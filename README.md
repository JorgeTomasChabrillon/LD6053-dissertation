# LD6053 Dissertation — Implementation Evidence and Re-execution Guide

Implementation evidence for **"From Public Funding to Sponsor-Capable Career Pathways: A Medallion Data Pipeline Using Token-Based Fuzzy Matching, Unsupervised Nearest-Neighbour Matching with TF-IDF and Cosine Distance, and Power BI"** — Jorge Tomas Chabrillon, 2026 (Northumbria University, LD6053).

The pipeline collects recent Contracts Finder and UKRI Gateway to Research records, processes them through Bronze, Silver and Gold layers, matches organisation names against the Home Office Register of Licensed Sponsors using two scoring routes, and writes dated CSV evidence. An optional final stage uploads reporting tables to SQL Server for Power BI.

---

## Before you start — read this

**Reported figures are from the 11 August 2026 run.** Both source APIs return a rolling 90-day window, so a run on any other date retrieves different records. Re-execution reproduces the **process and output structure**, not identical row counts. This is stated as a limitation in the dissertation (Section 7.6.1).

**The sponsor register CSV is supplied in this repository** — you do not need to download it from gov.uk. See Step 1.

**The SQL upload stage is optional and should be turned off** unless you have your own SQL Server instance. See Step 5.

---

## What you need

1. A Google account
2. A web browser — no local Python installation required
3. Internet access to the public Contracts Finder and Gateway to Research APIs
4. About 10–15 minutes for a full run at the default settings

Everything else — the Python packages and the Microsoft ODBC driver — is installed by the notebook into the Colab runtime.

Main Python dependencies: pandas, numpy, requests, tqdm, thefuzz, python-Levenshtein, scikit-learn, SQLAlchemy, pyodbc.

---

## Repository contents

| File | Purpose |
|---|---|
| `LD6053_dissertation_CF_GTR_PYTHON.ipynb` | The executable Colab pipeline (Sections 1–9) |
| `code/!SP_-_Worker_and_Temporary_Worker_Web_Register_-_2026-07-23 (1).csv` | Home Office sponsor register used as matching reference |
| SQL schema script | Creates the five tables, five reporting views and 33 constraints |
| SQL validation / inspection scripts | Row-count checks and reporting queries used during testing |
| Power BI report file (`.pbix`) | Four-page dashboard: Overview, Contracts Finder, Gateway to Research, Data Quality |

---

## Step-by-step: running the pipeline

### Step 1 — Download two files from this repository

Download these:

- `LD6053_dissertation_CF_GTR_PYTHON.ipynb`
- `code/!SP_-_Worker_and_Temporary_Worker_Web_Register_-_2026-07-23 (1).csv`

To download a single file on GitHub: click the file, then click the download icon — or click **Raw**, right-click, and **Save as**.

### Step 2 — Create the Google Drive folder

1. Go to https://drive.google.com and sign in
2. In **My Drive**, create a folder named exactly:

```
LD6053-dissertation
```

The name must match exactly. The notebook looks for `/content/drive/MyDrive/LD6053-dissertation` and will not find a folder named anything else.

### Step 3 — Upload the sponsor register CSV to that folder

Upload the CSV **directly inside** `MyDrive/LD6053-dissertation`.

- Do **not** place it in a subfolder. The notebook does not search subdirectories.
- Do **not** rename it in a way that breaks the pattern. The filename must either contain `Worker_and_Temporary_Worker`, or start with `SP_` and contain `Worker`. The supplied filename already satisfies this.
- If you prefer a current register, download the latest from *Register of licensed sponsors: workers* on gov.uk and follow the same naming rule. It must contain a column called `Organisation Name`.

### Step 4 — Open the notebook in Google Colab

1. Go to https://colab.research.google.com
2. Sign in with the **same Google account that owns the Drive folder** from Step 2
3. **File → Upload notebook**, and select the `.ipynb` you downloaded

Alternatively: **File → Open notebook → GitHub**, paste this repository URL, and select the notebook.

### Step 5 — Turn off the SQL upload

Scroll to **Section 2 — Imports, Drive folder, and settings** and change:

```python
RUN_SQL_UPLOAD = True
```

to:

```python
RUN_SQL_UPLOAD = False
```

**Do this unless you have your own SQL Server instance.** The published notebook points at the author's hosted database, which you are not authorised to write to. With `RUN_SQL_UPLOAD = False`, Sections 1–8 run the complete pipeline and produce all twelve CSV outputs with no database required.

