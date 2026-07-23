USE [jorgetomaschabrillon_LD6053dissertation]
GO


/* -----------------------------
   1. Drop views first
   ----------------------------- */
IF OBJECT_ID('dbo.vw_MatchingComparisonSummary', 'V') IS NOT NULL DROP VIEW dbo.vw_MatchingComparisonSummary;
IF OBJECT_ID('dbo.vw_Dashboard_Overview', 'V') IS NOT NULL DROP VIEW dbo.vw_Dashboard_Overview;
IF OBJECT_ID('dbo.vw_Dashboard_GtRResearch', 'V') IS NOT NULL DROP VIEW dbo.vw_Dashboard_GtRResearch;
IF OBJECT_ID('dbo.vw_Dashboard_ContractsFinder', 'V') IS NOT NULL DROP VIEW dbo.vw_Dashboard_ContractsFinder;
IF OBJECT_ID('dbo.vw_PossibleSkills', 'V') IS NOT NULL DROP VIEW dbo.vw_PossibleSkills;
IF OBJECT_ID('dbo.vw_PossibleJobs', 'V') IS NOT NULL DROP VIEW dbo.vw_PossibleJobs;
IF OBJECT_ID('dbo.vw_MainCompanies', 'V') IS NOT NULL DROP VIEW dbo.vw_MainCompanies;
IF OBJECT_ID('dbo.vw_Filters', 'V') IS NOT NULL DROP VIEW dbo.vw_Filters;
GO

/* -----------------------------
   2. Drop old and new tables
   ----------------------------- */
IF OBJECT_ID('dbo.MatchingValidation', 'U') IS NOT NULL DROP TABLE dbo.MatchingValidation;
IF OBJECT_ID('dbo.MatchComparison', 'U') IS NOT NULL DROP TABLE dbo.MatchComparison;
IF OBJECT_ID('dbo.Gold_GtRResearch', 'U') IS NOT NULL DROP TABLE dbo.Gold_GtRResearch;
IF OBJECT_ID('dbo.Gold_ContractsFinder', 'U') IS NOT NULL DROP TABLE dbo.Gold_ContractsFinder;
IF OBJECT_ID('dbo.Silver_GtRResearch', 'U') IS NOT NULL DROP TABLE dbo.Silver_GtRResearch;
IF OBJECT_ID('dbo.Silver_ContractsFinder', 'U') IS NOT NULL DROP TABLE dbo.Silver_ContractsFinder;
IF OBJECT_ID('dbo.Bronze_GtRResearch', 'U') IS NOT NULL DROP TABLE dbo.Bronze_GtRResearch;
IF OBJECT_ID('dbo.Bronze_ContractsFinder', 'U') IS NOT NULL DROP TABLE dbo.Bronze_ContractsFinder;
IF OBJECT_ID('dbo.DimSponsorOrganisation', 'U') IS NOT NULL DROP TABLE dbo.DimSponsorOrganisation;
IF OBJECT_ID('dbo.DataLoadAudit', 'U') IS NOT NULL DROP TABLE dbo.DataLoadAudit;

/* Old tables from previous design */
IF OBJECT_ID('dbo.PossibleJobs', 'U') IS NOT NULL DROP TABLE dbo.PossibleJobs;
IF OBJECT_ID('dbo.GtrProject', 'U') IS NOT NULL DROP TABLE dbo.GtrProject;
IF OBJECT_ID('dbo.ContractsFinderAward', 'U') IS NOT NULL DROP TABLE dbo.ContractsFinderAward;
GO

/* -----------------------------
   3. Audit table
   ----------------------------- */
