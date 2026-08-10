USE [master]
GO
/****** Object:  Database [jorgetomaschabrillon_LD6053dissertation]    Script Date: 10/08/2026 14:45:32 ******/
CREATE DATABASE [jorgetomaschabrillon_LD6053dissertation]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'jorgetomaschabrillon_LD6053dissertation', FILENAME = N'D:\sql-freeasphost-user-dbs\jorgetomaschabrillon_LD6053dissertation.mdf' , SIZE = 15360KB , MAXSIZE = 51200KB , FILEGROWTH = 5120KB )
 LOG ON 
( NAME = N'jorgetomaschabrillon_LD6053dissertation_log', FILENAME = N'D:\sql-freeasphost-user-dbs\jorgetomaschabrillon_LD6053dissertation.ldf' , SIZE = 25600KB , MAXSIZE = 25600KB , FILEGROWTH = 5120KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [jorgetomaschabrillon_LD6053dissertation].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET ARITHABORT OFF 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET  ENABLE_BROKER 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET RECOVERY FULL 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET  MULTI_USER 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET DB_CHAINING OFF 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET QUERY_STORE = ON
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [jorgetomaschabrillon_LD6053dissertation]
GO
/****** Object:  Table [dbo].[DimSponsorOrganisation]    Script Date: 10/08/2026 14:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimSponsorOrganisation](
	[SponsorKey] [bigint] IDENTITY(1,1) NOT NULL,
	[MatchedSponsor] [nvarchar](500) NULL,
	[TownCity] [nvarchar](255) NULL,
	[SponsorRoute] [nvarchar](1000) NULL,
	[InsertedDate] [datetime2](0) NOT NULL,
	[ModifiedDate] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SponsorKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[MatchedSponsor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Gold_ContractsFinder]    Script Date: 10/08/2026 14:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Gold_ContractsFinder](
	[GoldContractID] [bigint] IDENTITY(1,1) NOT NULL,
	[SponsorKey] [bigint] NULL,
	[Contract_Title] [nvarchar](max) NULL,
	[Contract_Value] [decimal](18, 2) NULL,
	[Supplier_Name] [nvarchar](500) NULL,
	[Award_Date] [nvarchar](50) NULL,
	[matched_sponsor] [nvarchar](500) NULL,
	[Town_City] [nvarchar](255) NULL,
	[Route] [nvarchar](1000) NULL,
	[MatchMethod] [nvarchar](100) NULL,
	[MatchingAccuracyPercent] [decimal](5, 2) NULL,
	[InsertedDate] [datetime2](0) NOT NULL,
	[ModifiedDate] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[GoldContractID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_Dashboard_ContractsFinder]    Script Date: 10/08/2026 14:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* ============================================================
   1. CONTRACTS FINDER DASHBOARD
   Show ONLY the most recent Contracts Finder insertion date
   ============================================================ */

CREATE VIEW [dbo].[vw_Dashboard_ContractsFinder] AS

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
    ON g.SponsorKey = d.SponsorKey

WHERE CAST(g.InsertedDate AS DATE) =
(
    SELECT CAST(MAX(InsertedDate) AS DATE)
    FROM dbo.Gold_ContractsFinder
);
GO
/****** Object:  Table [dbo].[Gold_GtRResearch]    Script Date: 10/08/2026 14:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Gold_GtRResearch](
	[GoldGtrID] [bigint] IDENTITY(1,1) NOT NULL,
	[SponsorKey] [bigint] NULL,
	[project_id] [nvarchar](100) NULL,
	[title] [nvarchar](max) NULL,
	[status] [nvarchar](100) NULL,
	[start_date] [nvarchar](50) NULL,
	[lead_organisation] [nvarchar](500) NULL,
	[matched_sponsor] [nvarchar](500) NULL,
	[MatchMethod] [nvarchar](100) NULL,
	[MatchingAccuracyPercent] [decimal](5, 2) NULL,
	[InsertedDate] [datetime2](0) NOT NULL,
	[ModifiedDate] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[GoldGtrID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_Dashboard_GtRResearch]    Script Date: 10/08/2026 14:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/* ============================================================
   2. GATEWAY TO RESEARCH DASHBOARD
   Show ONLY the most recent GtR insertion date
   ============================================================ */

CREATE VIEW [dbo].[vw_Dashboard_GtRResearch] AS

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
    ON g.SponsorKey = d.SponsorKey

WHERE CAST(g.InsertedDate AS DATE) =
(
    SELECT CAST(MAX(InsertedDate) AS DATE)
    FROM dbo.Gold_GtRResearch
);
GO
/****** Object:  View [dbo].[vw_Dashboard_Overview]    Script Date: 10/08/2026 14:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/* ============================================================
   3. OVERVIEW
   Uses the two latest-snapshot views above
   ============================================================ */

CREATE VIEW [dbo].[vw_Dashboard_Overview] AS

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
/****** Object:  Table [dbo].[MatchComparison]    Script Date: 10/08/2026 14:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MatchComparison](
	[MatchComparisonID] [bigint] IDENTITY(1,1) NOT NULL,
	[SourceSystem] [nvarchar](50) NULL,
	[SourceRecordKey] [nvarchar](255) NULL,
	[SourceOrganisationName] [nvarchar](500) NULL,
	[FuzzyMatchedSponsor] [nvarchar](500) NULL,
	[FuzzyScorePercent] [decimal](5, 2) NULL,
	[MLMatchedSponsor] [nvarchar](500) NULL,
	[MLScorePercent] [decimal](5, 2) NULL,
	[MethodsAgree] [bit] NULL,
	[RecommendedMethod] [nvarchar](100) NULL,
	[RecommendedMatchedSponsor] [nvarchar](500) NULL,
	[RecommendedScorePercent] [decimal](5, 2) NULL,
	[FuzzyCorrect] [bit] NULL,
	[MLCorrect] [bit] NULL,
	[ValidationNotes] [nvarchar](max) NULL,
	[InsertedDate] [datetime2](0) NOT NULL,
	[ModifiedDate] [datetime2](0) NOT NULL,
	[AutoValidationStatus] [nvarchar](100) NULL,
	[AutoValidationReason] [nvarchar](500) NULL,
	[IsDashboardEligible] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MatchComparisonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_MatchingComparisonSummary]    Script Date: 10/08/2026 14:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/* ============================================================
   DATA QUALITY VIEW 2
   Latest insertion date only
   ============================================================ */

CREATE VIEW [dbo].[vw_MatchingComparisonSummary] AS

SELECT
    SourceSystem,

    COUNT(*) AS TotalCompared,

    SUM(
        CASE
            WHEN FuzzyMatchedSponsor IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS FuzzyMatchesFound,

    SUM(
        CASE
            WHEN MLMatchedSponsor IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS MLMatchesFound,

    SUM(
        CASE
            WHEN MethodsAgree = 1 THEN 1
            ELSE 0
        END
    ) AS MethodsAgreeCount,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN MethodsAgree = 1 THEN 1
                ELSE 0
            END
        )
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS AgreementRatePercent,

    CAST(
        AVG(FuzzyScorePercent)
        AS DECIMAL(5,2)
    ) AS AverageFuzzyScorePercent,

    CAST(
        AVG(MLScorePercent)
        AS DECIMAL(5,2)
    ) AS AverageMLScorePercent,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN FuzzyCorrect = 1 THEN 1
                ELSE 0
            END
        )
        /
        NULLIF(
            SUM(
                CASE
                    WHEN FuzzyCorrect IS NOT NULL THEN 1
                    ELSE 0
                END
            ),
            0
        )
        AS DECIMAL(5,2)
    ) AS FuzzyManualPrecisionPercent,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN MLCorrect = 1 THEN 1
                ELSE 0
            END
        )
        /
        NULLIF(
            SUM(
                CASE
                    WHEN MLCorrect IS NOT NULL THEN 1
                    ELSE 0
                END
            ),
            0
        )
        AS DECIMAL(5,2)
    ) AS MLManualPrecisionPercent

