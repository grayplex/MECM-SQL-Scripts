SELECT 
    CDAD.DeploymentID AS 'AppModelID',
    CDAD.DeploymentID AS 'AssignmentID',
    CDAD.PackageID AS 'AssignmentID2',
    CDAD.PackageName AS 'Package Name',
    CDAD.DeviceID AS 'MachineID',
    CDAD.UserName AS 'UserName',
    CDAD.MessageID AS 'Message ID',
    CDAD.StatusType AS 'Status Type',
    CDAD.StatusDescription AS 'Status Description',
    CDAD.CollectionID AS 'CollectionID'
FROM 
    v_ClassicDeploymentAssetDetails AS CDAD
    INNER JOIN v_DeploymentSummary AS DS
        ON DS.OfferID = CDAD.DeploymentID
WHERE
    1=1
    -- AND CDAD.CollectionID != 'Testing collection'
    

