
USE [jorgetomaschabrillon_LD6053dissertation]
GO

/****** Object:  Table [dbo].[GtrProject]    Script Date: 25/06/2026 11:33:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GtrProject](
	[ProjectID] [bigint] IDENTITY(1,1) NOT NULL,
	[SponsorID] [nvarchar](500) NOT NULL,
	[ProjectTitle] [nvarchar](500) NOT NULL,
	[ProjectStatus] [nvarchar](50) NOT NULL,
	[StartDate] [date] NULL,
	[LeadOrganisation] [nvarchar](300) NOT NULL,
 CONSTRAINT [PK_GtrProject] PRIMARY KEY CLUSTERED 
(
	[ProjectID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


CREATE TABLE [dbo].[ContractsFinderAward](
	[ContractAwardID] [bigint] IDENTITY(1,1) NOT NULL,
	[SponsorID] [int] NOT NULL,
	[ContractTitle] [nvarchar](300) NOT NULL,
	[ContractValue] [decimal](18, 2) NOT NULL,
	[SupplierName] [nvarchar](200) NOT NULL,
	[AwardDate] [date] NOT NULL,
 CONSTRAINT [PK_ContractsFinderAward] PRIMARY KEY CLUSTERED 
(
	[ContractAwardID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO




CREATE TABLE [dbo].[PossibleJobs](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[PossibleJob] [nvarchar](300) NOT NULL,
	[ContractID] [bigint] NULL,
 CONSTRAINT [PK_PossibleJobs] PRIMARY KEY CLUSTERED (
	[ID] ASC)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [FK_PossibleJobs_ContractsFinderAward] FOREIGN KEY ([ContractID]) 
    REFERENCES [dbo].[ContractsFinderAward] ([ID])
) ON [PRIMARY]
GO

-- Main View for Companies and Projects
go
CREATE VIEW vw_MainCompanies AS
SELECT 
    ID,
	SupplierName AS CompanyName, 
    contractTitle AS ProjectTitle 
FROM ContractsFinderAward
UNION
SELECT 
	ID,
    LeadOrganisation AS CompanyName, 
    ProjectTitle AS ProjectTitle 
FROM GtrProject;

-- Placeholder View for Possible Jobs
go

CREATE VIEW vw_PossibleJobs AS
SELECT 
    a.ID,a.PossibleJob,a.ContractID
	from PossibleJobs a
	inner join ContractsFinderAward b on b.ID=a.ContractID


-- Placeholder View for Possible Skills
go
CREATE VIEW vw_PossibleSkills AS
SELECT 
    'Placeholder Job' AS Predicted_Role, 
    'Placeholder Skill' AS Predicted_Skills;

-- Placeholder View for Filters (1, 2, 3)
go
CREATE VIEW vw_Filters AS
SELECT 
    'Placeholder Company' AS CompanyName, 
    'Value 1' AS Filter_1, 
    'Value 2' AS Filter_2, 
    'Value 3' AS Filter_3;