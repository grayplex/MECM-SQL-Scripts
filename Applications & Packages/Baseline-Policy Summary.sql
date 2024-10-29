SELECT
    CICI.AssignmentID,
    CI.AssignmentID AS 'AppModelID',
    CICCS.ResourceID AS 'MachineID',
    CICCS.UserID AS '8-digit User ID',
    CASE
        WHEN CICCS.UserID = 0 THEN CICCS.ResourceID
        WHEN CICCS.UserID IS NULL THEN CICCS.ResourceID
        ELSE CICCS.UserID
    END AS 'JoinKey',
    CICCS.UserName,
    CICCS.CIType_ID,
    CASE 
        WHEN dbo.fn_GetAppState(CICCS.ComplianceState, CICCS.EnforcementState, CI.OfferTypeID, 1, CICCS.DesiredState, CICCS.IsApplicable) < 2000
            THEN 'Success'
        WHEN (dbo.fn_GetAppState(CICCS.ComplianceState, CICCS.EnforcementState, CI.OfferTypeID, 1, CICCS.DesiredState, CICCS.IsApplicable) > 1999 
            AND dbo.fn_GetAppState(CICCS.ComplianceState, CICCS.EnforcementState, CI.OfferTypeID, 1, CICCS.DesiredState, CICCS.IsApplicable) <3000)
            THEN 'In Progress'
        WHEN (dbo.fn_GetAppState(CICCS.ComplianceState, CICCS.EnforcementState, CI.OfferTypeID, 1, CICCS.DesiredState, CICCS.IsApplicable) > 2999
            AND dbo.fn_GetAppState(CICCS.ComplianceState, CICCS.EnforcementState, CI.OfferTypeID, 1, CICCS.DesiredState, CICCS.IsApplicable) <4000)
            THEN 'Requirements Not Met'
        WHEN (dbo.fn_GetAppState(CICCS.ComplianceState, CICCS.EnforcementState, CI.OfferTypeID, 1, CICCS.DesiredState, CICCS.IsApplicable) > 3999
            AND dbo.fn_GetAppState(CICCS.ComplianceState, CICCS.EnforcementState, CI.OfferTypeID, 1, CICCS.DesiredState, CICCS.IsApplicable) <5000)
            THEN 'Unknown'
        WHEN (dbo.fn_GetAppState(CICCS.ComplianceState, CICCS.EnforcementState, CI.OfferTypeID, 1, CICCS.DesiredState, CICCS.IsApplicable) > 4999
            AND dbo.fn_GetAppState(CICCS.ComplianceState, CICCS.EnforcementState, CI.OfferTypeID, 1, CICCS.DesiredState, CICCS.IsApplicable) <6000)
            THEN 'Error'
        ELSE ''
    END AS 'Enforcement State',
    CI.CollectionID
FROM
    v_CICurrentComplianceStatus CICCS
    JOIN v_CIAssignmentToCI CICI
        ON CICCS.CI_ID = CICI.CI_ID
    LEFT JOIN v_CIAssignment CI
        ON CICI.AssignmentID = CI.AssignmentID
WHERE 
    CICCS.CIType_ID IN ('50','2')
    --AND CI.CollectionID != 'testing collection ID'