SELECT DISTINCT
    CASE
        WHEN DeploySummary.FeatureType = 2 THEN Adv.PackageID
        WHEN DeploySummary.FeatureType = 7 THEN Adv.PackageID
        ELSE CAST(DeploySummary.ModelID AS varchar(8))
    END AS 'AppModelID',
    CICI.CI_ID,
    VCI.ObjectTypeID,
    CASE
        WHEN DeploySummary.FeatureType = 1 THEN 'Application'           -- v_AppIntentAssetData
        WHEN DeploySummary.FeatureType = 2 THEN 'Program'               -- vSMS_ClientAdvertisementStatus
        WHEN DeploySummary.FeatureType = 3 THEN 'Mobile Program'
        WHEN DeploySummary.FeatureType = 4 THEN 'Script'
        --WHEN DeploySummary.FeatureType = 5 THEN 'Update'
        WHEN DeploySummary.FeatureType = 6 THEN 'Baseline'              -- v_CICurrentComplianceStatus.CIType_ID = 2 -- Configuration Item Baselines
        WHEN DeploySummary.FeatureType = 7 THEN 'Task Sequence'         -- vSMS_ClientAdvertisementStatus
        WHEN DeploySummary.FeatureType = 8 THEN 'Content Distribution'
        WHEN DeploySummary.FeatureType = 9 THEN 'Distribution Point Group'
        WHEN DeploySummary.FeatureType = 10 THEN 'Distribution Health'
        WHEN DeploySummary.FeatureType = 11 THEN 'Configuration Policy' -- v_CICurrentComplianceStatus.CIType_ID = 50 -- Config Policies like Bitlocker
        WHEN DeploySummary.FeatureType = 12 THEN 'Application Group'    -- vAppGroupDeploymentAssetData
        WHEN DeploySummary.FeatureType = 20 THEN 'Abstract Configuration Item'
        ELSE CAST(DeploySummary.FeatureType AS varchar(2))
    END AS 'Type',
    CASE
        WHEN DeploySummary.FeatureType = 1 THEN AppAsn.ApplicationName      -- Application
        WHEN DeploySummary.FeatureType = 2 THEN Adv.PackageName  -- Program
        --WHEN DeploySummary.FeatureType = 5 THEN UpdateInfo.Title            -- Update                       
        WHEN DeploySummary.FeatureType = 6 THEN                             -- Baseline
        CASE
            WHEN len (DeploySummary.SoftwareName) > 0 THEN DeploySummary.SoftwareName
            ELSE CASE
                -- sometimes DeploySummary.SoftwareName is blank, extract the baseline name from the assigment name
                WHEN CHARINDEX (
                    DeploySummary.CollectionName,
                    CIAsn.AssignmentName
                ) = 0 THEN CIAsn.AssignmentName
                -- if the collection name isn't in the assignment name, concat special stuff at the END to force it to only match at the END of the string
                WHEN CHARINDEX (
                    concat (DeploySummary.CollectionName, '~@'),
                    concat (CIAsn.AssignmentName, '~@')
                ) < 1 THEN substring(
                    CIAsn.AssignmentName,
                    0,
                    CHARINDEX (
                        concat (DeploySummary.CollectionName, '~@'),
                        concat (CIAsn.AssignmentName, '~@'),
                        2
                    ) - 0
                )
                WHEN CHARINDEX (
                    concat (DeploySummary.CollectionName, '~@'),
                    concat (CIAsn.AssignmentName, '~@')
                ) >= 1 THEN substring(
                    CIAsn.AssignmentName,
                    0,
                    CHARINDEX (
                        concat (DeploySummary.CollectionName, '~@'),
                        concat (CIAsn.AssignmentName, '~@'),
                        2
                    ) - 1
                )
                ELSE CIAsn.AssignmentName
            END
        END
        WHEN DeploySummary.FeatureType = 7 THEN DeploySummary.SoftwareName  -- Task sequence
        WHEN DeploySummary.FeatureType = 11 THEN DeploySummary.SoftwareName -- Configuration Policy
        WHEN DeploySummary.FeatureType = 12 THEN AppGrpAsn.ApplicationName  -- Application Group
        ELSE 'Unknown'
    END AS 'Software'
FROM
    v_DeploymentSummary                                         AS DeploySummary
    LEFT JOIN vSMS_ApplicationAssignment                        AS AppAsn 
        ON DeploySummary.AssignmentID = AppAsn.AssignmentID
    LEFT JOIN vSMS_ApplicationGroupAssignment                   AS AppGrpAsn 
        ON DeploySummary.AssignmentID = AppGrpAsn.AssignmentID
    LEFT JOIN vSMS_BaselineAssignment                           AS BaseAsn 
        ON DeploySummary.AssignmentID = BaseAsn.AssignmentID
    LEFT JOIN vSMS_ConfigurationPolicyAssignment                AS ConfigAsn 
        ON DeploySummary.ASsignmentID = ConfigAsn.AssignmentID
    LEFT JOIN v_CIAssignment                                    AS CIAsn 
        ON CIAsn.AssignmentID = DeploySummary.AssignmentID
    LEFT JOIN v_AdvertisementInfo                               AS Adv 
        ON DeploySummary.OfferID = Adv.AdvertisementID
    LEFT JOIN v_CIAssignmentToCI                                AS CICI
        ON CICI.AssignmentID = DeploySummary.AssignmentID
    LEFT JOIN v_CICategoryInfo_All                              AS VCI 
        ON VCI.CI_ID = CICI.CI_ID
ORDER BY
    VCI.ObjectTypeID,
    'Software'