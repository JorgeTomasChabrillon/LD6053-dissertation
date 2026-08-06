SELECT COUNT(*) AS OverviewRows
FROM dbo.vw_Dashboard_Overview;

SELECT COUNT(*) AS ContractsFinderRows
FROM dbo.vw_Dashboard_ContractsFinder;

SELECT COUNT(*) AS GtRRows
FROM dbo.vw_Dashboard_GtRResearch;

SELECT *
FROM dbo.vw_MatchingComparisonSummary;

SELECT *
FROM dbo.vw_AutomatedValidationEvidence;

SELECT TOP 20 *
FROM dbo.DataLoadAudit;
