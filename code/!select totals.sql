SET NOCOUNT ON;

DECLARE @LatestSnapshotDate DATE;

SELECT
    @LatestSnapshotDate = MAX(CONVERT(DATE, InsertedDate))
FROM dbo.MatchComparison;


/* RESULT 1: Latest snapshot date */

SELECT
    @LatestSnapshotDate AS [LatestSnapshotDate],
    DATEADD(DAY, -90, @LatestSnapshotDate)
        AS [ExpectedEarliestEvidenceDate];


/* RESULT 2: Confirm historical dates were preserved */

SELECT
    'Gold_ContractsFinder' AS [TableName],
    CONVERT(DATE, InsertedDate) AS [InsertionDate],
    COUNT(*) AS [SnapshotRows]
FROM dbo.Gold_ContractsFinder
GROUP BY CONVERT(DATE, InsertedDate)

UNION ALL

SELECT
    'Gold_GtRResearch',
    CONVERT(DATE, InsertedDate),
    COUNT(*)
FROM dbo.Gold_GtRResearch
GROUP BY CONVERT(DATE, InsertedDate)

UNION ALL

SELECT
    'MatchComparison',
    CONVERT(DATE, InsertedDate),
    COUNT(*)
FROM dbo.MatchComparison
GROUP BY CONVERT(DATE, InsertedDate)

UNION ALL

SELECT
    'DataLoadAudit',
    CONVERT(DATE, InsertedDate),
    COUNT(*)
FROM dbo.DataLoadAudit
GROUP BY CONVERT(DATE, InsertedDate)

ORDER BY
    [InsertionDate] DESC,
    [TableName];


/* RESULT 3: Current accepted dashboard evidence */

SELECT
    'ContractsFinder' AS [SourceSystem],
    COUNT(*) AS [AcceptedEvidenceRows],
    COUNT(DISTINCT SponsorKey) AS [DistinctMatchedSponsors],
    MIN(TRY_CONVERT(DATE, Award_Date)) AS [EarliestEvidenceDate],
    MAX(TRY_CONVERT(DATE, Award_Date)) AS [LatestEvidenceDate],
    SUM(
        CASE
            WHEN TRY_CONVERT(DATE, Award_Date) IS NULL
            THEN 1 ELSE 0
        END
    ) AS [InvalidOrMissingDates],
    SUM(
        CASE
            WHEN TRY_CONVERT(DATE, Award_Date)
                 < DATEADD(DAY, -90, @LatestSnapshotDate)
              OR TRY_CONVERT(DATE, Award_Date)
                 > @LatestSnapshotDate
            THEN 1 ELSE 0
        END
    ) AS [Outside90DayWindow],
    CAST(
        AVG(CAST(MatchingAccuracyPercent AS DECIMAL(18,4)))
        AS DECIMAL(10,2)
    ) AS [AverageMatchConfidence],
    MIN(MatchingAccuracyPercent) AS [MinimumMatchConfidence],
    MAX(MatchingAccuracyPercent) AS [MaximumMatchConfidence]
FROM dbo.Gold_ContractsFinder
WHERE InsertedDate >= @LatestSnapshotDate
  AND InsertedDate < DATEADD(DAY, 1, @LatestSnapshotDate)

UNION ALL

SELECT
    'GtRResearch',
    COUNT(*),
    COUNT(DISTINCT SponsorKey),
    MIN(TRY_CONVERT(DATE, start_date)),
    MAX(TRY_CONVERT(DATE, start_date)),
    SUM(
        CASE
            WHEN TRY_CONVERT(DATE, start_date) IS NULL
            THEN 1 ELSE 0
        END
    ),
    SUM(
        CASE
            WHEN TRY_CONVERT(DATE, start_date)
                 < DATEADD(DAY, -90, @LatestSnapshotDate)
              OR TRY_CONVERT(DATE, start_date)
                 > @LatestSnapshotDate
            THEN 1 ELSE 0
        END
    ),
    CAST(
        AVG(CAST(MatchingAccuracyPercent AS DECIMAL(18,4)))
        AS DECIMAL(10,2)
    ),
    MIN(MatchingAccuracyPercent),
    MAX(MatchingAccuracyPercent)
