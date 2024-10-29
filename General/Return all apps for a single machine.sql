/* Return all applications for a single machine */
DECLARE	@Machine as NVARCHAR(6) = ''

SELECT 
	v_Add_Remove_Programs.DisplayName0 AS 'Display Name',
	v_Add_Remove_Programs.ProdID0 AS 'Product Code',
	v_Add_Remove_Programs.Version0 AS 'Version',
	v_Add_Remove_Programs.Publisher0 AS 'Publisher'
FROM 
	v_Add_Remove_Programs 
JOIN 
	v_R_System ON v_Add_Remove_Programs.ResourceID = v_R_System.ResourceID
WHERE
	v_R_System.Name0 = @Machine
ORDER BY
	'Publisher',
	'Display Name'