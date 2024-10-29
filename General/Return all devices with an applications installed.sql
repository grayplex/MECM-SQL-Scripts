/* return devices that have the application installed */
SELECT DISTINCT 
	v_R_System.Name0 AS 'Device Name',
	v_R_User.Name0 AS 'User',
	v_Add_Remove_Programs.DisplayName0 AS 'Display Name',
	v_Add_Remove_Programs.ProdID0 AS 'Product Code',
	CONVERT(date, v_Add_Remove_Programs.InstallDate0) AS 'Install Date',
	v_Add_Remove_Programs.Publisher0 AS 'Publisher',
	v_Add_Remove_Programs.Version0 AS 'Version'
FROM 
	v_Add_Remove_Programs
	INNER JOIN v_R_System on v_R_System.ResourceID = v_Add_Remove_Programs.ResourceID
	INNER JOIN v_UserMachineRelationship on v_UserMachineRelationship.MachineResourceID = v_R_System.ResourceID
	INNER JOIN v_R_User on v_R_User.Unique_User_Name0  = v_UserMachineRelationship.UniqueUserName 
	LEFT JOIN (
		SELECT DISTINCT ResourceID
		FROM v_Add_Remove_Programs
		WHERE DisplayName0 LIKE 'NVM for Windows%'
	) as NVMPrograms on v_R_System.ResourceID = NVMPrograms.ResourceID
	LEFT JOIN (
		SELECT DISTINCT SMSID
		FROM v_FullCollectionMembership
		WHERE CollectionID = 'Collection with application above deployed'
	) as NVMTestUsers on v_R_User.Unique_User_Name0 = NVMTestUsers.SMSID
WHERE 
	v_Add_Remove_Programs.DisplayName0 LIKE 'Node%' 
	AND NVMPrograms.ResourceID IS NULL
	AND NVMTestUsers.SMSID IS NULL
	AND (
		v_R_System.Name0 LIKE 'desktops' 
		OR v_R_System.Name0 LIKE 'laptop' 
		OR v_R_System.Name0 LIKE 'VM'
	)
	AND LEN(v_R_System.Name0) = 6 
ORDER BY v_R_System.Name0;