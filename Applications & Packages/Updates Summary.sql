SET NOCOUNT ON

IF OBJECT_ID('tempdb..#cici') IS NOT NULL DROP TABLE #cici
SELECT CICI.CategoryInstanceName, CICI.CI_ID
INTO #cici
FROM v_CICategoryInfo CICI
WHERE CICI.CategoryInstanceName IN (N'Critical Updates',N'Security Updates',N'Update Rollups',N'Updates',N'Upgrades')
CREATE NONCLUSTERED INDEX IX_cici_CI_ID ON #cici (CI_ID);

IF OBJECT_ID('tempdb..#fcm') IS NOT NULL DROP TABLE #fcm
SELECT FCM.ResourceID, FCM.CollectionID
INTO #fcm
FROM v_fullcollectionmembership FCM
CREATE NONCLUSTERED INDEX IX_fcm_ResourceID ON #fcm (ResourceID)
CREATE NONCLUSTERED INDEX IX_fcm_CollectionID on #fcm (CollectionID);

IF OBJECT_ID('tempdb..#uds') IS NOT NULL DROP TABLE #uds
SELECT UDS.CI_ID, UDS.CollectionID, UDS.StartTime, UDS.AssignmentID
INTO #uds
FROM v_UpdateDeploymentSummary UDS
WHERE UDS.AssignmentEnabled = '1'
AND CAST(UDS.StartTime AS DATE) <= CAST(GETDATE() AS DATE)
CREATE NONCLUSTERED INDEX IX_uds_CI_ID ON #uds (CI_ID)
CREATE NONCLUSTERED INDEX IX_uds_CollectionID ON #uds (CollectionID);

select DISTINCT
    UCS.ResourceID AS 'MachineID',
    UDS.AssignmentID, 
    CASE
        WHEN UCS.Status = '0' THEN 'Unknown'
        WHEN UCS.Status = '1' THEN 'Not Required'
        WHEN UCS.Status = '2' THEN 'Required'
        WHEN UCS.Status = '3' THEN 'Compliant'
    END AS 'Status',
    UI.Title,
    CICI.CategoryInstanceName,
    UDS.CollectionID
from v_Update_ComplianceStatus AS UCS 
    join v_UpdateInfo AS UI 
        on UCS.CI_ID = UI.CI_ID
    join #cici AS CICI 
        on UCS.CI_ID = CICI.CI_ID 
    join #fcm AS FCM 
        on FCM.resourceid = UCS.resourceid
    left join #uds AS UDS 
        on UCS.CI_ID = UDS.CI_ID 
        AND FCM.CollectionID = UDS.CollectionID
where 
    UDS.StartTime IS NOT NULL
    -- AND UDS.CollectionID != 'Testing collection';