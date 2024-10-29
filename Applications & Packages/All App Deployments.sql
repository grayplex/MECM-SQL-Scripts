SET NOCOUNT ON
SET STATISTICS TIME ON
SET STATISTICS IO ON
IF OBJECT_ID('tempdb..#UniqueUsers') IS NOT NULL DROP TABLE #UniqueUsers
SELECT
    U2.ResourceID,
    U1.UserID,
    U2.Unique_User_Name0
INTO #UniqueUsers
FROM
    v_Users AS U1
    INNER JOIN v_R_User AS U2
        ON U2.SID0 = U1.UserSID
CREATE NONCLUSTERED INDEX IX_UniqueUsers_ResourceID ON #UniqueUsers (ResourceID)
CREATE NONCLUSTERED INDEX IX_UniqueUsers_UserID ON #UniqueUsers (UserID);

IF OBJECT_ID('tempdb..#UniqueSystems') IS NOT NULL DROP TABLE #UniqueSystems
SELECT
    Name0,
    ResourceID
INTO #UniqueSystems
FROM
    v_R_System
CREATE NONCLUSTERED INDEX IX_UniqueSystems_ResourceID ON #UniqueSystems (ResourceID);

IF OBJECT_ID('tempdb..#CollectionMembership') IS NOT NULL DROP TABLE #CollectionMembership
SELECT
    ResourceID,
    CollectionID
INTO #CollectionMembership
FROM
    v_FullCollectionMembership
WHERE
    1=1
    -- AND CollectionID != 'Testing collection ID'
CREATE NONCLUSTERED INDEX IX_CollectionMembership_ResourceID ON #CollectionMembership (ResourceID)
CREATE NONCLUSTERED INDEX IX_CollectionMembership_CollectionID ON #CollectionMembership (CollectionID);

