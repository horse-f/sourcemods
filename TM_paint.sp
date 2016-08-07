#include <sourcemod>
#include <sdktools>
#define VERSION "0.5"
public Plugin:myinfo =
{
	name = "TM paint",
	author = "TIME",
	description = "+paint plugin for source mod",
	version = VERSION,
	url = ""
} 
new decal;
new bool:painting[MAXPLAYERS+1] = {false, ...};
public OnPluginStart()
{
	RegConsoleCmd("+paint", command_paint_on);
	RegConsoleCmd("-paint", command_paint_off);
}
public OnMapStart()
{
	reset();
	decal = PrecacheDecal("decals/paint/laser_red_med.vmt");
	CreateTimer(0.1, on_timer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}
public OnClientPutInServer(client)
{
	painting[client] = false;
}
public OnClientDisconnect(client)
{
	painting[client] = false;
}
public Action:on_timer(Handle:timer)
{
	decl Float:pos[3];
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && painting[i])
		{
			if(GetClientAimTargetEx(i,pos)!=-1)
			{
				TE_SetupBSPDecal(pos, 0, decal);
				TE_SendToAll();
			}
		}
	}
}
public Action:command_paint_on(client, args)
{
	painting[client]=true;
	return Plugin_Handled;
}
public Action:command_paint_off(client, args)
{
	painting[client]=false;
	return Plugin_Handled;
}

/*
	Taken from map-decals plugin by Berni, Stingbyte
	http://forums.alliedmods.net/showthread.php?t=69502
*/
GetClientAimTargetEx(client, Float:pos[3]) {

	if (client < 1) {
		return -1;
	}

	decl Float:vAngles[3], Float:vOrigin[3];
	
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_ALL, RayType_Infinite, TraceEntityFilterPlayer);
	
	if (TR_DidHit(trace)) {
		
		TR_GetEndPosition(pos, trace);
		new entity = TR_GetEntityIndex(trace);
		CloseHandle(trace);
		
		return entity;
	}
	
	CloseHandle(trace);
	
	return -1;
}

TE_SetupBSPDecal(const Float:vecOrigin[3], entity, index) {
	
	TE_Start("BSP Decal");
	TE_WriteVector("m_vecOrigin",vecOrigin);
	TE_WriteNum("m_nEntity",entity);
	TE_WriteNum("m_nIndex",index);
}

public bool:TraceEntityFilterPlayer(entity, contentsMask) {
	
 	return entity > MAXPLAYERS;
}
/**/

reset()
{
	for(new i = 1; i <= MAXPLAYERS; i++)
	{
		painting[i]=false;
	}
}