/* Set the table and column variable to search for tables with that field */
DECLARE @Column AS VARCHAR(100) = 'LastModifiedBy'
DECLARE @Wildcard AS BIT = 1    -- 1 = Wildcard, 0 = Verbatim
DECLARE @Table AS VARCHAR(100) = '' -- Leave AS empty '' TO display ALL tables.

/*
 * 
 * DO NOT EDIT BELOW THIS LINE
 * 
 */

SELECT 
    t.name AS TableName,
    c.name AS ColumnName
FROM 
    sys.views t
INNER JOIN 
    sys.columns c ON t.object_id = c.object_id
WHERE 
    (
        @Wildcard = 1 AND c.name LIKE '%' + @Column + '%' OR
        @Wildcard = 0 AND c.name = @Column
    )
    AND
    (
        @Wildcard = 1 AND t.name LIKE '%' + @Table + '%' OR
        @Wildcard = 0 AND (@Table = '' OR t.name = @Table)
    )
order by 1