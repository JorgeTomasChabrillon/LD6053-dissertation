USE [jorgetomaschabrillon_LD6053dissertation];
GO
/* Remove tables in foreign-key dependency order when re-running the script. */
DROP TABLE IF EXISTS dbo.ContractsFinderAward;
DROP TABLE IF EXISTS dbo.GtrProject;
DROP TABLE IF EXISTS dbo.SponsorOrganisation;
GO

/* Shared dimension table: one record per matched Sponsor Register organisation. */
CREATE TABLE dbo.SponsorOrganisation
(
    SponsorID       INT IDENTITY(1,1) NOT NULL,
    SponsorName     NVARCHAR(200) NOT NULL,
    TownCity        NVARCHAR(100) NULL,
    SponsorRoutes   NVARCHAR(300) NULL,

    CONSTRAINT PK_SponsorOrganisation
        PRIMARY KEY (SponsorID),

    CONSTRAINT UQ_SponsorOrganisation_SponsorName
        UNIQUE (SponsorName)
);
GO

/* Contracts Finder Gold data. ContractAwardID is generated because the CSV has no ID column. */
CREATE TABLE dbo.ContractsFinderAward
(
    ContractAwardID BIGINT IDENTITY(1,1) NOT NULL,
    SponsorID       INT NOT NULL,
    ContractTitle   NVARCHAR(300) NOT NULL,
    ContractValue   DECIMAL(18,2) NOT NULL,
    SupplierName    NVARCHAR(200) NOT NULL,
    AwardDate       DATE NOT NULL,

    CONSTRAINT PK_ContractsFinderAward
        PRIMARY KEY (ContractAwardID),

    CONSTRAINT FK_ContractsFinderAward_SponsorOrganisation
        FOREIGN KEY (SponsorID)
        REFERENCES dbo.SponsorOrganisation (SponsorID),

    CONSTRAINT CK_ContractsFinderAward_ContractValue
        CHECK (ContractValue >= 0)
);
GO

/* Gateway to Research Gold data. project_id values are UUIDs, so UNIQUEIDENTIFIER is appropriate. */
CREATE TABLE dbo.GtrProject
(
    ProjectID           UNIQUEIDENTIFIER NOT NULL,
    SponsorID           INT NOT NULL,
    ProjectTitle        NVARCHAR(500) NOT NULL,
    ProjectStatus       NVARCHAR(50) NOT NULL,
    StartDate           DATE NULL,
    LeadOrganisation    NVARCHAR(300) NOT NULL,

    CONSTRAINT PK_GtrProject
        PRIMARY KEY (ProjectID),

    CONSTRAINT FK_GtrProject_SponsorOrganisation
        FOREIGN KEY (SponsorID)
        REFERENCES dbo.SponsorOrganisation (SponsorID)
);
GO

/* Helpful indexes for filtering and joins. */
CREATE INDEX IX_ContractsFinderAward_SponsorID
    ON dbo.ContractsFinderAward (SponsorID);

CREATE INDEX IX_ContractsFinderAward_AwardDate
    ON dbo.ContractsFinderAward (AwardDate);

CREATE INDEX IX_GtrProject_SponsorID
    ON dbo.GtrProject (SponsorID);

CREATE INDEX IX_GtrProject_ProjectStatus
    ON dbo.GtrProject (ProjectStatus);
GO
