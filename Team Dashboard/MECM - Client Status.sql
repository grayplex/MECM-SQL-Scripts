DECLARE @Collection varchar(8)
SET @Collection = 'SMS00001'
DECLARE @sql nvarchar(max)
SET @sql = '
WITH CTE AS (
    SELECT 
        sys.name0 AS ''Device'',
        sys.Client0,
        sys.Active0,
        sys.Obsolete0,
        sys.ResourceID,
        ROW_NUMBER() OVER (
            PARTITION BY sys.name0 
            ORDER BY CASE WHEN sys.SMBIOS_GUID0 IS NOT NULL THEN 0 ELSE 1 END
        ) AS RowNum
    FROM v_r_system Sys
    INNER JOIN v_FullCollectionMembership Col ON Sys.ResourceID = Col.ResourceID
    WHERE Col.CollectionID = ''SMS00001''
)
SELECT 
    Device,
    CASE WHEN Client0 = 1 THEN ''YES'' WHEN Client0 = 0 THEN ''NO'' ELSE ''NA'' END AS ''ConfigMgr Client'',
    CASE WHEN Active0 = 1 THEN ''YES'' WHEN Active0 = 0 THEN ''NO'' ELSE ''NA'' END AS ''Active Client'', 
    CASE WHEN Obsolete0 = 1 THEN ''YES'' WHEN Obsolete0 = 0 THEN ''NO'' ELSE ''NA'' END AS ''Obsolete Client''
FROM CTE
WHERE RowNum = 1
ORDER BY Device;'

EXEC sp_executesql
    @stmt = @sql,
    @params = N'@Collection varchar(8)',
    @Collection = @Collection;
