USE jorgetomaschabrillon_LD6053dissertation;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    ------------------------------------------------------------
    -- AUTOMATIC TODAY WINDOW
    -- From today at 00:00:00
    -- Up to, but not including, tomorrow at 00:00:00
    ------------------------------------------------------------

    DECLARE @StartDate DATETIME2(0) = CAST(CAST(GETDATE() AS DATE) AS DATETIME2(0));
    --set @StartDate=cast ('2026-08-07' as datetime2(0)) hardcode date
    DECLARE @EndDate DATETIME2(0) = DATEADD(DAY, 1, @StartDate);

    SELECT @StartDate AS DeleteFrom, @EndDate AS DeleteUntil;

    ------------------------------------------------------------
    -- PREVIEW: SHOW WHAT WILL BE DELETED
    ------------------------------------------------------------

    SELECT 'Gold_ContractsFinder' AS TableName, COUNT(*) AS RowsToDelete
    FROM dbo.Gold_ContractsFinder
    WHERE InsertedDate >= @StartDate
      AND InsertedDate < @EndDate

    UNION ALL

    SELECT 'Gold_GtRResearch', COUNT(*)
    FROM dbo.Gold_GtRResearch
    WHERE InsertedDate >= @StartDate
      AND InsertedDate < @EndDate

    UNION ALL

    SELECT 'MatchComparison', COUNT(*)
    FROM dbo.MatchComparison
    WHERE InsertedDate >= @StartDate
      AND InsertedDate < @EndDate

    UNION ALL

    SELECT 'DataLoadAudit', COUNT(*)
    FROM dbo.DataLoadAudit
    WHERE InsertedDate >= @StartDate
      AND InsertedDate < @EndDate

    UNION ALL

    SELECT 'DimSponsorOrganisation', COUNT(*)
    FROM dbo.DimSponsorOrganisation
    WHERE InsertedDate >= @StartDate
      AND InsertedDate < @EndDate;

    ------------------------------------------------------------
    -- DELETE INSIDE A TRANSACTION
    ------------------------------------------------------------

    BEGIN TRANSACTION;

    DELETE FROM dbo.Gold_ContractsFinder
    WHERE InsertedDate >= @StartDate
      AND InsertedDate < @EndDate;

    PRINT CONCAT('Gold_ContractsFinder deleted: ', @@ROWCOUNT);

    DELETE FROM dbo.Gold_GtRResearch
    WHERE InsertedDate >= @StartDate
      AND InsertedDate < @EndDate;

    PRINT CONCAT('Gold_GtRResearch deleted: ', @@ROWCOUNT);

    DELETE FROM dbo.MatchComparison
    WHERE InsertedDate >= @StartDate
      AND InsertedDate < @EndDate;

    PRINT CONCAT('MatchComparison deleted: ', @@ROWCOUNT);

    DELETE FROM dbo.DataLoadAudit
    WHERE InsertedDate >= @StartDate
      AND InsertedDate < @EndDate;

    PRINT CONCAT('DataLoadAudit deleted: ', @@ROWCOUNT);

    ------------------------------------------------------------
    -- DELETE TODAY'S SPONSORS ONLY IF NOTHING STILL REFERENCES THEM
    ------------------------------------------------------------

    DELETE sponsor
    FROM dbo.DimSponsorOrganisation AS sponsor
    WHERE sponsor.InsertedDate >= @StartDate
      AND sponsor.InsertedDate < @EndDate
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.Gold_ContractsFinder AS contract
          WHERE contract.SponsorKey = sponsor.SponsorKey
      )
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.Gold_GtRResearch AS research
          WHERE research.SponsorKey = sponsor.SponsorKey
      );

    PRINT CONCAT('DimSponsorOrganisation deleted: ', @@ROWCOUNT);

    ------------------------------------------------------------
    -- SAFE DEFAULT
    -- Nothing is permanently deleted while ROLLBACK is active
    ------------------------------------------------------------
     SELECT 'Gold_ContractsFinder' AS TableName, COUNT(*) AS RowsToDelete
    FROM dbo.Gold_ContractsFinder
    WHERE InsertedDate >= @StartDate
      AND InsertedDate < @EndDate

    UNION ALL

    SELECT 'Gold_GtRResearch', COUNT(*)
    FROM dbo.Gold_GtRResearch
    WHERE InsertedDate >= @StartDate
      AND InsertedDate < @EndDate

    UNION ALL

    SELECT 'MatchComparison', COUNT(*)
    FROM dbo.MatchComparison
    WHERE InsertedDate >= @StartDate
      AND InsertedDate < @EndDate

    UNION ALL

    SELECT 'DataLoadAudit', COUNT(*)
    FROM dbo.DataLoadAudit
    WHERE InsertedDate >= @StartDate
      AND InsertedDate < @EndDate

    UNION ALL

    SELECT 'DimSponsorOrganisation', COUNT(*)
    FROM dbo.DimSponsorOrganisation
    WHERE InsertedDate >= @StartDate
      AND InsertedDate < @EndDate;

    --COMMIT TRANSACTION;
    ROLLBACK TRANSACTION;

    PRINT 'TEST COMPLETE: all changes were rolled back.';
    PRINT 'Nothing was permanently deleted.';

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage;

END CATCH;
GO

