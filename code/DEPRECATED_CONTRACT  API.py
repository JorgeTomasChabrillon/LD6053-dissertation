import requests
import pandas as pd
from thefuzz import process, fuzz
import os
import time
import glob
from datetime import datetime, timedelta
from tqdm import tqdm

# --- CONFIGURATION ---
BASE_DIR = r"C:\Users\tomas\Desktop\Computing\Year 3, Semester 1\4 - LD6053 UG Computing Project\UG"
API_DIR = os.path.join(BASE_DIR, "Contracts Finder API")

# Auto-detect Sponsor File
sponsor_files = glob.glob(os.path.join(BASE_DIR, "*Worker_and_Temporary_Worker*.csv"))
SPONSOR_FILE = sponsor_files[0] if sponsor_files else None

# Output Files (Medallion Architecture)
BRONZE_FILE = os.path.join(API_DIR, "cf_bronze_dirty.csv")
SILVER_FILE = os.path.join(API_DIR, "cf_silver_cleaned.csv")
GOLD_FILE = os.path.join(API_DIR, "cf_gold_matched.csv")

# API Settings
MONTHS_TO_FETCH = 12
PAGES_PER_MONTH = 50

def fetch_bronze_data():
    print(f"\n--- PHASE 1: EXTRACTION (Bronze Layer) ---")
    if os.path.exists(BRONZE_FILE): os.remove(BRONZE_FILE)
    
    print(f"Scanning {MONTHS_TO_FETCH} months of historical contract awards...")
    
    for i in range(MONTHS_TO_FETCH):
        start_date = (datetime.now() - timedelta(days=(i+1)*30)).strftime('%Y-%m-%d')
        end_date = (datetime.now() - timedelta(days=i*30)).strftime('%Y-%m-%d')
        
        page_rows = []
        for page in tqdm(range(1, PAGES_PER_MONTH + 1), desc=f"Month {i+1} ({start_date} to {end_date})"):
            url = f"https://www.contractsfinder.service.gov.uk/Published/Notices/OCDS/Search?type=award&publishedFrom={start_date}&publishedTo={end_date}&page={page}"
            try:
                response = requests.get(url, timeout=25)
                if response.status_code != 200: 
                    break 
                
                data = response.json()
                releases = data.get('releases', []) or [item.get('releases', [])[0] for item in data.get('results', []) if item.get('releases')]
                
                if not releases: break
                    
                for rel in releases:
                    title = rel.get('tender', {}).get('title', 'N/A')
                    for award in rel.get('awards', []):
                        for s in award.get('suppliers', []):
                            if s.get('name'):
                                award_date = award.get('date', 'Unknown')
                                if award_date != 'Unknown' and "T" in str(award_date):
                                    award_date = str(award_date).split("T")[0]
                                    
                                page_rows.append({
                                    'Contract_Title': title,
                                    'Contract_Value': award.get('value', {}).get('amount', 0),
                                    'Supplier_Name': s.get('name'),
                                    'Award_Date': award_date
                                })
                time.sleep(0.3)
            except Exception:
                break
                
        # Incremental Save to Bronze per month
        if page_rows:
            df_batch = pd.DataFrame(page_rows).drop_duplicates()
            df_batch.to_csv(BRONZE_FILE, mode='a', header=not os.path.exists(BRONZE_FILE), index=False, encoding='utf-8')
            
    if os.path.exists(BRONZE_FILE):
        df_bronze = pd.read_csv(BRONZE_FILE).drop_duplicates()
        df_bronze.to_csv(BRONZE_FILE, index=False, encoding='utf-8')
        print(f"Bronze file saved: {len(df_bronze)} total contracts downloaded.")
        return df_bronze
    else:
        print("ERROR: Bronze Layer failed to extract data.")
        return pd.DataFrame()

def clean_silver_data(df_bronze):
    print("\n--- PHASE 2: STANDARDIZATION (Silver Layer) ---")
    
    # Drop rows without Supplier Name and Standardize Formatting
    df_silver = df_bronze.dropna(subset=['Supplier_Name']).copy()
    df_silver['Supplier_Name'] = df_silver['Supplier_Name'].astype(str).str.upper().str.strip()
    
    # Handle numeric values for Power BI
    df_silver['Contract_Value'] = pd.to_numeric(df_silver['Contract_Value'], errors='coerce').fillna(0)
    
    # Sort by Award Date descending
    df_silver.sort_values(by="Award_Date", ascending=False, inplace=True)
    
    df_silver.to_csv(SILVER_FILE, index=False, encoding='utf-8')
    print(f"Silver layer complete! {len(df_silver)} clean contracts saved.")
    return df_silver

def match_gold_incremental(df_silver):
    print("\n--- PHASE 3: ENTITY RESOLUTION (Gold Layer) ---")
    if not SPONSOR_FILE: return print("CRITICAL: Sponsor file missing in the UG folder.")

    # Load Sponsor List and standardize base names for grouping
    df_sponsors = pd.read_csv(SPONSOR_FILE, low_memory=False)
    df_sponsors['Organisation Name'] = df_sponsors['Organisation Name'].astype(str).str.upper().str.strip()
    
    # Aggregate routes to avoid repetition in final file
    df_lookup = df_sponsors.groupby('Organisation Name').agg({
        'Town/City': 'first',
        'Route': lambda x: ' / '.join(sorted(x.unique()))
    }).reset_index()
    
    sponsor_names = list(df_lookup['Organisation Name'].unique())
    sponsor_set = set(sponsor_names)

    if os.path.exists(GOLD_FILE): os.remove(GOLD_FILE)
    results_batch = []
    
    for i, row in tqdm(df_silver.iterrows(), total=len(df_silver), desc="Matching Companies"):
        name = str(row['Supplier_Name'])
        matched_name = name if name in sponsor_set else None
        
        # Stricter token_set_ratio matching
        if not matched_name:
            match = process.extractOne(name, sponsor_names, scorer=fuzz.token_sort_ratio)
            if match and match[1] >= 90:
                matched_name = match[0]
        
        if matched_name:
            sponsor_info = df_lookup[df_lookup['Organisation Name'] == matched_name].iloc[0]
            
            new_row = row.to_dict()
            new_row['matched_sponsor'] = matched_name
            new_row['Town/City'] = sponsor_info['Town/City']
            new_row['Route'] = sponsor_info['Route']
            
            results_batch.append(new_row)
        
        # Incremental Save every 50 matches
        if len(results_batch) >= 50:
            pd.DataFrame(results_batch).to_csv(GOLD_FILE, mode='a', header=not os.path.exists(GOLD_FILE), index=False, encoding='utf-8')
            results_batch = [] 

    if results_batch:
        pd.DataFrame(results_batch).to_csv(GOLD_FILE, mode='a', header=not os.path.exists(GOLD_FILE), index=False, encoding='utf-8')
    print(f"\nPipeline complete! All files generated in: {API_DIR}")

if __name__ == "__main__":
    os.makedirs(API_DIR, exist_ok=True)
    
    df_bronze = fetch_bronze_data()
    if not df_bronze.empty:
        df_silver_clean = clean_silver_data(df_bronze)
        if not df_silver_clean.empty:
            match_gold_incremental(df_silver_clean)
        else:
            print("ERROR: Silver Layer ended up empty.")
