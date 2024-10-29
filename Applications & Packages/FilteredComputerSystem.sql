SELECT
    CS.ResourceID AS 'Resource ID',
    CS.NAME0 AS 'Machine Name',
    CS.Manufacturer0 AS 'Manufacturer',
    CS.Model0 AS 'Model',
    CON.TopConsoleUser0 AS 'Console User',
    CS.UserName0 AS 'User Name',
    vSYS.AD_Site_Name0
FROM 
    v_GS_COMPUTER_SYSTEM CS
    LEFT JOIN v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP CON ON CON.ResourceID = CS.ResourceID
    LEFT JOIN v_R_System vSYS ON vSYS.ResourceID = CS.ResourceID