Leave all other settings unchanged to reproduce the documented bounded-run configuration:

| Setting | Value | Meaning |
|---|---|---|
| `ROWS_PER_SOURCE` | 300 | Maximum rows retained per API |
| `RECENT_DAYS` | 90 | Recency window in days |
| `FUZZY_THRESHOLD` | 90 | Token-sort acceptance threshold |
| `ML_THRESHOLD_PERCENT` | 75.0 | TF-IDF / nearest-neighbour acceptance threshold |
| `FUZZY_CANDIDATE_SHORTLIST` | 25 | TF-IDF shortlist size used for fuzzy scoring |
| `REFETCH_API_DATA` | True | Fetch fresh data from both APIs |
| `RUN_CONTRACTS_FINDER` | True | Enable the Contracts Finder pipeline |
| `RUN_GTR` | True | Enable the Gateway to Research pipeline |

### Step 6 — Run all cells

1. **Runtime → Run all**
2. Section 1 installs the Python packages and the Microsoft ODBC driver. This takes 1–2 minutes and prints a large amount of installation output — this is normal.
3. **When prompted, authorise Colab to access Google Drive.** A dialogue appears asking you to choose your Google account and click **Allow**, then **Connect to Google Drive**. The run cannot continue until you do this. If you miss the prompt or dismiss it, re-run the Section 2 cell.
4. Section 8 runs the full pipeline and prints per-stage progress bars, row counts and timings.

The notebook creates a dated output folder automatically:

```
MyDrive/LD6053-dissertation/YYYYMMDD/
```

You do not need to create this folder yourself.

### Step 7 — Check the outputs

Twelve CSV files are written to the dated folder:

| File | Contents |
|---|---|
| `HOME_SPONSOR.csv` | Cleaned sponsor register reference data |
| `CF_BRONZE.csv` | Contracts Finder raw source evidence |
| `CF_SILVER.csv` | Contracts Finder cleaned and normalised |
| `CF_GOLD_FUZ.csv` | Contracts Finder fuzzy-matched, threshold-qualified |
| `CF_GOLD_ML.csv` | Contracts Finder TF-IDF-matched, threshold-qualified |
| `CF_COMPARISON.csv` | Contracts Finder candidates, scores, agreement and exclusion reasons |
| `GTR_BRONZE.csv` | Gateway to Research raw source evidence |
| `GTR_SILVER.csv` | Gateway to Research cleaned and normalised |
| `GTR_GOLD_FUZ.csv` | Gateway to Research fuzzy-matched, threshold-qualified |
| `GTR_GOLD_ML.csv` | Gateway to Research TF-IDF-matched, threshold-qualified |
| `GTR_COMPARISON.csv` | Gateway to Research candidates, scores, agreement and exclusion reasons |
| `LD6053_RUNTIME_LOG.csv` | Per-stage status, row counts and timings |

Bronze retains source evidence, Silver contains cleaned and normalised data, Gold contains threshold-qualified matching results for each method, and Comparison contains the automated agreement, acceptance and exclusion evidence.

The two `*_COMPARISON.csv` files are the key validation evidence: they retain both candidate matches, both scores, whether the two methods agreed, and the recorded reason for every exclusion.

Section 8 also prints an automated validation summary showing accepted and excluded counts by category (`ACCEPTED`, `EXCLUDED_LOW_CONFIDENCE`, `EXCLUDED_SINGLE_METHOD`, `EXCLUDED_METHOD_DISAGREEMENT`) and the candidate agreement rate per source.

---

## How the matching works

1. **Exact match** on cleaned organisation names returns a score of 100.
2. **Non-exact matching** applies two routes:
   - a token-sort fuzzy scorer applied to a shortlist of 25 TF-IDF / nearest-neighbour candidates
   - a TF-IDF character n-gram scorer using cosine-distance nearest neighbours
3. A match becomes **dashboard eligible** only when both routes identify the same sponsor **and** the fuzzy score is at least 90 **and** the TF-IDF score is at least 75.
4. If either condition fails, the record is retained with an exclusion reason rather than discarded, so all comparison evidence is preserved.

The two routes are **not fully independent** — the fuzzy route consumes the TF-IDF shortlist. Agreement between routes is therefore an eligibility filter, not a measure of accuracy. This is documented in the dissertation (Sections 5.4 and 8.3).

