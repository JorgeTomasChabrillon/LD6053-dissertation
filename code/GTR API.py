import requests
import pandas as pd
import time
import os
import glob
from thefuzz import process, fuzz
from tqdm import tqdm

BASE_DIR = r"C:\Users\tomas\Desktop\Computing\Year 3, Semester 1\4 - LD6053 UG Computing Project\UG"
API_DIR = os.path.join(BASE_DIR, "Gateway to research API")
sponsor_files = glob.glob(os.path.join(BASE_DIR, "*Worker_and_Temporary_Worker*.csv"))
SPONSOR_FILE = sponsor_files[0] if sponsor_files else None

BRONZE_FILE = os.path.join(API_DIR, "gtr_bronze_dirty.csv")
SILVER_FILE = os.path.join(API_DIR, "gtr_silver_cleaned.csv")
GOLD_FILE = os.path.join(API_DIR, "gtr_gold_matched.csv")

BASE_URL = "https://gtr.ukri.org/gtr/api/projects"
HEADERS = {"Accept": "application/vnd.rcuk.gtr.json-v7"}
PAGES_TO_FETCH = 100 

def fetch_recent_bronze_data():
    if os.path.exists(BRONZE_FILE): os.remove(BRONZE_FILE)
    
    try:
        init_res = requests.get(BASE_URL, headers=HEADERS, params={"s": 100, "p": 1}, timeout=20)
        total_pages = init_res.json().get("totalPages", 1500)
    except Exception:
        total_pages = 1500
        
    target_pages = range(total_pages, max(0, total_pages - PAGES_TO_FETCH), -1)
    
    page_rows = []
    for page in tqdm(target_pages, desc="Downloading Recent Projects"):
        try:
            res = requests.get(BASE_URL, headers=HEADERS, params={"s": 100, "p": page}, timeout=20)
            data = res.json().get("project", [])
            if not data: continue
            
            for p in data:
                org_url = "Unknown"
                links = p.get("links", {}).get("link", [])
                if isinstance(links, dict): links = [links]
                
                for link in links:
                    if link.get("rel") == "LEAD_ORG":
                        org_url = link.get("href", "Unknown")
                        break
                
                fund_info = p.get("fund", {})
                start_date = fund_info.get("start") if isinstance(fund_info, dict) else "Unknown"
                
                if start_date != "Unknown" and "T" in str(start_date):
                    start_date = str(start_date).split("T")[0]
                
                page_rows.append({
                    "project_id": p.get("id"),
                    "title": p.get("title"),
                    "status": p.get("status"),
                    "start_date": start_date,
                    "org_url": org_url
                })
            time.sleep(0.5) 
        except Exception:
            break
            
    df_bronze = pd.DataFrame(page_rows)
    df_bronze.to_csv(BRONZE_FILE, index=False, encoding='utf-8')
    return df_bronze

def clean_and_enrich_silver_data(df_bronze):
    df_silver = df_bronze[df_bronze['status'].astype(str).str.upper() == 'ACTIVE'].copy()
    unique_urls = [url for url in df_silver['org_url'].unique() if url != "Unknown"]
    
    url_to_name_dict = {"Unknown": "Unknown"}
    for url in tqdm(unique_urls, desc="Fetching Real Names"):
        try:
            secure_url = url.replace("http://", "https://")
            res = requests.get(secure_url, headers=HEADERS, timeout=10)
            if res.status_code == 200:
                url_to_name_dict[url] = res.json().get("name", "Unknown").upper().strip()
            else:
                url_to_name_dict[url] = "Unknown"
            time.sleep(0.1) 
        except:
            url_to_name_dict[url] = "Unknown"
            
    df_silver['lead_organisation'] = df_silver['org_url'].map(url_to_name_dict)
    df_silver = df_silver[df_silver['lead_organisation'] != "UNKNOWN"]
    df_silver.dropna(subset=['lead_organisation'], inplace=True)
    df_silver.drop(columns=['org_url'], inplace=True) 
    
    df_silver.sort_values(by="start_date", ascending=False, inplace=True)
    df_silver.to_csv(SILVER_FILE, index=False, encoding='utf-8')
    return df_silver

def match_gold_incremental(df_silver):
    if not SPONSOR_FILE: return
    df_sponsors = pd.read_csv(SPONSOR_FILE)
    sponsors = list(df_sponsors['Organisation Name'].astype(str).str.upper().str.strip().unique())
    sponsor_set = set(sponsors)

    if os.path.exists(GOLD_FILE): os.remove(GOLD_FILE)
    results_batch = []
    
    for i, row in tqdm(df_silver.iterrows(), total=len(df_silver), desc="Matching Companies"):
        name = str(row['lead_organisation'])
        matched_name = name if name in sponsor_set else None
        
        if not matched_name:
            match = process.extractOne(name, sponsors, scorer=fuzz.token_set_ratio)
            if match and match[1] >= 93:
                matched_name = match[0]
        
        if matched_name:
            new_row = row.to_dict()
            new_row['matched_sponsor'] = matched_name
            results_batch.append(new_row)
        
        if len(results_batch) >= 10:
            pd.DataFrame(results_batch).to_csv(GOLD_FILE, mode='a', header=not os.path.exists(GOLD_FILE), index=False, encoding='utf-8')
            results_batch = [] 

    if results_batch:
        pd.DataFrame(results_batch).to_csv(GOLD_FILE, mode='a', header=not os.path.exists(GOLD_FILE), index=False, encoding='utf-8')

if __name__ == "__main__":
    os.makedirs(API_DIR, exist_ok=True)
    df_bronze = fetch_recent_bronze_data()
    if not df_bronze.empty:
        df_silver_clean = clean_and_enrich_silver_data(df_bronze)
        if not df_silver_clean.empty:
            match_gold_incremental(df_silver_clean)