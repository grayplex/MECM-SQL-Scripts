SELECT
    FCM.ResourceID AS 'CombinedResourceID',
    CASE
        WHEN COL.CollectionType = '1' THEN FCM.ResourceID
        WHEN COL.CollectionType = '2' THEN NULL
    END AS 'UserID',
    CASE
        WHEN COL.CollectionType = '1' THEN USR.Unique_User_Name0
        WHEN COL.CollectionType = '2' THEN NULL
    END AS 'UserName',
     CASE
        WHEN COL.CollectionType = '1' THEN NULL
        WHEN COL.CollectionType = '2' THEN FCM.ResourceID
    END AS 'MachineID',
    CASE
        WHEN COL.CollectionType = '1' THEN NULL
        WHEN COL.CollectionType = '2' THEN vSYS.Name0
    END AS 'MachineName',
    FCM.CollectionID,
    COL.Name AS 'CollectionName',
    CASE
        WHEN COL.CollectionType = '1' THEN 'User'
        WHEN COL.CollectionType = '2' THEN 'Device'
    END AS 'CollectionType'
FROM
    v_FullCollectionMembership FCM
    INNER JOIN v_Collection COL
        ON COL.CollectionID = FCM.CollectionID 
    LEFT JOIN v_R_System vSYS
        ON vSYS.ResourceID = FCM.ResourceID
    LEFT JOIN v_R_User USR
        ON USR.ResourceID = FCM.ResourceID
WHERE
    1=1
    -- AND FCM.CollectionID != 'Testing collection'