SELECT 
    AAD.AssignmentID,
    ASN.AppModelID,
    AAD.MachineID,
    AAD.MachineName,
    AAD.UserName,
    AAD.StatusUserID AS '8-digit User ID',
    ASN.CollectionID,
    CASE
        WHEN AAD.StatusType = 1 THEN 'Success'
        WHEN AAD.StatusType = 2 THEN 'In Progress'
        WHEN AAD.StatusType = 3 THEN 'Requirements Not Met'
        WHEN AAD.StatusType = 4 THEN 'Unknown'
        WHEN AAD.StatusType = 5 THEN 'Error'
    END AS 'Enforcement State'
FROM
    vAppGroupDeploymentAssetData AAD
    LEFT JOIN vSMS_ApplicationGroupAssignment ASN
        ON ASN.AssignmentID = AAD.AssignmentID
WHERE
    1=1
    -- AND ASN.CollectionID != 'testing collection ID'