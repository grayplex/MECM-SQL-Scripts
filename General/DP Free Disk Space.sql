SELECT 
    SUBSTRING(
        NALPath,
        CHARINDEX('Display=\\', NALPath) + 10,
        CHARINDEX('\"]', NALPath) - (CHARINDEX('Display=\\', NALPath) + 10)
    ) AS 'Distribution Point',
    SiteCode AS 'Site Code',
    Drive,
    FORMAT((BytesFree / 1024.0 / 1024.0), 'N2') AS 'Free Space (GB)',
    FORMAT((BytesTotal / 1024.0 / 1024.0), 'N2') AS 'Total Space (GB)',
    PercentFree AS 'Percent Free',
    CASE 
        WHEN PercentFree BETWEEN 0 AND 19 THEN '1'
        WHEN PercentFree BETWEEN 20 AND 39 THEN '2'
        WHEN PercentFree BETWEEN 40 AND 59 THEN '3'
        WHEN PercentFree BETWEEN 60 AND 79 THEN '4'
        WHEN PercentFree BETWEEN 80 AND 100 THEN '5'
    END AS 'Percent Free Category'
FROM 
    v_DistributionPointDriveInfo AS DPDrive