FROM dbo.Gold_GtRResearch
WHERE InsertedDate >= @LatestSnapshotDate
  AND InsertedDate < DATEADD(DAY, 1, @LatestSnapshotDate);


/* RESULT 4: Fuzzy and TF-IDF comparison totals */

SELECT
    SourceSystem,
    COUNT(*) AS [TotalCompared],
    SUM(
        CASE
            WHEN FuzzyMatchedSponsor IS NOT NULL
            THEN 1 ELSE 0
        END
    ) AS [FuzzyMatchesFound],
    SUM(
        CASE
            WHEN MLMatchedSponsor IS NOT NULL
            THEN 1 ELSE 0
        END
    ) AS [MLMatchesFound],
    SUM(
        CASE
            WHEN MethodsAgree = 1
            THEN 1 ELSE 0
        END
    ) AS [MethodsAgreeCount],
    CAST(
        100.0 *
        SUM(CASE WHEN MethodsAgree = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS [AgreementRatePercent],
    CAST(
        AVG(CAST(FuzzyScorePercent AS DECIMAL(18,4)))
        AS DECIMAL(10,2)
    ) AS [AverageFuzzyScorePercent],
    CAST(
        AVG(CAST(MLScorePercent AS DECIMAL(18,4)))
        AS DECIMAL(10,2)
    ) AS [AverageMLScorePercent]
FROM dbo.MatchComparison
WHERE InsertedDate >= @LatestSnapshotDate
  AND InsertedDate < DATEADD(DAY, 1, @LatestSnapshotDate)
GROUP BY SourceSystem
ORDER BY SourceSystem;


/* RESULT 5: Accepted and excluded organisations */

SELECT
    SourceSystem,
    AutoValidationStatus,
    COUNT(*) AS [TotalRecords],
    SUM(
        CASE
            WHEN IsDashboardEligible = 1
            THEN 1 ELSE 0
        END
    ) AS [DashboardEligibleRecords],
    SUM(
        CASE
            WHEN MethodsAgree = 1
            THEN 1 ELSE 0
        END
    ) AS [MethodsAgreeRecords],
    CAST(
        100.0 *
        SUM(CASE WHEN MethodsAgree = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS [MethodsAgreePercent],
    CAST(
        AVG(CAST(FuzzyScorePercent AS DECIMAL(18,4)))
        AS DECIMAL(10,2)
    ) AS [AverageFuzzyScorePercent],
    CAST(
        AVG(CAST(MLScorePercent AS DECIMAL(18,4)))
        AS DECIMAL(10,2)
    ) AS [AverageMLScorePercent]
FROM dbo.MatchComparison
WHERE InsertedDate >= @LatestSnapshotDate
  AND InsertedDate < DATEADD(DAY, 1, @LatestSnapshotDate)
GROUP BY
    SourceSystem,
    AutoValidationStatus
ORDER BY
    SourceSystem,
    AutoValidationStatus;


/* RESULT 6: Check for missing matching information */

SELECT
    SourceSystem,
    COUNT(*) AS [TotalRecords],
    SUM(
        CASE
            WHEN FuzzyScorePercent IS NULL
            THEN 1 ELSE 0
        END
    ) AS [MissingFuzzyScore],
    SUM(
        CASE
            WHEN MLScorePercent IS NULL
            THEN 1 ELSE 0
        END
    ) AS [MissingMLScore],
    SUM(
        CASE
            WHEN RecommendedScorePercent IS NULL
            THEN 1 ELSE 0
        END
    ) AS [MissingRecommendedScore],
    SUM(
        CASE
            WHEN SourceOrganisationName IS NULL
            THEN 1 ELSE 0
        END
    ) AS [MissingOrganisationName]
FROM dbo.MatchComparison
WHERE InsertedDate >= @LatestSnapshotDate
  AND InsertedDate < DATEADD(DAY, 1, @LatestSnapshotDate)
GROUP BY SourceSystem
ORDER BY SourceSystem;