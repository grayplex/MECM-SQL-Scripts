 /* Users without primary PCs */
WITH ExcludedUsers AS (
	SELECT DISTINCT
		u.ResourceID
	FROM
		v_R_User u
	LEFT JOIN
		v_RA_User_UserGroupName ug
	ON 
		u.ResourceID = ug.ResourceID
	LEFT JOIN 
		v_RA_User_UserOUName ou
	ON	
		u.ResourceID = ou.ResourceID
	WHERE 
		ug.User_Group_Name0 IN ('DOMAIN\Guest Accounts')
		OR ou.User_OU_Name0 LIKE ('%User_Templates%')
		OR ou.User_OU_Name0 LIKE ('%O365 Contacts%')
		OR ou.User_OU_Name0  LIKE ('%MANAGED%')
)
SELECT 
	u.ResourceID AS UserID,
	u.User_Name0 AS UserWithoutPrimaryDevice,
	u.Full_User_Name0 AS FullName,
	u.AD_Object_Creation_Time0 AS ADCreationTime,
	sys.Name0 AS LastLoggedInDevice
FROM
	v_R_User u 
LEFT JOIN
	v_UserMachineRelation vum
ON 
	u.Unique_User_Name0 = vum.UniqueUserName
LEFT JOIN
	ExcludedUsers eu
ON 
	u.ResourceID = eu.ResourceID
LEFT JOIN
	v_GS_SYSTEM_CONSOLE_USER sc
ON
	u.Unique_User_Name0 = sc.SystemConsoleUser0 
LEFT JOIN 
	v_R_System sys
ON
	sc.ResourceID = sys.ResourceID 
WHERE
	vum.UniqueUserName IS NULL 
	AND eu.ResourceID IS NULL
	AND sc.LastConsoleUse0 IS NOT NULL
	AND u.AD_Object_Creation_Time0 <= DATEADD(DAY,-30,GETDATE())
ORDER BY 
	sc.LastConsoleUse0 DESC
;