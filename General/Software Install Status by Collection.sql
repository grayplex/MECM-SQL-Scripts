-- Step 1: Get the list of distinct application names
DECLARE @cols AS NVARCHAR(MAX),
        @query AS NVARCHAR(MAX),
       	@CollectionID AS NVARCHAR(50);

-- Step 2: Set the parameter values (for testing purposes, should be passed from Power BI)
SET @CollectionID = '';

SET @cols = STUFF((SELECT DISTINCT ',' + QUOTENAME(ApplicationName)
                   FROM v_ApplicationAssignment ASN
                   INNER JOIN v_Collection COL ON ASN.CollectionID = COL.CollectionID
                   WHERE COL.CollectionID = @CollectionID
                   AND ASN.AssignmentEnabled = 1
                   FOR XML PATH(''), TYPE
                  ).value('.', 'NVARCHAR(MAX)'), 1, 1, '');
              
-- Step 3: Generate the dynamic pivot query
SET @query = '
SELECT Full_User_Name0 AS [User Name], Name0 AS [Primary Device], ' + @cols + '
FROM 
(
    SELECT 
        USR.Full_User_Name0,
		SYS.Name0,
        ASN.ApplicationName,
        CASE 
            WHEN APP.EnforcementState = 1000 THEN ''Success''
            WHEN APP.EnforcementState = 1001 THEN ''Already Compliant''
            WHEN APP.EnforcementState = 1002 THEN ''Simulate Success''
            WHEN APP.EnforcementState = 2000 THEN ''In Progress''
            WHEN APP.EnforcementState = 2001 THEN ''Waiting for content''
            WHEN APP.EnforcementState = 2002 THEN ''Installing''
            WHEN APP.EnforcementState = 2003 THEN ''Restart to continue''
            WHEN APP.EnforcementState = 2004 THEN ''Waiting for maintenance window''
            WHEN APP.EnforcementState = 2005 THEN ''Waiting for schedule''
            WHEN APP.EnforcementState = 2006 THEN ''Downloading content''
            WHEN APP.EnforcementState = 2007 THEN ''Installing content''
            WHEN APP.EnforcementState = 2008 THEN ''Restart to complete''
            WHEN APP.EnforcementState = 2009 THEN ''Content downloaded''
            WHEN APP.EnforcementState = 2010 THEN ''Waiting for update''
            WHEN APP.EnforcementState = 2011 THEN ''Waiting for session reconnect''
            WHEN APP.EnforcementState = 2012 THEN ''Waiting for logoff''
            WHEN APP.EnforcementState = 2013 THEN ''Waiting for logon''
            WHEN APP.EnforcementState = 2014 THEN ''Waiting To Install''
            WHEN APP.EnforcementState = 2015 THEN ''Waiting Retry''
            WHEN APP.EnforcementState = 2016 THEN ''Waiting For Presentation Mode''
            WHEN APP.EnforcementState = 2017 THEN ''Waiting For Orchestration''
            WHEN APP.EnforcementState = 2018 THEN ''Waiting For Network''
            WHEN APP.EnforcementState = 2019 THEN ''Pending App-V Update''
            WHEN APP.EnforcementState = 2020 THEN ''Updating App-V''
            WHEN APP.EnforcementState = 3000 THEN ''Requirements not met''
            WHEN APP.EnforcementState = 3001 THEN ''Host Platform Not Applicable''
            WHEN APP.EnforcementState = 4000 THEN ''Unknown''
            WHEN APP.EnforcementState = 5000 THEN ''Deployment failed''
            WHEN APP.EnforcementState = 5001 THEN ''Evaluation failed''
            WHEN APP.EnforcementState = 5002 THEN ''Deployment failed''
            WHEN APP.EnforcementState = 5003 THEN ''Failed to locate content''
            WHEN APP.EnforcementState = 5004 THEN ''Dependency failed''
            WHEN APP.EnforcementState = 5005 THEN ''Failed to download content''
            WHEN APP.EnforcementState = 5006 THEN ''Conflicts with another deployment''
            WHEN APP.EnforcementState = 5007 THEN ''Waiting Retry''
            WHEN APP.EnforcementState = 5008 THEN ''Failed to uninstall superseded deployment''
            WHEN APP.EnforcementState = 5009 THEN ''Failed to download superseded deployment''
            WHEN APP.EnforcementState = 5010 THEN ''Failed to update App-V''
            ELSE ''Unknown State''
        END AS DeploymentStatus
    FROM 
        v_R_User USR
    JOIN 
        v_FullCollectionMembership FCM ON USR.ResourceID = FCM.ResourceID
    JOIN 
        v_Collection COL ON FCM.CollectionID = COL.CollectionID 
    JOIN 
        v_ApplicationAssignment ASN ON FCM.CollectionID = ASN.CollectionID
    JOIN 
        vAppDeploymentAssetDetails APP ON USR.Unique_User_Name0 = APP.UserName AND ASN.AssignmentId = APP.AssignmentID
	JOIN
		v_UserMachineRelationship REL ON USR.Unique_User_Name0 = REL.UniqueUserName
	JOIN
		v_R_System SYS ON REL.MachineResourceID = SYS.ResourceID
    WHERE 
        FCM.CollectionID = @CollectionID
) x
PIVOT
(
    MAX(DeploymentStatus)
    FOR ApplicationName IN (' + @cols + ')
) p
ORDER BY [User Name];
';
-- Step 4: Execute the dynamic pivot query
EXEC sp_executesql @query, N'@CollectionID NVARCHAR(50)', @CollectionID;