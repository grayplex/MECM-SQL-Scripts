/* Return applications that match variable*/
DECLARE 
	@QueryString AS NVARCHAR(100) = 'Teams'
SELECT DISTINCT 
	v_Add_Remove_Programs.DisplayName0 as 'DisplayName', 
	COUNT(v_R_User.Name0) as 'Number of Users'
FROM 
	v_Add_Remove_Programs 
JOIN 
	v_R_System ON v_Add_Remove_Programs.ResourceID = v_R_System.ResourceID 
JOIN 
	v_R_User ON v_R_System.User_Name0 LIKE v_R_User.User_Name0 
WHERE 
	v_Add_Remove_Programs.DisplayName0 = @QueryString
	OR v_Add_Remove_Programs.DisplayName0 LIKE '%' + @QueryString + '%' 
GROUP BY 
	v_Add_Remove_Programs.DisplayName0
ORDER BY 
	'DisplayName';