CREATE TABLE dbo.DataLoadAudit (
    DataLoadAuditID BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FileName NVARCHAR(300) NOT NULL,
    SourceSystem NVARCHAR(50) NOT NULL,
    LayerName NVARCHAR(20) NOT NULL,
    RowsLoaded BIGINT NOT NULL,
    LoadedAtUTC DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

/* -----------------------------
   4. Sponsor dimension
   ----------------------------- */
CREATE TABLE dbo.DimSponsorOrganisation (
    SponsorKey BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    MatchedSponsor NVARCHAR(500) NOT NULL UNIQUE,
    TownCity NVARCHAR(255) NULL,
    SponsorRoute NVARCHAR(MAX) NULL,
    InsertedDate DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedDate DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

/* -----------------------------
   5. Contracts Finder layers
   Stores all current columns from:
   cf_bronze_dirty.csv, cf_silver_cleaned.csv, cf_gold_matched.csv
   ----------------------------- */
CREATE TABLE dbo.Bronze_ContractsFinder (
    BronzeContractID BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Contract_Title NVARCHAR(MAX) NULL,
    Contract_Value DECIMAL(18,2) NULL,
    Supplier_Name NVARCHAR(500) NULL,
    Award_Date NVARCHAR(50) NULL,
    InsertedDate DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedDate DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE dbo.Silver_ContractsFinder (
    SilverContractID BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Contract_Title NVARCHAR(MAX) NULL,
    Contract_Value DECIMAL(18,2) NULL,
    Supplier_Name NVARCHAR(500) NULL,
    Award_Date NVARCHAR(50) NULL,
    InsertedDate DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedDate DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE dbo.Gold_ContractsFinder (
    GoldContractID BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SponsorKey BIGINT NULL,
    Contract_Title NVARCHAR(MAX) NULL,
    Contract_Value DECIMAL(18,2) NULL,
    Supplier_Name NVARCHAR(500) NULL,
    Award_Date NVARCHAR(50) NULL,
    matched_sponsor NVARCHAR(500) NULL,
    Town_City NVARCHAR(255) NULL,
    Route NVARCHAR(MAX) NULL,
    MatchMethod NVARCHAR(30) NOT NULL DEFAULT 'Fuzzy',
    MatchingAccuracyPercent DECIMAL(5,2) NULL,
    InsertedDate DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedDate DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_GoldContractsFinder_Sponsor
        FOREIGN KEY (SponsorKey) REFERENCES dbo.DimSponsorOrganisation(SponsorKey),
    CONSTRAINT CK_GoldContractsFinder_MatchMethod
        CHECK (MatchMethod IN ('Exact', 'Fuzzy', 'ML')),
    CONSTRAINT CK_GoldContractsFinder_Accuracy
        CHECK (MatchingAccuracyPercent IS NULL OR MatchingAccuracyPercent BETWEEN 0 AND 100)
);
GO

/* -----------------------------
   6. Gateway to Research layers
   Stores all current columns from:
   gtr_bronze_dirty.csv, gtr_silver_cleaned.csv, gtr_gold_matched.csv
   ----------------------------- */
CREATE TABLE dbo.Bronze_GtRResearch (
    BronzeGtrID BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    project_id NVARCHAR(100) NULL,
    title NVARCHAR(MAX) NULL,
    status NVARCHAR(100) NULL,
    start_date NVARCHAR(50) NULL,
    org_url NVARCHAR(1000) NULL,
    InsertedDate DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedDate DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE dbo.Silver_GtRResearch (
    SilverGtrID BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    project_id NVARCHAR(100) NULL,
    title NVARCHAR(MAX) NULL,
    status NVARCHAR(100) NULL,
    start_date NVARCHAR(50) NULL,
    lead_organisation NVARCHAR(500) NULL,
    InsertedDate DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedDate DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE dbo.Gold_GtRResearch (
    GoldGtrID BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SponsorKey BIGINT NULL,
    project_id NVARCHAR(100) NULL,
    title NVARCHAR(MAX) NULL,
    status NVARCHAR(100) NULL,
    start_date NVARCHAR(50) NULL,
    lead_organisation NVARCHAR(500) NULL,
    matched_sponsor NVARCHAR(500) NULL,
    MatchMethod NVARCHAR(30) NOT NULL DEFAULT 'Fuzzy',
    MatchingAccuracyPercent DECIMAL(5,2) NULL,
    InsertedDate DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedDate DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_GoldGtRResearch_Sponsor
        FOREIGN KEY (SponsorKey) REFERENCES dbo.DimSponsorOrganisation(SponsorKey),
    CONSTRAINT CK_GoldGtRResearch_MatchMethod
        CHECK (MatchMethod IN ('Exact', 'Fuzzy', 'ML')),
    CONSTRAINT CK_GoldGtRResearch_Accuracy
        CHECK (MatchingAccuracyPercent IS NULL OR MatchingAccuracyPercent BETWEEN 0 AND 100)
);
GO

/* -----------------------------
   7. Matching comparison table
   This supports fuzzy vs unsupervised ML comparison and manual validation.
   ----------------------------- */
CREATE TABLE dbo.MatchComparison (
    MatchComparisonID BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SourceSystem NVARCHAR(50) NOT NULL,          -- ContractsFinder or GtRResearch
    SourceRecordKey NVARCHAR(200) NULL,          -- project_id or generated contract row key
    SourceOrganisationName NVARCHAR(500) NULL,   -- Supplier_Name or lead_organisation
    FuzzyMatchedSponsor NVARCHAR(500) NULL,
    FuzzyScorePercent DECIMAL(5,2) NULL,
    MLMatchedSponsor NVARCHAR(500) NULL,
    MLScorePercent DECIMAL(5,2) NULL,
    MethodsAgree BIT NULL,
    RecommendedMethod NVARCHAR(30) NULL,
    RecommendedMatchedSponsor NVARCHAR(500) NULL,
    RecommendedScorePercent DECIMAL(5,2) NULL,
    FuzzyCorrect BIT NULL,
    MLCorrect BIT NULL,
    ValidationNotes NVARCHAR(MAX) NULL,
    InsertedDate DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedDate DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT CK_MatchComparison_SourceSystem
        CHECK (SourceSystem IN ('ContractsFinder', 'GtRResearch')),
    CONSTRAINT CK_MatchComparison_RecommendedMethod
        CHECK (RecommendedMethod IS NULL OR RecommendedMethod IN ('Exact', 'Fuzzy', 'ML'))
);
GO

CREATE TABLE dbo.MatchingValidation (
    MatchingValidationID BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SourceSystem NVARCHAR(50) NOT NULL,
    SourceRecordKey NVARCHAR(200) NULL,
    SourceOrganisationName NVARCHAR(500) NULL,
    MatchedSponsor NVARCHAR(500) NULL,
    MatchMethod NVARCHAR(30) NOT NULL,
    MatchingAccuracyPercent DECIMAL(5,2) NULL,
    IsCorrect BIT NULL,
    CheckedBy NVARCHAR(200) NULL,
    ValidationNotes NVARCHAR(MAX) NULL,
    InsertedDate DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedDate DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT CK_MatchingValidation_SourceSystem
        CHECK (SourceSystem IN ('ContractsFinder', 'GtRResearch')),
    CONSTRAINT CK_MatchingValidation_MatchMethod
        CHECK (MatchMethod IN ('Exact', 'Fuzzy', 'ML')),
    CONSTRAINT CK_MatchingValidation_Accuracy
        CHECK (MatchingAccuracyPercent IS NULL OR MatchingAccuracyPercent BETWEEN 0 AND 100)
);
GO

/* -----------------------------
   8. Dashboard views
   ----------------------------- */
CREATE VIEW dbo.vw_Dashboard_ContractsFinder AS
SELECT
    'Contracts Finder' AS DashboardSource,
    g.GoldContractID,
    g.SponsorKey,
    g.Contract_Title,
    g.Contract_Value,
    g.Supplier_Name,
    TRY_CONVERT(date, g.Award_Date) AS Award_Date_Converted,
    g.Award_Date,
    g.matched_sponsor,
    COALESCE(g.Town_City, d.TownCity) AS TownCity,
    COALESCE(g.Route, d.SponsorRoute) AS SponsorRoute,
    g.MatchMethod,
    g.MatchingAccuracyPercent,
    g.InsertedDate,
    g.ModifiedDate
FROM dbo.Gold_ContractsFinder g
LEFT JOIN dbo.DimSponsorOrganisation d
    ON g.SponsorKey = d.SponsorKey;
GO

CREATE VIEW dbo.vw_Dashboard_GtRResearch AS
SELECT
    'Gateway to Research' AS DashboardSource,
    g.GoldGtrID,
    g.SponsorKey,
    g.project_id,
    g.title AS ProjectTitle,
    g.status AS ProjectStatus,
    TRY_CONVERT(date, g.start_date) AS Start_Date_Converted,
    g.start_date,
    g.lead_organisation,
    g.matched_sponsor,
    d.TownCity,
    d.SponsorRoute,
    g.MatchMethod,
    g.MatchingAccuracyPercent,
    g.InsertedDate,
    g.ModifiedDate
FROM dbo.Gold_GtRResearch g
LEFT JOIN dbo.DimSponsorOrganisation d
    ON g.SponsorKey = d.SponsorKey;
GO

CREATE VIEW dbo.vw_Dashboard_Overview AS
SELECT
    'Contract' AS EvidenceType,
    'Contracts Finder' AS DashboardSource,
    CAST(GoldContractID AS NVARCHAR(100)) AS EvidenceID,
    Supplier_Name AS SourceOrganisation,
    matched_sponsor,
    Contract_Title AS EvidenceTitle,
    Award_Date AS EvidenceDate,
    Contract_Value AS EvidenceValue,
    TownCity,
    SponsorRoute,
    MatchMethod,
    MatchingAccuracyPercent,
    InsertedDate,
    ModifiedDate
FROM dbo.vw_Dashboard_ContractsFinder
UNION ALL
SELECT
    'Research' AS EvidenceType,
    'Gateway to Research' AS DashboardSource,
    CAST(project_id AS NVARCHAR(100)) AS EvidenceID,
    lead_organisation AS SourceOrganisation,
    matched_sponsor,
    ProjectTitle AS EvidenceTitle,
    start_date AS EvidenceDate,
    NULL AS EvidenceValue,
    TownCity,
    SponsorRoute,
    MatchMethod,
    MatchingAccuracyPercent,
    InsertedDate,
    ModifiedDate
FROM dbo.vw_Dashboard_GtRResearch;
GO

CREATE VIEW dbo.vw_MatchingComparisonSummary AS
SELECT
    SourceSystem,
    COUNT(*) AS TotalCompared,
    SUM(CASE WHEN FuzzyMatchedSponsor IS NOT NULL THEN 1 ELSE 0 END) AS FuzzyMatchesFound,
    SUM(CASE WHEN MLMatchedSponsor IS NOT NULL THEN 1 ELSE 0 END) AS MLMatchesFound,
    SUM(CASE WHEN MethodsAgree = 1 THEN 1 ELSE 0 END) AS MethodsAgreeCount,
    CAST(100.0 * SUM(CASE WHEN MethodsAgree = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0) AS DECIMAL(5,2)) AS AgreementRatePercent,
    CAST(AVG(FuzzyScorePercent) AS DECIMAL(5,2)) AS AverageFuzzyScorePercent,
    CAST(AVG(MLScorePercent) AS DECIMAL(5,2)) AS AverageMLScorePercent,
    CAST(100.0 * SUM(CASE WHEN FuzzyCorrect = 1 THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN FuzzyCorrect IS NOT NULL THEN 1 ELSE 0 END),0) AS DECIMAL(5,2)) AS FuzzyManualPrecisionPercent,
    CAST(100.0 * SUM(CASE WHEN MLCorrect = 1 THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN MLCorrect IS NOT NULL THEN 1 ELSE 0 END),0) AS DECIMAL(5,2)) AS MLManualPrecisionPercent
FROM dbo.MatchComparison
GROUP BY SourceSystem;
GO

select * from vw_Dashboard_Overview
select * from vw_MatchingComparisonSummary
