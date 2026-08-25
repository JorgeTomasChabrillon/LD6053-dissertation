# LD6053-dissertation

# LD6053 Dissertation - Re-execution Guide

## Project

This repository contains the implementation evidence for "From Public Funding to Sponsor-Capable Career Pathways" by Jorge Tomas Chabrillon (2026). The project uses Python in Google Colab to collect recent Contracts Finder and Gateway to Research data, process it through Bronze, Silver and Gold layers, compare organisation names with token-based fuzzy matching and TF-IDF nearest-neighbour matching, and optionally upload reporting tables to SQL Server for Power BI.

## Main files

- `LD6053_dissertation_CF_GTR_PYTHON.ipynb` - final executable Google Colab pipeline
- `data base creation.sql` - SQL Server tables, constraints and reporting views
- `power bi dashboard.pbix` - four-page Power BI report
- `check counts.sql`, `selects.sql` and the other SQL scripts - validation and inspection queries

## Requirements

1. A Google account.
2. Access to Google Colab: https://colab.research.google.com/
3. Permission to mount Google Drive from Colab.
4. A current Home Office Worker and Temporary Worker sponsor-register CSV. Its filename must contain `Worker_and_Temporary_Worker`, or begin with `SP_` and contain `Worker`.
5. Internet access to the public Contracts Finder and Gateway to Research APIs.
6. SQL Server credentials only if the optional SQL-upload stage will be run.

The notebook installs its Python packages and the Microsoft SQL Server ODBC driver in the Colab runtime. The main Python dependencies are pandas, numpy, requests, tqdm, thefuzz, python-Levenshtein, scikit-learn, SQLAlchemy and pyodbc.

## Run the notebook in Google Colab

1. Sign in to the Google account that will own the generated output files.
2. Open https://colab.research.google.com/.
3. Choose File > Open notebook > GitHub and enter this repository URL, or download `LD6053_dissertation_CF_GTR_PYTHON.ipynb` and upload it to Colab.
4. In Google Drive, create `MyDrive/LD6053-dissertation` if it does not already exist.
5. Place the current Home Office sponsor-register CSV directly inside `MyDrive/LD6053-dissertation`.
6. In the notebook settings, keep `ROWS_PER_SOURCE = 300` and `RECENT_DAYS = 90` to reproduce the documented bounded-run configuration. The APIs are live, so row contents and counts can change when the notebook is rerun on another date.
7. Decide whether to use the optional SQL stage:
   - For a CSV-only examiner run, set `RUN_SQL_UPLOAD = False` before running all cells. The current setup cell still reads the names `SQL_USERNAME` and `SQL_PASSWORD`, so add non-sensitive placeholder values for both in Colab Secrets and enable notebook access. They will not be sent anywhere while `RUN_SQL_UPLOAD` is False.
   - For an authorised SQL run, first execute `data base creation.sql` on the target SQL Server. Add the real values as private Colab Secrets named `SQL_USERNAME` and `SQL_PASSWORD`, enable notebook access to them, and confirm the `SQL_SERVER` and `SQL_DATABASE` settings point to an authorised database. Never paste credentials into a code cell or commit them to GitHub.
8. Select Runtime > Run all.
9. When Google asks, authorise Colab to mount Google Drive. The notebook creates a dated output folder at `/content/drive/MyDrive/LD6053-dissertation/YYYYMMDD/`.
10. Allow the run to finish and review the final pipeline summary and runtime log. Temporary public-API or network failures may require rerunning the affected cell or the full notebook.

## Expected outputs

The dated output folder contains:

- `HOME_SPONSOR.csv`
- `CF_BRONZE.csv`
- `CF_SILVER.csv`
- `CF_GOLD_FUZ.csv`
- `CF_GOLD_ML.csv`
- `CF_COMPARISON.csv`
- `GTR_BRONZE.csv`
- `GTR_SILVER.csv`
- `GTR_GOLD_FUZ.csv`
- `GTR_GOLD_ML.csv`
- `GTR_COMPARISON.csv`
- `LD6053_RUNTIME_LOG.csv`

Bronze retains source evidence, Silver contains cleaned and normalised data, Gold contains threshold-qualified matching results for the fuzzy and TF-IDF methods, and Comparison contains the automated agreement/acceptance/exclusion evidence. `LD6053_RUNTIME_LOG.csv` records pipeline-stage status and timings.

Because Contracts Finder, Gateway to Research and the Sponsor Register are live or periodically updated sources, a later rerun is expected to reproduce the process and output structure rather than identical records or counts.

## Troubleshooting

- Drive does not mount: confirm that the browser is signed into Google, allow the requested Drive permission, and rerun the setup cell.
- Sponsor Register not found: confirm that the CSV is directly inside `MyDrive/LD6053-dissertation` and that its filename matches one of the patterns described above.
- Colab Secret error: add `SQL_USERNAME` and `SQL_PASSWORD` in the Colab Secrets panel and enable notebook access. Use private authorised credentials only when `RUN_SQL_UPLOAD = True`.
- SQL connection error: set `RUN_SQL_UPLOAD = False` for a CSV-only run, or verify the authorised server, database, ODBC installation, firewall and credentials.
- API error or unexpectedly low row count: rerun later and check whether the source API returned data within the configured 90-day window.
- Existing dated folder: outputs for the same date use the same folder. Preserve a previous evidence run before rerunning if it must remain unchanged.

## Security and data note

No database password is stored in the notebook. Credentials must remain in Colab Secrets and must never be committed to the repository. The project uses public secondary organisational and award/contract data and does not collect participant personal data. Check source licences and avoid redistributing copyrighted material without permission.
