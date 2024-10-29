/*
 * Items still needing identification
 * 
 * Mobile Program
 * Script
 * Update
 * Content Distribution
 * Distribution Point Group
 * Distribution Health
 * Abstract Configuration Item
 */
SELECT
    CASE 
        WHEN DeploySummary.FeatureType = 2 THEN Adv.AdvertisementID
        WHEN DeploySummary.FeatureType = 7 THEN Adv.AdvertisementID
        ELSE CAST(DeploySummary.AssignmentID AS varchar(9))
    END AS 'AssignmentID',
    CASE
        WHEN DeploySummary.FeatureType = 2 THEN Adv.PackageID
        WHEN DeploySummary.FeatureType = 7 THEN Adv.PackageID
        ELSE CAST(DeploySummary.ModelID AS varchar(8))
    END AS 'AppModelID',
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
        WHEN DeploySummary.FeatureType = 2 THEN DeploySummary.SoftwareName  -- Program
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
    END AS 'Software',
    DeploySummary.CollectionID AS 'Collection ID',
    DeploySummary.CollectionName AS 'CollectionName',
    DeploySummary.NumberTotal AS 'Targeted',
    DeploySummary.NumberSuccess AS 'Success',
    DeploySummary.NumberInProgress AS 'InProgress',
    DeploySummary.NumberErrors AS 'Errors',
    DeploySummary.NumberOther AS 'Other',
    DeploySummary.NumberUnknown AS 'Unknown',
    CASE
        WHEN (DeploySummary.NumberTotal = 0)
        OR (DeploySummary.NumberTotal IS NULL) THEN '1'
        ELSE round(
            (
                DeploySummary.NumberSuccess + DeploySummary.NumberOther
            ) / CONVERT(float, DeploySummary.NumberTotal),
            2
        )
    END AS 'Success%',
    DeploySummary.NumberInProgress + DeploySummary.NumberErrors + DeploySummary.NumberOther + DeploySummary.NumberUnknown AS 'Unfinished',
    DeploySummary.DeploymentTime AS 'Available/Start Time',
    CASE
        WHEN DeploySummary.FeatureType = 6 THEN BaseAsn.EnforcementDeadline     -- Baselines
        WHEN DeploySummary.FeatureType = 11 THEN ConfigAsn.EnforcementDeadline  -- Config Policies
        WHEN DeploySummary.FeatureType = 12 THEN AppGrpAsn.EnforcementDeadline  -- Application Groups
        ELSE DeploySummary.EnforcementDeadline                                  -- Applications, Programs, Updates, Task Sequences
    END AS 'Deadline',
    CASE
        WHEN DeploySummary.FeatureType = 1 THEN CASE    -- Application
            WHEN AppAsn.UseGMTTimes = 0 THEN 'Local'
            ELSE 'UTC'
        END
        WHEN DeploySummary.FeatureType = 2 THEN CASE    -- Program
            WHEN Adv.PresentTimeIsGMT = 0 THEN 'Local'
            ELSE 'UTC'
        END
        --WHEN DeploySummary.FeatureType = 5 THEN CASE    -- Update
            --WHEN UpdateAsn.UseGMTTimes = 0 THEN 'Local'
            --ELSE 'UTC'
        --END
        WHEN DeploySummary.FeatureType = 6 THEN CASE    -- Baseline
            WHEN BaseAsn.UseGMTTimes = 0 THEN 'Local'
            ELSE 'UTC'
        END
        WHEN DeploySummary.FeatureType = 7 THEN CASE    -- Task Sequence
            WHEN Adv.PresentTimeIsGMT = 0 THEN 'Local'
            ELSE 'UTC'
        END
        WHEN DeploySummary.FeatureType = 11 THEN CASE   -- Config Policy
            WHEN ConfigAsn.UseGMTTimes = 0 THEN 'Local'
            ELSE 'UTC'
        END
        WHEN DeploySummary.FeatureType = 12 THEN CASE   -- Application Group
            WHEN AppGrpAsn.UseGMTTimes = 0 THEN 'Local'
            ELSE 'UTC'
        END
        ELSE 'unknown'
    END AS 'Local/UTC',
    DeploySummary.CreationTime AS 'CreationTime',
    CASE
        WHEN DeploySummary.FeatureType = 1  THEN AppAsn.LastModificationTime    -- Application
        WHEN DeploySummary.FeatureType = 2  THEN DeploySummary.ModificationTime -- Program
        --WHEN DeploySummary.FeatureType = 5  THEN UpdateAsn.LastModificationTime -- Update
        WHEN DeploySummary.FeatureType = 6  THEN BaseAsn.LastModificationTime   -- Baseline
        WHEN DeploySummary.FeatureType = 7  THEN DeploySummary.ModificationTime -- Task Sequence
        WHEN DeploySummary.FeatureType = 11 THEN ConfigAsn.LastModificationTime -- Config Policy
        WHEN DeploySummary.FeatureType = 12 THEN AppGrpAsn.LastModificationTime -- Application Group
    END AS 'LastModifiedTime',
    CASE
        WHEN DeploySummary.FeatureType = 1  THEN AppAsn.LastModifiedBy      -- Application
        WHEN DeploySummary.FeatureType = 2  THEN ''                         -- Program
        --WHEN DeploySummary.FeatureType = 5  THEN UpdateAsn.LastModifiedBy   -- Update
        WHEN DeploySummary.FeatureType = 6  THEN BaseAsn.LastModifiedBy     -- Baseline
        WHEN DeploySummary.FeatureType = 7  THEN ''                         -- Task Sequence
        WHEN DeploySummary.FeatureType = 11 THEN ConfigAsn.LastModifiedBy   -- Config Policy
        WHEN DeploySummary.FeatureType = 12 THEN AppGrpAsn.LastModifiedBy   -- Application Group
    END AS 'LastModifiedBy',
    DeploySummary.SummarizationTime AS 'SummarizationTime',
    CASE
        WHEN DeploySummary.FeatureType = 1 THEN CASE        -- Application
            WHEN AppAsn.DesiredConfigType = 1 THEN 'Install'
            WHEN AppAsn.DesiredConfigType = 2 THEN 'Uninstall'
        END
        WHEN DeploySummary.FeatureType = 2 THEN 'Install'   -- Program
        --WHEN DeploySummary.FeatureType = 5 THEN CASE        -- Update
            --WHEN UpdateAsn.DesiredConfigType = 1 THEN 'Install'
            --WHEN UpdateAsn.DesiredConfigType = 2 THEN 'Uninstall'
        --END
        WHEN DeploySummary.FeatureType = 6 THEN CASE        -- Baseline
            WHEN BaseAsn.DesiredConfigType = 1 THEN 'Install'
            WHEN BaseAsn.DesiredConfigType = 2 THEN 'Uninstall'
        END
        WHEN DeploySummary.FeatureType = 7 THEN ''          -- Task Sequence
        WHEN DeploySummary.FeatureType = 11 THEN CASE       -- Config Policy
            WHEN ConfigAsn.DesiredConfigType = 1 THEN 'Install'
            WHEN ConfigAsn.DesiredConfigType = 2 THEN 'Uninstall'
        END
        WHEN DeploySummary.FeatureType = 12 THEN CASE       -- Application Group
            WHEN AppGrpAsn.DesiredConfigType = 1 THEN 'Install'
            WHEN AppGrpAsn.DesiredConfigType = 2 THEN 'Uninstall'
        END
        ELSE ''
    END AS 'Action',
    CASE
        WHEN DeploySummary.DeploymentIntent = 1 THEN 'Required'
        WHEN DeploySummary.DeploymentIntent = 2 THEN 'Available'
        WHEN DeploySummary.DeploymentIntent = 3 THEN 'Simulate'
    END AS 'Purpose',
    CASE
        WHEN DeploySummary.FeatureType = 1 THEN CASE    -- Application
            WHEN AppAsn.useruiexperience = 0 THEN 'Hide in Software Center and all notifications'
            WHEN AppAsn.useruiexperience = 1 THEN 'Display in Software Center and only show notifications for computer restarts '
            WHEN AppAsn.useruiexperience = 3 THEN 'Display in Software Center and show all notifications'
        END
        WHEN DeploySummary.FeatureType = 2 THEN NULL    -- Program
        --WHEN DeploySummary.FeatureType = 5 THEN CASE    -- Update
            --WHEN UpdateAsn.useruiexperience = 0 THEN 'Hide in Software Center and all notifications'
            --WHEN UpdateAsn.useruiexperience = 1 THEN 'Display in Software Center and only show notifications for computer restarts '
            --WHEN UpdateAsn.useruiexperience = 3 THEN 'Display in Software Center and show all notifications'
        --END
        WHEN DeploySummary.FeatureType = 6 THEN CASE    -- Baseline
            WHEN BaseAsn.useruiexperience = 0 THEN 'Hide in Software Center and all notifications'
            WHEN BaseAsn.useruiexperience = 1 THEN 'Display in Software Center and only show notifications for computer restarts '
            WHEN BaseAsn.useruiexperience = 3 THEN 'Display in Software Center and show all notifications'
        END
        WHEN DeploySummary.FeatureType = 7 THEN NULL    -- Task Sequence
        WHEN DeploySummary.FeatureType = 11 THEN CASE   -- Config Policy
            WHEN ConfigAsn.useruiexperience = 0 THEN 'Hide in Software Center and all notifications'
            WHEN ConfigAsn.useruiexperience = 1 THEN 'Display in Software Center and only show notifications for computer restarts '
            WHEN ConfigAsn.useruiexperience = 3 THEN 'Display in Software Center and show all notifications'
        END
        WHEN DeploySummary.FeatureType = 12 THEN CASE   -- Application Group
            WHEN AppGrpAsn.useruiexperience = 0 THEN 'Hide in Software Center and all notifications'
            WHEN AppGrpAsn.useruiexperience = 1 THEN 'Display in Software Center and only show notifications for computer restarts '
            WHEN AppGrpAsn.useruiexperience = 3 THEN 'Display in Software Center and show all notifications'
        END
        ELSE ''
    END AS 'UserExperience',
    CASE
        WHEN DeploySummary.FeatureType = 1 THEN CASE    -- Application
            WHEN AppAsn.OverrideServiceWindows = 1 THEN 'Yes'
            WHEN AppAsn.OverrideServiceWindows = 0 THEN 'No'
        END
        WHEN DeploySummary.FeatureType = 2 THEN CASE    -- Program
            WHEN (Adv.AdvertFlags & 0x00100000) = 0x00100000 THEN 'Yes'
            ELSE 'No'
        END
        --WHEN DeploySummary.FeatureType = 5 THEN CASE    -- Update
            --WHEN UpdateAsn.OverrideServiceWindows = 1 THEN 'Yes'
            --WHEN UpdateAsn.OverrideServiceWindows = 0 THEN 'No'
        --END
        WHEN DeploySummary.FeatureType = 6 THEN CASE    -- Baseline
            WHEN BaseAsn.OverrideServiceWindows = 1 THEN 'Yes'
            WHEN BaseAsn.OverrideServiceWindows = 0 THEN 'No'
        END
        WHEN DeploySummary.FeatureType = 7 THEN CASE     -- Task Sequence
            WHEN (Adv.AdvertFlags & 0x00100000) = 0x00100000 THEN 'Yes'
            ELSE 'No'
        END
        WHEN DeploySummary.FeatureType = 11 THEN CASE   -- Config Policy
            WHEN ConfigAsn.OverrideServiceWindows = 1 THEN 'Yes'
            WHEN ConfigAsn.OverrideServiceWindows = 0 THEN 'No'
        END
        WHEN DeploySummary.FeatureType = 12 THEN CASE   -- Application Group
            WHEN AppGrpAsn.OverrideServiceWindows = 1 THEN 'Yes'
            WHEN AppGrpAsn.OverrideServiceWindows = 0 THEN 'No'
        END
        ELSE ''
    END AS 'Ignore Maint Windows',
    CASE
        WHEN DeploySummary.FeatureType = 1 THEN CASE    -- Application
            WHEN AppAsn.RebootOutsideOfServiceWindows = 1 THEN 'Yes'
            WHEN AppAsn.RebootOutsideOfServiceWindows = 0 THEN 'No'
        END
        WHEN DeploySummary.FeatureType = 2 THEN CASE    -- Program
            WHEN (Adv.AdvertFlags & 0x00200000) = 0x00200000 THEN 'Yes'
            ELSE 'No'
        END
        --WHEN DeploySummary.FeatureType = 5 THEN CASE    -- Update
            --WHEN UpdateAsn.RebootOutsideOfServiceWindows = 1 THEN 'Yes'
            --WHEN UpdateAsn.RebootOutsideOfServiceWindows = 0 THEN 'No'
        --END
        WHEN DeploySummary.FeatureType = 6 THEN CASE    -- Baseline
            WHEN BaseAsn.RebootOutsideOfServiceWindows = 1 THEN 'Yes'
            WHEN BaseAsn.RebootOutsideOfServiceWindows = 0 THEN 'No'
        END
        WHEN DeploySummary.FeatureType = 7 THEN CASE    -- Task Sequence
            WHEN (Adv.AdvertFlags & 0x00200000) = 0x00200000 THEN 'Yes'
            ELSE 'No'
        END
        WHEN DeploySummary.FeatureType = 11 THEN CASE   -- Config Policy
            WHEN ConfigAsn.RebootOutsideOfServiceWindows = 1 THEN 'Yes'
            WHEN ConfigAsn.RebootOutsideOfServiceWindows = 0 THEN 'No'
        END
        WHEN DeploySummary.FeatureType = 12 THEN CASE   -- Application Group
            WHEN AppGrpAsn.RebootOutsideOfServiceWindows = 1 THEN 'Yes'
            WHEN AppGrpAsn.RebootOutsideOfServiceWindows = 0 THEN 'No'
        END
        ELSE ''
    END AS 'Reboot Outside Maint Windows',
    CASE
        WHEN DeploySummary.FeatureType = 1 THEN AppAsn.AssignmentName       -- Application
        WHEN DeploySummary.FeatureType = 2 THEN Adv.AdvertisementName       -- Program
        --WHEN DeploySummary.FeatureType = 5 THEN UpdateAsn.AssignmentName    -- Update
        WHEN DeploySummary.FeatureType = 6 THEN BaseAsn.AssignmentName      -- Baseline
        WHEN DeploySummary.FeatureType = 7 THEN Adv.AdvertisementName       -- Task Sequence
        WHEN DeploySummary.FeatureType = 11 THEN ConfigAsn.AssignmentName   -- Configuration Policy
        WHEN DeploySummary.FeatureType = 12 THEN AppGrpAsn.AssignmentName   -- Application Group
    END AS 'DeploymentName',
    Colls.ObjectPath AS 'CollectionPath'
