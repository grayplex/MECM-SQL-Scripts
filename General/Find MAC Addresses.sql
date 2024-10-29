SELECT
    A.Name0,
    B.SerialNumber0,
    A.Manufacturer0,
    A.Model0,
    C.Name0,
    D.TotalPhysicalMemory0,
    sum(E.Size0),
    F.MACAddress0,
    F.IPAddress0,
    G.AD_Site_Name0,
    A.UserName0,
    H.Caption0,
    H.CSDVersion0,
    G.Creation_Date0,
    I.LastHWScan,
    J.Name0
FROM
    v_R_System G
JOIN
    v_GS_COMPUTER_SYSTEM A ON G.ResourceID = A.ResourceID
JOIN
    v_GS_PC_BIOS B  ON G.ResourceID = B.ResourceID
JOIN
    v_GS_PROCESSOR C  ON G.ResourceID = C.ResourceID
JOIN
    v_GS_X86_PC_MEMORY D ON G.ResourceID = D.ResourceID
JOIN 
    v_GS_DISK E ON G.ResourceID = E.ResourceID
JOIN 
    v_GS_NETWORK_ADAPTER_CONFIGURATION F ON G.ResourceID = F.ResourceID
JOIN 
    v_GS_OPERATING_SYSTEM H ON G.ResourceID = H.ResourceID
JOIN 
    v_GS_WORKSTATION_STATUS I ON G.ResourceID = I.ResourceID 
JOIN
    v_GS_NETWORK_ADAPTER J ON G.ResourceID = J.ResourceID
WHERE 
    G.Netbios_Name0 LIKE '%'
    AND F.MACAddress0 !=''
    AND J.Name0 NOT LIKE 'Bluetooth%'
    AND J.Name0 NOT LIKE 'WAN Miniport%'
    AND J.Name0 NOT LIKE 'Microsoft %'
    AND J.Name0 NOT LIKE 'Teredo%'
    AND J.Name0 NOT LIKE '%Wireless%'
    AND J.Name0 NOT LIKE 'Cisco%'
    AND F.IPAddress0 != ''
    -- AND G.AD_Site_Name0 = ''
    --AND A.Name0 LIKE ''
    -- AND F.MACAddress0 LIKE ''
GROUP BY
    A.Name0,
    A.Manufacturer0,
    A.Model0,
    C.Name0,
    D.TotalPhysicalMemory0,
    G.AD_Site_Name0,
    A.UserName0,
    H.Caption0,
    H.CSDVersion0,
    G.Creation_Date0,
    I.LastHWScan,
    B.SerialNumber0,
    F.MACAddress0,
    F.IPAddress0,
    J.Name0