---

## Optional: running the SQL Server stage

Only if you have your own SQL Server instance and wish to reproduce the reporting layer.

1. Execute the schema script in this repository against your database. It creates five tables — `DimSponsorOrganisation`, `Gold_ContractsFinder`, `Gold_GtRResearch`, `MatchComparison`, `DataLoadAudit` — and five reporting views: `vw_Dashboard_Overview`, `vw_Dashboard_ContractsFinder`, `vw_Dashboard_GtRResearch`, `vw_MatchingComparisonSummary`, `vw_AutomatedValidationEvidence`. The script includes 33 constraints, including foreign keys from the Gold tables to the sponsor dimension and CHECK constraints on scores and method values.
2. In Section 2, set `SQL_SERVER` and `SQL_DATABASE` to your own instance.
3. Replace the `SQL_USERNAME` and `SQL_PASSWORD` values with your own. Preferably move them out of the code and into Colab Secrets:

```python
from google.colab import userdata
SQL_USERNAME = userdata.get("SQL_USERNAME")
SQL_PASSWORD = userdata.get("SQL_PASSWORD")
```

Add both secrets using the **key icon** in the Colab left sidebar and enable notebook access for each.

4. Set `RUN_SQL_UPLOAD = True` and run all cells.

Behaviour of the upload stage:

- Replaces **only the current UTC day's rows**. Previous dated partitions are preserved.
- Runs a **storage preflight check** and stops cleanly rather than filling the transaction log if free space falls below the configured minimum.
- Uses small autocommitted insert and delete batches to protect hosted SQL instances with limited log capacity.
- Writes a row-count audit to `DataLoadAudit` for reconciliation against the CSV outputs.

---

## Troubleshooting

**Drive does not mount.** Confirm the browser is signed into Google, accept the permission dialogue, and re-run the Section 2 cell.

**"Sponsor Register CSV not found."** The CSV is not directly inside `MyDrive/LD6053-dissertation`, or its filename does not match the required pattern. Fix the location or the name, then **re-run the Section 2 cell** before continuing. The file path is resolved once during setup, so adding the CSV afterwards is not detected until Section 2 runs again.

**"Sponsor Register must contain a column called Organisation Name."** You are using a register export with different column headers. Use the CSV supplied in this repository.

**SQL connection or credential error.** Set `RUN_SQL_UPLOAD = False` for a CSV-only run. Section 9 is the only stage that requires a database.

**API error, timeout, or unexpectedly low row count.** Both APIs are live and rate-limited. Re-run the affected cell, or re-run later. Row counts vary by date because of the rolling 90-day window.

**Colab runtime disconnects mid-run.** Re-run all cells. Any outputs already written to Drive are preserved.

**Existing dated folder.** Outputs for the same date are written to the same folder and will overwrite it. Copy a previous evidence run elsewhere first if it must remain unchanged.

**Run takes much longer than expected.** Increasing `ROWS_PER_SOURCE` significantly increases runtime. A test at 500 rows per source exceeded 50 minutes. The documented configuration uses 300.

---

## Data and security notes

- The published notebook contains hardcoded database credentials for the author's own hosted instance. **Do not use them.** Set `RUN_SQL_UPLOAD = False`, or substitute your own credentials via Colab Secrets as shown above. These credentials will be rotated and removed after assessment.
- The project uses public secondary organisational, award and contract data. No participant personal data is collected and no user study was conducted.
- Matching results are **similarity-based, not verified accuracy**. No labelled ground truth was produced, so precision, recall and accuracy are not reported. The database field `MatchingAccuracyPercent` is a misnomer retained for schema compatibility — it stores a similarity score and is scheduled to be renamed `SimilarityScorePercent`.
- Public funding is treated as an **activity signal only**. It does not indicate a vacancy, an employer's willingness to sponsor, or candidate eligibility. The dashboard carries this disclaimer on every page.
- Check the source licences for Contracts Finder, Gateway to Research and the Home Office register before redistributing any derived data.

---

## Citation

Chabrillon, J.T. (2026) *From Public Funding to Sponsor-Capable Career Pathways: A Medallion Data Pipeline Using Token-Based Fuzzy Matching, Unsupervised Nearest-Neighbour Matching with TF-IDF and Cosine Distance, and Power BI*. BSc (Hons) Computing with Data Science and Big Data Technology dissertation, Northumbria University.
