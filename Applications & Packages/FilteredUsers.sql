SELECT
    USR.ResourceID AS '10-digit User Key',
    U.UserID AS '8-digit User ID',
    USR.Unique_User_Name0 AS 'Unique User Name',
    USR.FULL_USER_NAME0 AS 'Full User Name',
    USR.AD_Object_Creation_Time0 AS 'Creation Date'
FROM
    v_R_User USR
    JOIN v_Users U
        ON U.FullName = USR.Unique_User_Name0
        AND U.UserSID IS NOT NULL
    INNER JOIN (
        SELECT Unique_User_Name0, MAX(AD_Object_Creation_Time0) AS 'ADCreationDate' 
        FROM v_R_User 
        GROUP BY Unique_User_Name0
    ) AS GRP
        ON USR.Unique_User_Name0 = GRP.Unique_User_Name0
        AND USR.AD_Object_Creation_Time0 = GRP.ADCreationDate
WHERE
    U.UserSID IS NOT NULL