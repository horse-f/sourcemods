/*TM
	This plugin is meant to be a teleport save
system that will retain the client's velocity upon
saving their location. This is a very light plugin
with only two commands:
	sm_saveloc
	sm_teleport
	
	This pluin can only save one location per client 
and the locations cannot be transfered to other clients.
This plugin is meant to be a small plugin for my personal
use and is therefore very bare-bones. Feel free to modify,
copy, or use any of this code where ever you want.

Uses SourceMod 1.6.3
*/

#include <sourcemod>
#include <sdktools>

//float vectors saving the positions, angles, and velocities of each client
//add one because client indexes start on 1 (0 is server)
new Float:posData[MAXPLAYERS+1][3];
new Float:angData[MAXPLAYERS+1][3];
new Float:velData[MAXPLAYERS+1][3];

//plugin info
public Plugin:myinfo =
{
	name = "TM_saveloc",
	author = "Time",
	description = "Location saver that retains velocity",
	version = "1.0",
	url = ""
};

public OnPluginStart()
{
	RegConsoleCmd("sm_saveloc", Command_SaveLoc);
	RegConsoleCmd("sm_teleport", Command_Teleport);
}
public OnMapEnd()
{
	//reset each client locations
	for(new i = 1; i<=MAXPLAYERS; i++)
	{
		resetData(i);
	}
}

//command callbacks
public Action:Command_SaveLoc(client, args)
{
	//check if player is alive
	if(client>0&&IsPlayerAlive(client))
	{
		GetClientAbsOrigin(client, posData[client]);//save position
		GetClientAbsAngles(client, angData[client]);//save angles
		GetClientVelocity(client, velData[client]);//save velocity - internal
		
		//debug
		//PrintToConsole(client, "save vel: %f, %f, %f", 
			//velData[client][0],velData[client][1],velData[client][2]);
		
		PrintToChat(client, "location saved");//notify client
	}
	else//print out error and exit
	{
		PrintToChat(client, "saveloc: must be alive");
	}
	return Plugin_Handled;
}
public Action:Command_Teleport(client, args)
{
	//check if player is alive
	if(client>0&&IsPlayerAlive(client))
	{
		//check if any location was saved
		if((GetVectorDistance(posData[client],NULL_VECTOR) > 0.00)&&
		   (GetVectorDistance(angData[client],NULL_VECTOR) > 0.00))
		{
			new Float:vel[3];
			TeleportEntity(client, posData[client], angData[client], velData[client]);
			GetClientVelocity(client,vel);
			
			//debug
			//PrintToConsole(client, "tele vel: %f, %f, %f", vel[0],vel[1],vel[2]);
		}
		else//print error and exit
		{
			PrintToChat(client, "No Location Saved");
		}
	}
	else//print error and exit
	{
		PrintToChat(client,"teleport: must be alive");
	}
	return Plugin_Handled;
}
GetClientVelocity(client, Float:vel[3])
{
	//dig into the entity properties for the client
	vel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	vel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	vel[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
}
resetData(client)
{
	posData[client] = NULL_VECTOR;
	angData[client] = NULL_VECTOR;
	velData[client] = NULL_VECTOR;
}