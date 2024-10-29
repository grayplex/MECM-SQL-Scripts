/*
 * Our termination/disabled OU is excludeded from AD discovery.
 * So sometimes when contractors are terminated, and later rehired,
 * their AD object in MECM still exists and causes conflicts with app deployments.
 * This script identifies those users.
 */
WITH DuplicateUsers AS (
    SELECT
        Unique_User_Name0,
        COUNT(*) AS DuplicateCount
    FROM
        v_R_User
    GROUP BY
        Unique_User_Name0
    HAVING
        COUNT(DISTINCT ResourceID) > 1
)
SELECT
    Unique_User_Name0,
    DuplicateCount
FROM
    DuplicateUsers
ORDER BY 
    DuplicateCount DESC;
    
/*
 * This section will take the above users and output all SIDs associated with that AD object,
 * so we know which user to delete from the database. 
 * The SID the user signs into with, and viewable from the CCM logs, should be the object kept,
 * regardless of what account is the most recent or "correct" one.
 */
SELECT 
    ResourceID,
    Unique_User_Name0,
    SID0
FROM
    v_R_User
WHERE
    UNIQUE_USER_NAME0 = 'DOMAIN\John.Doe';