FROM
    v_DeploymentSummary                                         AS DeploySummary
    LEFT JOIN vSMS_ApplicationAssignment                        AS AppAsn 
        ON DeploySummary.AssignmentID = AppAsn.AssignmentID
    LEFT JOIN vSMS_ApplicationGroupAssignment                   AS AppGrpAsn 
        ON DeploySummary.AssignmentID = AppGrpAsn.AssignmentID
    LEFT JOIN vSMS_BaselineAssignment                           AS BaseAsn 
        ON DeploySummary.AssignmentID = BaseAsn.AssignmentID
    --LEFT JOIN vSMS_UpdatesAssignment                            AS UpdateAsn 
        --ON DeploySummary.AssignmentID = UpdateAsn.AssignmentID
    LEFT JOIN vSMS_ConfigurationPolicyAssignment                AS ConfigAsn 
        ON DeploySummary.ASsignmentID = ConfigAsn.AssignmentID
    LEFT JOIN v_Collections                                     AS Colls 
        ON Colls.CollectionName = DeploySummary.CollectionName
    LEFT JOIN v_Collection                                      AS Col 
        ON Col.CollID = Colls.CollectionID
    LEFT JOIN v_CIAssignment                                    AS CIAsn 
        ON CIAsn.AssignmentID = DeploySummary.AssignmentID
    LEFT JOIN v_CIAssignmentToCI                                AS CIAsntoCI 
        ON CIAsntoCI.AssignmentID = DeploySummary.AssignmentID
    LEFT JOIN v_UpdateInfo                                      AS UpdateInfo 
        ON UpdateInfo.CI_ID = CIAsntoCI.CI_ID
    LEFT JOIN v_Advertisement                                   AS Adv 
        ON DeploySummary.OfferID = Adv.AdvertisementID
WHERE
    1=1
    -- AND Col.CollectionID != 'testing collection ID'
    AND DeploySummary.FeatureType != '5'
ORDER BY
    DeploySummary.FeatureType,
    AppAsn.ApplicationName,
    DeploySummary.EnforcementDeadline