WITH Apps AS (
-- Handles Applications, Application Groups, Baselines, and Configuration Policies
SELECT
    DS.ModelID AS 'ModelID',
    NULL AS 'PackageID',
    CIAsn.AssignmentID AS 'AssignmentID',
    NULL AS 'DeploymentID',
    DS.FeatureType,
    CASE
        WHEN DS.FeatureType = 1 THEN 'Application'
        WHEN DS.FeatureType = 2 THEN 'Program'
        WHEN DS.FeatureType = 3 THEN 'Mobile Program'
        WHEN DS.FeatureType = 4 THEN 'Script'
        WHEN DS.FeatureType = 5 THEN 'Update'
        WHEN DS.FeatureType = 6 THEN 'Baseline'
        WHEN DS.FeatureType = 7 THEN 'Task Sequence'
        WHEN DS.FeatureType = 8 THEN 'Content Distribution'
        WHEN DS.FeatureType = 9 THEN 'Distribution Point Group'
        WHEN DS.FeatureType = 10 THEN 'Distribution Health'
        WHEN DS.FeatureType = 11 THEN 'Configuration Policy'
        WHEN DS.FeatureType = 12 THEN 'Application Group'
        WHEN DS.FeatureType = 20 THEN 'Abstract Configuration Item'
        ELSE CAST(DS.FeatureType AS varchar(2))
    END AS 'Type',
    CI.LastModifiedBy AS 'Last Modified By',
    CIStatus.ResourceID AS 'MachineID',
    S1.Name0 AS 'Machine Name',
    U1.UserID AS 'User ID',
    U1.Unique_User_Name0 AS 'User Name',
    CIAsn.AssignmentName AS 'AssignmentName',
    CIAsn.CollectionID AS 'CollectionID',
    CIAsn.CollectionName AS 'CollectionName',
    CASE
        WHEN len (DS.SoftwareName) > 0 THEN DS.SoftwareName
        ELSE CASE
            WHEN CHARINDEX (DS.CollectionName, CIAsn.AssignmentName) = 0 THEN CIAsn.AssignmentName
            WHEN CHARINDEX (concat (DS.CollectionName, '~@'),concat (CIAsn.AssignmentName, '~@')) < 1 THEN substring(
                CIAsn.AssignmentName,
                0,
                CHARINDEX (concat (DS.CollectionName, '~@'),concat (CIAsn.AssignmentName, '~@'),2) - 0
            )
            WHEN CHARINDEX (concat (DS.CollectionName, '~@'),concat (CIAsn.AssignmentName, '~@')) >= 1 THEN substring(
                CIAsn.AssignmentName,
                0,
                CHARINDEX (concat (DS.CollectionName, '~@'),concat (CIAsn.AssignmentName, '~@'),2) - 1
            )
            ELSE CIAsn.AssignmentName
        END
    END AS 'Software',
    CIStatus.CIType_ID AS 'CIType_ID',
    CASE 
        WHEN dbo.Fn_getappstate(CIStatus.ComplianceState, CIStatus.EnforcementState, CIAsn.OfferTypeID, 1, CIStatus.DesiredState, CIStatus.IsApplicable) < 2000 THEN 'Success'
        WHEN dbo.Fn_getappstate(CIStatus.ComplianceState, CIStatus.EnforcementState, CIAsn.OfferTypeID, 1, CIStatus.DesiredState, CIStatus.IsApplicable) BETWEEN 1999 AND 3000 THEN 'In Progress'
        WHEN dbo.Fn_getappstate(CIStatus.ComplianceState, CIStatus.EnforcementState, CIAsn.OfferTypeID, 1, CIStatus.DesiredState, CIStatus.IsApplicable) BETWEEN 2999 AND 4000 THEN 'Requirements Not Met'
        WHEN dbo.Fn_getappstate(CIStatus.ComplianceState, CIStatus.EnforcementState, CIAsn.OfferTypeID, 1, CIStatus.DesiredState, CIStatus.IsApplicable) BETWEEN 3999 AND 5000 THEN 'Unknown'
        WHEN dbo.Fn_getappstate(CIStatus.ComplianceState, CIStatus.EnforcementState, CIAsn.OfferTypeID, 1, CIStatus.DesiredState, CIStatus.IsApplicable) BETWEEN 4999 AND 6000 THEN 'Error'
        ELSE ''
    END AS 'Enforcement State'
FROM
    v_DeploymentSummary                         AS DS
    LEFT JOIN v_ConfigurationItems              AS CI
        ON DS.ModelID = CI.ModelID
    LEFT JOIN v_CIAssignment                    AS CIAsn
        ON CIAsn.AssignmentID = DS.AssignmentID
    LEFT JOIN v_CIAssignmentToCI                AS CItoCI
        ON CItoCI.AssignmentID = CIAsn.AssignmentID
    LEFT JOIN v_CICurrentComplianceStatus       AS CIStatus
        ON CIStatus.CI_ID = CItoCI.CI_ID
    LEFT JOIN #UniqueSystems                    AS S1 
        ON S1.ResourceID = CIStatus.ResourceID
    LEFT JOIN #UniqueUsers                      AS U1 
        ON U1.UserID = CIStatus.UserID
    INNER JOIN #CollectionMembership            AS FCM
        ON FCM.CollectionID = DS.CollectionID
        AND FCM.ResourceID = COALESCE(U1.ResourceID, S1.ResourceID)
WHERE
    DS.FeatureType IN (1,6,11,12)
UNION
-- Handles Programs & Task Sequences
SELECT
    NULL AS 'ModelID',
    CDS.PackageID AS 'PackageID',
    NULL AS 'AssignmentID',
    CDS.DeploymentID AS 'DeploymentID',
    DS.FeatureType,
    CASE
        WHEN DS.FeatureType = 1 THEN 'Application'
        WHEN DS.FeatureType = 2 THEN 'Program'
        WHEN DS.FeatureType = 3 THEN 'Mobile Program'
        WHEN DS.FeatureType = 4 THEN 'Script'
        WHEN DS.FeatureType = 5 THEN 'Update'
        WHEN DS.FeatureType = 6 THEN 'Baseline'
        WHEN DS.FeatureType = 7 THEN 'Task Sequence'
        WHEN DS.FeatureType = 8 THEN 'Content Distribution'
        WHEN DS.FeatureType = 9 THEN 'Distribution Point Group'
        WHEN DS.FeatureType = 10 THEN 'Distribution Health'
        WHEN DS.FeatureType = 11 THEN 'Configuration Policy'
        WHEN DS.FeatureType = 12 THEN 'Application Group'
        WHEN DS.FeatureType = 20 THEN 'Abstract Configuration Item'
        ELSE CAST(DS.FeatureType AS varchar(2))
    END AS 'Type',
    NULL AS 'Last Modified By',
    CDAD.DeviceID AS 'MachineID',
    S2.Name0 AS 'Machine Name',
    U2.UserID AS 'User ID',
    U2.Unique_User_Name0 AS 'User Name',
    ADV.AdvertisementName AS 'AssignmentName',
    CDS.CollectionID AS 'CollectionID',
    CDS.CollectionName AS 'CollectionName',
    CASE
        WHEN len (DS.SoftwareName) > 0 THEN DS.SoftwareName
        ELSE CASE
            WHEN CHARINDEX (DS.CollectionName, CIAsn.AssignmentName) = 0 THEN CIAsn.AssignmentName
            WHEN CHARINDEX (concat (DS.CollectionName, '~@'),concat (CIAsn.AssignmentName, '~@')) < 1 THEN substring(
                CIAsn.AssignmentName,
                0,
                CHARINDEX (concat (DS.CollectionName, '~@'),concat (CIAsn.AssignmentName, '~@'),2) - 0
            )
            WHEN CHARINDEX (concat (DS.CollectionName, '~@'),concat (CIAsn.AssignmentName, '~@')) >= 1 THEN substring(
                CIAsn.AssignmentName,
                0,
                CHARINDEX (concat (DS.CollectionName, '~@'),concat (CIAsn.AssignmentName, '~@'),2) - 1
            )
            ELSE CIAsn.AssignmentName
        END
    END AS 'Software',
    NULL AS 'CIType_ID',
    CASE 
        WHEN CDAD.StatusType = 1 THEN 'Success'
        WHEN CDAD.StatusType = 2 THEN 'In Progress'
        WHEN CDAD.StatusType = 4 THEN 'Unknown'
        WHEN CDAD.StatusType = 5 THEN 'Error'
        ELSE ''
    END AS 'Enforcement State'
FROM
    v_DeploymentSummary                         AS DS
    LEFT JOIN v_CIAssignment                    AS CIAsn
        ON CIAsn.AssignmentID = DS.AssignmentID
    LEFT JOIN vClassicDeployments               AS CDS
        ON CDS.DeploymentID = DS.OfferID
    LEFT JOIN v_ClassicDeploymentAssetDetails   AS CDAD
        ON CDAD.PackageID = CDS.PackageID
        AND CDAD.DeploymentID = CDS.DeploymentID
        AND CDAD.ProgramName = CDS.ProgramName
    LEFT JOIN v_Advertisement                   AS ADV
        ON ADV.AdvertisementID = CDS.DeploymentID
        AND ADV.ProgramName = CDS.ProgramName
    LEFT JOIN #UniqueSystems                    AS S2
        ON S2.ResourceID = CDAD.DeviceID
    LEFT JOIN #UniqueUsers                      AS U2
        ON U2.Unique_User_Name0 = CDAD.UserName
    INNER JOIN #CollectionMembership            AS FCM
        ON FCM.CollectionID = DS.CollectionID
        AND FCM.ResourceID = COALESCE(U2.ResourceID, S2.ResourceID)
WHERE
    DS.FeatureType IN (2,7)
)
SELECT 
    CONCAT(
        CASE
            WHEN FeatureType IN (2,7) THEN DeploymentID
            ELSE CAST(AssignmentID AS varchar(9))
        END,
        '-',
        CASE
            WHEN FeatureType IN (2,7) THEN PackageID
            ELSE CAST(ModelID AS varchar(8))
        END
    ) AS 'Composite Key',
    *
FROM
    Apps
;