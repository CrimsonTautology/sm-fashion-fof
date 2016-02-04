/**
 * vim: set ts=4 :
 * =============================================================================
 * fashion_fof
 * The Dress-up simmulator for Fistful of Frags that no one wanted.
 *
 * Copyright 2015 CrimsonTautology
 * =============================================================================
 *
 */

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "0.1"
#define PLUGIN_NAME "[FoF] Fashion"

public Plugin:myinfo =
{
    name = PLUGIN_NAME,
    author = "CrimsonTautology",
    description = "Customize the player models for Fistful of Frags",
    version = PLUGIN_VERSION,
    url = "https://github.com/CrimsonTautology/fashion_fof"
};

#define MAX_SKINS 3
#define MAX_BODY_GROUPS 512

new bool:g_IsFashionEnabled[MAXPLAYERS+1] = {false, ...};

new g_Skin[MAXPLAYERS+1]      = {0, ...};
new g_BodyGroup[MAXPLAYERS+1] = {0, ...};

new g_Model_Ghost;
new g_Model_Skeleton;
new g_Model_test1;
new g_Model_test2;

new Handle:g_Cvar_Enabled = INVALID_HANDLE;

public OnPluginStart()
{
    CreateConVar("sm_fashion_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_PLUGIN | FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
    g_Cvar_Enabled = CreateConVar("sm_fashion_enabled", "1", "Enabled");

    RegConsoleCmd("sm_fashion", Command_Fashion, "Randomize client's fashion");
    RegAdminCmd("sm_test1", Command_Test, ADMFLAG_SLAY, "TEST");//TODO
    RegAdminCmd("sm_test2", Command_Test2, ADMFLAG_SLAY, "TEST");//TODO
    RegAdminCmd("sm_test3", Command_Test3, ADMFLAG_SLAY, "TEST");//TODO
    RegAdminCmd("sm_test4", Command_Test4, ADMFLAG_SLAY, "TEST");//TODO
    RegAdminCmd("sm_test5", Command_Test5, ADMFLAG_SLAY, "TEST");//TODO
    RegAdminCmd("sm_test6", Command_Test6, ADMFLAG_SLAY, "TEST");//TODO

    HookEvent("player_spawn", Event_PlayerSpawn);

    AutoExecConfig();
}

public OnClientConnected(client)
{
    //TODO default to false
    g_IsFashionEnabled[client] = true;

    //g_Skin[client]      = 0;
    //g_BodyGroup[client] = 0;
    RandomizeClientFashion(client);
}

public OnMapStart()
{
    g_Model_Ghost = PrecacheModel("models/npc/ghost.mdl");
    g_Model_Skeleton = PrecacheModel("models/skeleton.mdl");
    g_Model_test1 = PrecacheModel("models/humans/corpse1.mdl");
    g_Model_test2 = PrecacheModel("models/humans/group03/female_01.mdl");
}

public Action:Command_Fashion(client, args)
{
    if(client)
    {
        RandomizeClientFashion(client);
    }

    return Plugin_Handled;
}

//TODO
public Action:Command_Test(client, args)
{
    if(client)
    {
        decl String:model[256];
        GetClientModel(client, model, sizeof(model));
        PrintToChat(client, "%s", model);
    }

    return Plugin_Handled;
}
public Action:Command_Test2(client, args)
{
    if(client)
    {
        decl String:path[256];
        GetCmdArgString(path, sizeof(path));
        new index = StringToInt(path);
        SetClientModelIndex(client, index);
    }

    return Plugin_Handled;
}

public Action:Command_Test3(client, args)
{
    if(client)
    {
        SetClientModelIndex(client, g_Model_Ghost);
    }

    return Plugin_Handled;
}

public Action:Command_Test4(client, args)
{
    if(client)
    {
        SetClientModelIndex(client, g_Model_Skeleton);
    }

    return Plugin_Handled;
}

public Action:Command_Test5(client, args)
{
    if(client)
    {
        SetClientModelIndex(client, g_Model_test1);
    }

    return Plugin_Handled;
}

public Action:Command_Test6(client, args)
{
    if(client)
    {
        SetClientModelIndex(client, g_Model_test2);
    }

    return Plugin_Handled;
}


public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event, "userid"));

    if(!IsFashionEnabled()) return;
    if(!IsFashionEnabledForClient(client)) return;

    CreateTimer(0.0, DelaySpawn, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action:DelaySpawn(Handle:Timer, any:userid)
{
    new client = GetClientOfUserId(userid);
    if( !(0 < client < MaxClients)) return Plugin_Stop;

    //PrintToConsole(0, "Hit spawn %d: skin %d, body %d", client, g_Skin[client], g_BodyGroup[client]);
    SetClientSkin(client, g_Skin[client]);
    SetClientBodyGroup(client, g_BodyGroup[client]);

    return Plugin_Stop;
}

bool:IsFashionEnabled()
{
    return GetConVarBool(g_Cvar_Enabled);
}

bool:IsFashionEnabledForClient(client)
{
    return g_IsFashionEnabled[client];
}

RandomizeClientFashion(client)
{
    new skin = GetRandomInt(0, MAX_SKINS - 1);
    g_Skin[client] = skin;
    //SetClientSkin(client, skin);

    new body_group = GetRandomInt(1, MAX_BODY_GROUPS - 1);
    g_BodyGroup[client] = body_group;
    //SetClientBodyGroup(client, body_group);
}

SetClientSkin(client, skin)
{
    SetEntProp(client, Prop_Data, "m_nSkin", skin);
}

SetClientBodyGroup(client, body_group)
{
    SetEntProp(client, Prop_Data, "m_nBody", body_group);
}

SetClientModelIndex(client, index)
{
    SetEntProp(client, Prop_Data, "m_nModelIndex", index, 2);
}
