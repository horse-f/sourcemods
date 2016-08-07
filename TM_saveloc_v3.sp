/*TM
	This plugin is meant to be a teleport save
system that will retain the client's velocity upon
saving their location. This is a very light plugin
with only two commands:
	sm_saveloc
	sm_teleport [#tele]
	
	This pluin can save multiple locations and the 
locations can be used to other clients. The last location
teleported to or saved by the client is used with sm_teleport
with no arguments. This plugin is meant to be a small 
plugin for my personaluse and is therefore very bare-bones. 
Feel free to modify, copy, or use any of this code where ever you want.

Uses SourceMod 1.6.3
*/

#include <sourcemod>
#include <sdktools>

#define MAXLOCS 512 //maximum locations that can be saved

//float vectors saving the positions, angles, and velocities of each client
//add one because client indexes start on 1 (0 is server)
new Float:posData[MAXLOCS][3];
new Float:angData[MAXLOCS][3];
new Float:velData[MAXLOCS][3];
new String:targetData[MAXLOCS][32];
new String:classData[MAXLOCS][32];


new clientLoc[MAXPLAYERS+1];//saves the last tp loc for the client
new index;//first available tele loc

//plugin info
public Plugin:myinfo =
{
	name = "TM_saveloc",
	author = "Time",
	description = "Location saver that retains velocity",
	version = "3",
	url = "https://github.com/horse-f/sourcemods"
};

public OnPluginStart()
{
	//reset client locsations on start
	for(new i=0;i<MAXPLAYERS+1;i++)
	{
		clientLoc[i]=-1;
	}
	RegConsoleCmd("sm_saveloc", Command_SaveLoc);
	RegConsoleCmd("sm_teleport", Command_Teleport);
	RegConsoleCmd("sm_tele", Command_Teleport);
}
public OnMapEnd()
{
	resetData();
}
//command callbacks
public Action:Command_SaveLoc(client, args)
{
	if(index<MAXLOCS-1)
	{
		GetClientAbsOrigin(client, posData[index]);//save position
		GetClientEyeAngles(client, angData[index]);//save angles
		GetClientVelocity(client, velData[index]);//save velocity - internal
		
		GetEntPropString(client, Prop_Data, "m_iName", targetData[index], 32);//save targetname
		ReplyToCommand(client, "Targetname: %s", targetData[index]);

		GetEdictClassname(client,classData[index],32);
		ReplyToCommand(client, "Classname: %s", classData[index]);
		
		clientLoc[client]=index;
		PrintToChat(client, "location saved: %d", index+1);//notify client
		index++;
	}
	else
	{
		PrintToChat(client, "maximum save locations reached");
	}
	//debug
	//PrintToConsole(client, "save vel: %f, %f, %f", 
		//velData[client][0],velData[client][1],velData[client][2]);
	
	return Plugin_Handled;
}
public Action:Command_Teleport(client, args)
{
	//check if player is alive
	if(client>0&&IsPlayerAlive(client))
	{
		if(args>=1)
		{
			new String:arg[32];
			new ind;//arg index specified
			
			//parse arg
			GetCmdArg(1,arg,sizeof(arg));
			ind = StringToInt(arg);
			if(ind<=0)
			{
				PrintToChat(client,"usage: sm_teleport #(>0)");
				return Plugin_Handled;
			}
			ind-=1;//indecies are offset by one for StoI error checking
			
			//check if loc saved
			if((GetVectorDistance(posData[ind],NULL_VECTOR,true) > 0.00)&&
			   (GetVectorDistance(angData[ind],NULL_VECTOR,true) > 0.00))
			{
				//teleport client
				TeleportClient(client,posData[ind],angData[ind],velData[ind],targetData[ind],classData[ind]);
				//set client location
				clientLoc[client]=ind;
				
				PrintToChat(client,"location set to: %d", ind+1);
			}
		}
		else
		{
			
			//check if any location was saved
			new ci = clientLoc[client];
			if((ci!=-1)&&(GetVectorDistance(posData[ci],NULL_VECTOR,true) > 0.00)&&
			   (GetVectorDistance(angData[ci],NULL_VECTOR,true) > 0.00))
			{
				//teleport client
				TeleportClient(client,posData[ci],angData[ci],velData[ci],targetData[ci],classData[ci]);
			}
			else//print error and exit
			{
				PrintToChat(client, "No Location Saved");
			}
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
	//dig into the entity properties for the client to get velocity
	vel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	vel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	vel[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
}
resetData()
{
	//reset all the data
	index=0;
	for(new i=0;i<MAXPLAYERS+1;i++)
	{
		clientLoc[i]=-1;
	}
	for(new i=0;i<MAXLOCS;i++)
	{
		posData[i]=NULL_VECTOR;
		angData[i]=NULL_VECTOR;
		velData[i]=NULL_VECTOR;
		targetData[i]="";
		classData[i]="";
	}
}
TeleportClient(client,Float:pos[3],Float:ang[3],Float:vel[3],String:targetname[32],String:classname[32]) 
{
	DispatchKeyValue(client, "targetname", targetname);
	DispatchKeyValue(client, "classname", classname);
	TeleportEntity(client, pos, ang, vel);
}