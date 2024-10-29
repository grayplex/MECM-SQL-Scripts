SET NOCOUNT ON

IF OBJECT_ID('tempdb..#cici') IS NOT NULL DROP TABLE #cici
SELECT CICI.CategoryInstanceName, CICI.CI_ID
INTO #cici
FROM v_CICategoryInfo CICI
WHERE CICI.CategoryInstanceName = 'Security Updates'
CREATE NONCLUSTERED INDEX IX_cici_CI_ID ON #cici (CI_ID)

IF OBJECT_ID('tempdb..#fcm') IS NOT NULL DROP TABLE #fcm
SELECT FCM.ResourceID, FCM.CollectionID
INTO #fcm
FROM v_fullcollectionmembership FCM
-- WHERE FCM.CollectionID IN ('patch ring 1', 'patch ring 2', 'patch ring 3', 'patch all')
CREATE NONCLUSTERED INDEX IX_fcm_ResourceID ON #fcm (ResourceID)
CREATE NONCLUSTERED INDEX IX_fcm_CollectionID on #fcm (CollectionID)

IF OBJECT_ID('tempdb..#uds') IS NOT NULL DROP TABLE #uds
SELECT UDS.CI_ID, UDS.CollectionID, UDS.StartTime
INTO #uds
FROM v_UpdateDeploymentSummary UDS
WHERE UDS.AssignmentEnabled = '1'
AND CAST(UDS.StartTime AS DATE) <= CAST(GETDATE() AS DATE)
CREATE NONCLUSTERED INDEX IX_uds_CI_ID ON #uds (CI_ID)
CREATE NONCLUSTERED INDEX IX_uds_CollectionID ON #uds (CollectionID)

select distinct 
    sys.Name0, 
    UCS.CI_ID, 
    UI.Title,
    CICI.CategoryInstanceName
from v_Update_ComplianceStatus UCS 
    join v_R_System sys on UCS.ResourceID = sys.ResourceID AND UCS.Status = '2'
    join v_UpdateInfo UI on UCS.CI_ID = UI.CI_ID 
    join #cici CICI on UCS.CI_ID = CICI.CI_ID 
    join #fcm FCM on FCM.resourceid=sys.resourceid
    left join #uds UDS on UCS.CI_ID = UDS.CI_ID AND FCM.CollectionID = UDS.CollectionID
where 
    UDS.StartTime IS NOT NULL
Order by 
    sys.Name0