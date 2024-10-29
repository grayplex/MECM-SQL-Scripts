SELECT 
    AAD.AssignmentID,
    ASN.AppModelID,
    AAD.MachineID,
    AAD.UserName,
    AAD.UserID AS '8-digit User ID',
    AAD.MachineName,
    ASN.CollectionID,
    CASE 
        WHEN dbo.Fn_getappstate(AAD.ComplianceState, AAD.EnforcementState, ASN.OfferTypeID, 1, AAD.DesiredState, AAD.IsApplicable) < 2000
            THEN 'Success'
        WHEN (dbo.Fn_getappstate(AAD.ComplianceState, AAD.EnforcementState, ASN.OfferTypeID, 1, AAD.DesiredState, AAD.IsApplicable) > 1999 
            AND dbo.Fn_getappstate(AAD.ComplianceState, AAD.EnforcementState, ASN.OfferTypeID, 1, AAD.DesiredState, AAD.IsApplicable) <3000)
            THEN 'In Progress'
        WHEN (dbo.Fn_getappstate(AAD.ComplianceState, AAD.EnforcementState, ASN.OfferTypeID, 1, AAD.DesiredState, AAD.IsApplicable) > 2999
            AND dbo.Fn_getappstate(AAD.ComplianceState, AAD.EnforcementState, ASN.OfferTypeID, 1, AAD.DesiredState, AAD.IsApplicable) <4000)
            THEN 'Requirements Not Met'
        WHEN (dbo.Fn_getappstate(AAD.ComplianceState, AAD.EnforcementState, ASN.OfferTypeID, 1, AAD.DesiredState, AAD.IsApplicable) > 3999
            AND dbo.Fn_getappstate(AAD.ComplianceState, AAD.EnforcementState, ASN.OfferTypeID, 1, AAD.DesiredState, AAD.IsApplicable) <5000)
            THEN 'Unknown'
        WHEN (dbo.Fn_getappstate(AAD.ComplianceState, AAD.EnforcementState, ASN.OfferTypeID, 1, AAD.DesiredState, AAD.IsApplicable) > 4999
            AND dbo.Fn_getappstate(AAD.ComplianceState, AAD.EnforcementState, ASN.OfferTypeID, 1, AAD.DesiredState, AAD.IsApplicable) <6000)
            THEN 'Error'
        ELSE ''
    END AS 'Enforcement State'
FROM
    v_AppIntentAssetData AS AAD
    LEFT JOIN v_ApplicationAssignment ASN
        ON AAD.AssignmentID = ASN.AssignmentID
WHERE
    1=1
    -- AND ASN.CollectionID != 'testing collection ID'