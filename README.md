# LD6053 Dissertation — Implementation Evidence and Re-execution Guide

Implementation evidence for **"From Public Funding to Sponsor-Capable Career
Pathways: A Medallion Data Pipeline Using Token-Based Fuzzy Matching,
Unsupervised Nearest-Neighbour Matching with TF-IDF and Cosine Distance, and
Power BI"** — Jorge Tomas Chabrillon, 2026 (Northumbria University, LD6053).

The pipeline collects recent Contracts Finder and UKRI Gateway to Research
records, processes them through Bronze, Silver and Gold layers, matches
organisation names against the Home Office Register of Licensed Sponsors using
two independent scoring routes, and writes dated CSV evidence. An optional final
stage uploads reporting tables to SQL Server for Power BI.

---

## Before you start — read this

**Reported figures are from the 11 August 2026 run.** Both source APIs return a
rolling 90-day window, so a run on any other date retrieves different records.
Re-execution reproduces the **process and output structure**, not identical row
counts. This is stated as a limitation in the dissertation (Section 7.6.1).

**The sponsor register CSV is supplied in this repository** — you do not need to
download it from gov.uk. See Step 3.

---

## What you need

1. A Google account
2. A web browser (no local Python installation required)
3. Internet access to the public Contracts Finder and Gateway to Research APIs
4. About 10–15 minutes for a full run at the default settings

Everything else — Python packages and the Microsoft ODBC driver — is installed
by the notebook into the Colab runtime.

---

## Step-by-step: running the pipeline

### Step 1 — Download the two files from this repository

From this repository, download:

- `LD6053_dissertation_CF_GTR_PYTHON.ipynb` (the notebook)
- `code/!SP_-_Worker_and_Temporary_Worker_Web_Register_-_2026-07-23 (1).csv`
  (the Home Office sponsor register)

To download a single file on GitHub: click the file, then click the download
icon (or **Raw** → right-click → Save as).

### Step 2 — Create the Drive folder

1. Go to https://drive.google.com and sign in
2. In **My Drive**, create a folder. The name must match exactly — the notebook looks for
   `/content/drive/MyDrive/LD6053-dissertation`.

### Step 3 — Upload the sponsor register CSV

Upload the CSV **directly inside** `MyDrive/LD6053-dissertation`.

- Do **not** put it in a subfolder. The notebook does not search subdirectories.
- Do **not** rename it in a way that breaks the pattern. The filename must
  either contain `Worker_and_Temporary_Worker`, or start with `SP_` and contain
  `Worker`. The supplied filename already satisfies this.
- If you prefer a current register, download the latest from
  *Register of licensed sponsors: workers* on gov.uk and follow the same naming
  rule. It must contain a column called `Organisation Name`.

### Step 4 — Open the notebook in Google Colab

1. Go to https://colab.research.google.com and sign in with the same Google
   account that owns the Drive folder
2. **File → Upload notebook** and select the `.ipynb` you downloaded

   (Alternatively **File → Open notebook → GitHub**, paste this repository URL,
   and select the notebook.)

### Step 5 — Turn off the SQL upload

Scroll to **Section 2 — Imports, Drive folder, and settings** and change:

```python
RUN_SQL_UPLOAD = True
```

to

```python
RUN_SQL_UPLOAD = False
```

**Do this unless you have your own SQL Server instance.** The published notebook
points at the author's hosted database, which you are not authorised to write
to. With `RUN_SQL_UPLOAD = False`, Sections 1–8 run the complete pipeline and
produce all twelve CSV outputs — no database is needed.

Leave all other settings unchanged to reproduce the documented bounded-run
configuration:

| Setting | Value | Meaning |
|---|---|---|
| `ROWS_PER_SOURCE` | 300 | Max rows retained per API |
| `RECENT_DAYS` | 90 | Recency window |
| `FUZZY_THRESHOLD` | 90 | Token-sort acceptance threshold |
| `ML_THRESHOLD_PERCENT` | 75.0 | TF-IDF / nearest-neighbour threshold |
| `FUZZY_CANDIDATE_SHORTLIST` | 25 | TF-IDF shortlist size for fuzzy scoring |

### Step 6 — Run it

1. **Runtime → Run all**
2. Section 1 installs packages and the ODBC driver. This takes 1–2 minutes and
   prints a lot of output — this is normal.
3. **When prompted, authorise Colab to access Google Drive.** A dialogue will
   appear asking you to choose your Google account and click **Allow**. The run
   cannot continue until you do. If you miss the prompt, re-run the Section 2
   cell.
4. Watch Section 8 — it prints per-stage progress bars and timings.