FROM dbo.MatchComparison

WHERE CAST(InsertedDate AS DATE) =
(
    SELECT CAST(MAX(InsertedDate) AS DATE)
    FROM dbo.MatchComparison
)

GROUP BY
    SourceSystem;
GO
/****** Object:  View [dbo].[vw_AutomatedValidationEvidence]    Script Date: 10/08/2026 14:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* ============================================================
   DATA QUALITY VIEW 1
   Latest insertion date only
   ============================================================ */

CREATE VIEW [dbo].[vw_AutomatedValidationEvidence] AS

SELECT
    SourceSystem,
    AutoValidationStatus,

    COUNT(*) AS TotalRecords,

    SUM(
        CASE
            WHEN IsDashboardEligible = 1 THEN 1
            ELSE 0
        END
    ) AS DashboardEligibleRecords,

    AVG(
        CAST(FuzzyScorePercent AS FLOAT)
    ) AS AverageFuzzyScorePercent,

    AVG(
        CAST(MLScorePercent AS FLOAT)
    ) AS AverageMLScorePercent,

    SUM(
        CASE
            WHEN MethodsAgree = 1 THEN 1
            ELSE 0
        END
    ) AS MethodsAgreeRecords,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN MethodsAgree = 1 THEN 1
                ELSE 0
            END
        )
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS MethodsAgreePercent

