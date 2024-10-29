select distinct 
    sys.name0 [Computer Name],
    os.caption0 [OS],
    convert(nvarchar(26),ws.lasthwscan,100) as [Last MECM Scan],
    convert(nvarchar(26),sys.Last_Logon_Timestamp0,100) [Last Loggedon time Stamp],
    sys.user_name0 [Last User Name],
    uss.lasterrorcode,
    uss.lastscanpackagelocation 
from 
    v_r_system sys
    inner join v_gs_operating_system os 
        on os.resourceid=sys.resourceid
    inner join v_GS_WORKSTATION_STATUS ws 
        on ws.resourceid=sys.resourceid
    inner join v_updatescanstatus uss 
        on uss.ResourceId=sys.ResourceID
where 
    uss.lasterrorcode!='0'
order by 
    sys.name0 DESC,
    uss.lasterrorcode
