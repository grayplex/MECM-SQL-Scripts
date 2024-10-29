/* Client Health Queries */
 SELECT DISTINCT 
 		vrs.Name0, /* 'Device Name' */
 		vrs.Client0, /* Installed?? */
 		vrs.Obsolete0, /* Obsolete */
 		vrs.Client_Version0, /* Version */
 		vrs.Client_Type0, /* Type */
 		vrs.Decommissioned0, /* Decomissioned */
 		vccs.LastMPServerName, /* Server */
 		/* Communication */
 		vccs.LastStatusMessage, /* Last Status */
 		vccs.LastActiveTime, /* Active */
 		vccs.ClientStateDescription, /* State */
 		vccs.LastEvaluationHealthy, /* Evaluation Status  ??*/
 		vccs.LastDDR, /* DDR */
 		vccs.LastHW, /* HW */
 		vccs.LastSW, /* SW */
 		vccs.LastPolicyRequest /* Policy Request */
 FROM 
 	v_R_System vrs
JOIN 
 	v_CH_ClientHealth vcch on vcch.MachineID = vrs.ResourceID
JOIN
 	v_CH_ClientSummary vccs on vccs.ResourceID = vrs.ResourceID;