FROM dbo.MatchComparison

WHERE CAST(InsertedDate AS DATE) =
(
    SELECT CAST(MAX(InsertedDate) AS DATE)
    FROM dbo.MatchComparison
)

GROUP BY
    SourceSystem,
    AutoValidationStatus;
GO
/****** Object:  Table [dbo].[DataLoadAudit]    Script Date: 10/08/2026 14:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataLoadAudit](
	[DataLoadAuditID] [bigint] IDENTITY(1,1) NOT NULL,
	[RunDate] [char](8) NULL,
	[FileName] [nvarchar](300) NOT NULL,
	[FilePath] [nvarchar](1000) NULL,
	[SourceSystem] [nvarchar](50) NOT NULL,
	[LayerName] [nvarchar](30) NOT NULL,
	[MatchMethod] [nvarchar](30) NULL,
	[RowsLoaded] [bigint] NOT NULL,
	[InsertedDate] [datetime2](0) NOT NULL,
	[ModifiedDate] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DataLoadAuditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataLoadAudit] ADD  DEFAULT (sysutcdatetime()) FOR [InsertedDate]
GO
ALTER TABLE [dbo].[DataLoadAudit] ADD  DEFAULT (sysutcdatetime()) FOR [ModifiedDate]
GO
ALTER TABLE [dbo].[DimSponsorOrganisation] ADD  DEFAULT (sysutcdatetime()) FOR [InsertedDate]
GO
ALTER TABLE [dbo].[DimSponsorOrganisation] ADD  DEFAULT (sysutcdatetime()) FOR [ModifiedDate]
GO
ALTER TABLE [dbo].[Gold_ContractsFinder] ADD  DEFAULT (sysutcdatetime()) FOR [InsertedDate]
GO
ALTER TABLE [dbo].[Gold_ContractsFinder] ADD  DEFAULT (sysutcdatetime()) FOR [ModifiedDate]
GO
ALTER TABLE [dbo].[Gold_GtRResearch] ADD  DEFAULT (sysutcdatetime()) FOR [InsertedDate]
GO
ALTER TABLE [dbo].[Gold_GtRResearch] ADD  DEFAULT (sysutcdatetime()) FOR [ModifiedDate]
GO
ALTER TABLE [dbo].[MatchComparison] ADD  DEFAULT (sysutcdatetime()) FOR [InsertedDate]
GO
ALTER TABLE [dbo].[MatchComparison] ADD  DEFAULT (sysutcdatetime()) FOR [ModifiedDate]
GO
ALTER TABLE [dbo].[Gold_ContractsFinder]  WITH CHECK ADD  CONSTRAINT [FK_GoldContractsFinder_Sponsor] FOREIGN KEY([SponsorKey])
REFERENCES [dbo].[DimSponsorOrganisation] ([SponsorKey])
GO
ALTER TABLE [dbo].[Gold_ContractsFinder] CHECK CONSTRAINT [FK_GoldContractsFinder_Sponsor]
GO
ALTER TABLE [dbo].[Gold_GtRResearch]  WITH CHECK ADD  CONSTRAINT [FK_GoldGtRResearch_Sponsor] FOREIGN KEY([SponsorKey])
REFERENCES [dbo].[DimSponsorOrganisation] ([SponsorKey])
GO
ALTER TABLE [dbo].[Gold_GtRResearch] CHECK CONSTRAINT [FK_GoldGtRResearch_Sponsor]
GO
ALTER TABLE [dbo].[DataLoadAudit]  WITH CHECK ADD  CONSTRAINT [CK_DataLoadAudit_LayerName] CHECK  (([LayerName]='Comparison' OR [LayerName]='Gold' OR [LayerName]='Silver' OR [LayerName]='Bronze' OR [LayerName]='Sponsor'))
GO
ALTER TABLE [dbo].[DataLoadAudit] CHECK CONSTRAINT [CK_DataLoadAudit_LayerName]
GO
ALTER TABLE [dbo].[DataLoadAudit]  WITH CHECK ADD  CONSTRAINT [CK_DataLoadAudit_MatchMethod] CHECK  (([MatchMethod] IS NULL OR ([MatchMethod]='ML' OR [MatchMethod]='Fuzzy')))
GO
ALTER TABLE [dbo].[DataLoadAudit] CHECK CONSTRAINT [CK_DataLoadAudit_MatchMethod]
GO
ALTER TABLE [dbo].[DataLoadAudit]  WITH CHECK ADD  CONSTRAINT [CK_DataLoadAudit_SourceSystem] CHECK  (([SourceSystem]='HomeOfficeSponsorRegister' OR [SourceSystem]='GtRResearch' OR [SourceSystem]='ContractsFinder'))
GO
ALTER TABLE [dbo].[DataLoadAudit] CHECK CONSTRAINT [CK_DataLoadAudit_SourceSystem]
GO
ALTER TABLE [dbo].[Gold_ContractsFinder]  WITH CHECK ADD  CONSTRAINT [CK_GoldContractsFinder_Accuracy] CHECK  (([MatchingAccuracyPercent] IS NULL OR [MatchingAccuracyPercent]>=(0) AND [MatchingAccuracyPercent]<=(100)))
GO
ALTER TABLE [dbo].[Gold_ContractsFinder] CHECK CONSTRAINT [CK_GoldContractsFinder_Accuracy]
GO
ALTER TABLE [dbo].[Gold_ContractsFinder]  WITH CHECK ADD  CONSTRAINT [CK_GoldContractsFinder_MatchMethod] CHECK  (([MatchMethod]='ML' OR [MatchMethod]='Fuzzy' OR [MatchMethod]='Exact'))
GO
ALTER TABLE [dbo].[Gold_ContractsFinder] CHECK CONSTRAINT [CK_GoldContractsFinder_MatchMethod]
GO
ALTER TABLE [dbo].[Gold_GtRResearch]  WITH CHECK ADD  CONSTRAINT [CK_GoldGtRResearch_Accuracy] CHECK  (([MatchingAccuracyPercent] IS NULL OR [MatchingAccuracyPercent]>=(0) AND [MatchingAccuracyPercent]<=(100)))
GO
ALTER TABLE [dbo].[Gold_GtRResearch] CHECK CONSTRAINT [CK_GoldGtRResearch_Accuracy]
GO
ALTER TABLE [dbo].[Gold_GtRResearch]  WITH CHECK ADD  CONSTRAINT [CK_GoldGtRResearch_MatchMethod] CHECK  (([MatchMethod]='ML' OR [MatchMethod]='Fuzzy' OR [MatchMethod]='Exact'))
GO
ALTER TABLE [dbo].[Gold_GtRResearch] CHECK CONSTRAINT [CK_GoldGtRResearch_MatchMethod]
GO
ALTER TABLE [dbo].[MatchComparison]  WITH CHECK ADD  CONSTRAINT [CK_MatchComparison_FuzzyScore] CHECK  (([FuzzyScorePercent] IS NULL OR [FuzzyScorePercent]>=(0) AND [FuzzyScorePercent]<=(100)))
GO
ALTER TABLE [dbo].[MatchComparison] CHECK CONSTRAINT [CK_MatchComparison_FuzzyScore]
GO
ALTER TABLE [dbo].[MatchComparison]  WITH CHECK ADD  CONSTRAINT [CK_MatchComparison_MLScore] CHECK  (([MLScorePercent] IS NULL OR [MLScorePercent]>=(0) AND [MLScorePercent]<=(100)))
GO
ALTER TABLE [dbo].[MatchComparison] CHECK CONSTRAINT [CK_MatchComparison_MLScore]
GO
ALTER TABLE [dbo].[MatchComparison]  WITH CHECK ADD  CONSTRAINT [CK_MatchComparison_RecommendedMethod] CHECK  (([RecommendedMethod] IS NULL OR ([RecommendedMethod]='ML' OR [RecommendedMethod]='Fuzzy' OR [RecommendedMethod]='Exact')))
GO
ALTER TABLE [dbo].[MatchComparison] CHECK CONSTRAINT [CK_MatchComparison_RecommendedMethod]
GO
ALTER TABLE [dbo].[MatchComparison]  WITH CHECK ADD  CONSTRAINT [CK_MatchComparison_RecommendedScore] CHECK  (([RecommendedScorePercent] IS NULL OR [RecommendedScorePercent]>=(0) AND [RecommendedScorePercent]<=(100)))
GO
ALTER TABLE [dbo].[MatchComparison] CHECK CONSTRAINT [CK_MatchComparison_RecommendedScore]
GO
ALTER TABLE [dbo].[MatchComparison]  WITH CHECK ADD  CONSTRAINT [CK_MatchComparison_SourceSystem] CHECK  (([SourceSystem]='GtRResearch' OR [SourceSystem]='ContractsFinder'))
GO
ALTER TABLE [dbo].[MatchComparison] CHECK CONSTRAINT [CK_MatchComparison_SourceSystem]
GO
USE [master]
GO
ALTER DATABASE [jorgetomaschabrillon_LD6053dissertation] SET  READ_WRITE 
GO