The notebook creates a dated output folder automatically:



### Step 7 — Check the outputs

Twelve CSV files are written to the dated folder:

| File | Contents |
|---|---|
| `HOME_SPONSOR.csv` | Cleaned sponsor register reference data |
| `CF_BRONZE.csv` | Contracts Finder raw source evidence |
| `CF_SILVER.csv` | Contracts Finder cleaned and normalised |
| `CF_GOLD_FUZ.csv` | Contracts Finder fuzzy-matched, threshold-qualified |
| `CF_GOLD_ML.csv` | Contracts Finder TF-IDF-matched, threshold-qualified |
| `CF_COMPARISON.csv` | Contracts Finder candidates, scores, agreement, exclusion reasons |
| `GTR_BRONZE.csv` | Gateway to Research raw source evidence |
| `GTR_SILVER.csv` | Gateway to Research cleaned and normalised |
| `GTR_GOLD_FUZ.csv` | Gateway to Research fuzzy-matched |
| `GTR_GOLD_ML.csv` | Gateway to Research TF-IDF-matched |
| `GTR_COMPARISON.csv` | Gateway to Research comparison evidence |
| `LD6053_RUNTIME_LOG.csv` | Per-stage status, row counts and timings |

The two `*_COMPARISON.csv` files are the key validation evidence: they retain
both candidate matches, both scores, whether the methods agreed, and the reason
for every exclusion.

Section 8 also prints an automated validation summary showing accepted and
excluded counts by category, and the candidate agreement rate per source.

---

## Optional: running the SQL Server stage

Only if you have your own SQL Server instance and wish to reproduce the
reporting layer.

1. Execute the schema script in this repository against your database. It
   creates five tables (`DimSponsorOrganisation`, `Gold_ContractsFinder`,
   `Gold_GtRResearch`, `MatchComparison`, `DataLoadAudit`) and five reporting
   views (`vw_Dashboard_Overview`, `vw_Dashboard_ContractsFinder`,
   `vw_Dashboard_GtRResearch`, `vw_MatchingComparisonSummary`,
   `vw_AutomatedValidationEvidence`).
2. In Section 2, set `SQL_SERVER` and `SQL_DATABASE` to your own instance.
3. Replace the `SQL_USERNAME` and `SQL_PASSWORD` values with your own.
   Preferably move them to Colab Secrets:

```python
   from google.colab import userdata
   SQL_USERNAME = userdata.get("SQL_USERNAME")
   SQL_PASSWORD = userdata.get("SQL_PASSWORD")
```

   Add both secrets in the Colab **key icon** panel and enable notebook access.
4. Set `RUN_SQL_UPLOAD = True` and run all.

The upload replaces **only the current UTC day's rows**; previous dated
partitions are preserved. A storage preflight check stops the run rather than
filling the database log if free space falls below the configured minimum.

---

## Troubleshooting

**Drive does not mount.** Confirm the browser is signed into Google, accept the
permission dialogue, and re-run the Section 2 cell.

**"Sponsor Register CSV not found."** The CSV is not directly inside
`MyDrive/LD6053-dissertation`, or its filename does not match the required
pattern. Fix the location or name, then **re-run the Section 2 cell** before
continuing — the file path is resolved once during setup, so adding the CSV
afterwards is not detected until Section 2 runs again.

**"Sponsor Register must contain a column called Organisation Name."** You are
using a register export with different headers. Use the supplied CSV.

**SQL connection or credential error.** Set `RUN_SQL_UPLOAD = False` for a
CSV-only run. Section 9 is the only stage requiring a database.

**API error or unexpectedly low row count.** Both APIs are live. Re-run the
affected cell, or re-run later. Row counts vary by date because of the rolling
90-day window.

**Colab runtime disconnects.** Re-run all cells. Outputs already written to
Drive are preserved.

**Existing dated folder.** Outputs for the same date overwrite the same folder.
Copy a previous evidence run elsewhere first if it must remain unchanged.

---

## Data and security notes

- The published notebook contains hardcoded database credentials for the
  author's own hosted instance. **Do not use them.** Set
  `RUN_SQL_UPLOAD = False`, or substitute your own credentials via Colab
  Secrets as shown above. These credentials will be rotated and removed after
  assessment.
- The project uses public secondary organisational, award and contract data. No
  participant personal data is collected and no user study was conducted.
- Matching results are similarity-based, not verified accuracy. No labelled
  ground truth was produced, so precision, recall and accuracy are not
  reported. Public funding is treated as an activity signal only — it does not
  indicate a vacancy, an employer's willingness to sponsor, or candidate
  eligibility.
- Check source licences before redistributing any derived data.
