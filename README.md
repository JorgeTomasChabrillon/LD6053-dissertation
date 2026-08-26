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
2. In **My Drive**, create a folder named exactly:
