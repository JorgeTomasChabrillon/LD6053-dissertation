USE jorgetomaschabrillon_LD6053dissertation;
GO

SELECT
    TableName,
    InsertionDate,
    COUNT(*) AS [RowCount]
FROM
(
    SELECT
        'DataLoadAudit' AS TableName,
        CAST(InsertedDate AS DATE) AS InsertionDate
    FROM dbo.DataLoadAudit

    UNION ALL

    SELECT
        'DimSponsorOrganisation',
        CAST(InsertedDate AS DATE)
    FROM dbo.DimSponsorOrganisation

    UNION ALL

    SELECT
        'Gold_ContractsFinder',
        CAST(InsertedDate AS DATE)
    FROM dbo.Gold_ContractsFinder

    UNION ALL

    SELECT
        'Gold_GtRResearch',
        CAST(InsertedDate AS DATE)
    FROM dbo.Gold_GtRResearch

    UNION ALL

    SELECT
        'MatchComparison',
        CAST(InsertedDate AS DATE)
    FROM dbo.MatchComparison
) AS AllRows

GROUP BY
    TableName,
    InsertionDate

ORDER BY
    InsertionDate DESC,
    TableName;
GO