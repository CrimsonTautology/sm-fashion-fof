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

 /*
 default 16

 hats
 none +0
 black +2
 white +4
 derby +6
 black whitestripe +8
 gray +10
 sombraro +12
 top hat +14

 bandanas
 none +0
 white +16
 black +32
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

#define HAT_OFFSET 2
#define BANDANA_OFFSET 16

new bool:g_IsFashionEnabled[MAXPLAYERS+1] = {false, ...};

new g_Skin[MAXPLAYERS+1]      = {0, ...};
new g_BodyGroup[MAXPLAYERS+1] = {0, ...};
new g_Hat[MAXPLAYERS+1] = {0, ...};
new g_Bandana[MAXPLAYERS+1] = {0, ...};

new g_Model_Vigilante;
new g_Model_Desperado;
new g_Model_Bandido;
new g_Model_Ranger;
new g_Model_Ghost;
new g_Model_Skeleton;

new Handle:g_Cvar_Enabled = INVALID_HANDLE;

public OnPluginStart()
{
    CreateConVar("sm_fashion_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_PLUGIN | FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
    g_Cvar_Enabled = CreateConVar("sm_fashion_enabled", "1", "Enabled");

    RegConsoleCmd("sm_fashion", Command_Fashion, "Change your Style");
    RegAdminCmd("sm_test1", Command_Test, ADMFLAG_SLAY, "TEST");//TODO
    RegAdminCmd("sm_test2", Command_Test2, ADMFLAG_SLAY, "TEST");//TODO

    HookEvent("player_spawn", Event_PlayerSpawn);

    AutoExecConfig();
}

public OnClientConnected(client)
{
    //TODO default to false
    g_IsFashionEnabled[client] = true;

    //g_Skin[client]      = 0;
    //g_BodyGroup[client] = 0;
    //RandomizeClientFashion(client);

    g_Hat[client] = 0;
    g_Bandana[client] = 0;
}

public OnMapStart()
{
    g_Model_Vigilante = PrecacheModel("models/playermodels/player1.mdl");
    g_Model_Desperado = PrecacheModel("models/playermodels/player2.mdl");
    g_Model_Bandido = PrecacheModel("models/playermodels/bandito.mdl");
    g_Model_Ranger = PrecacheModel("models/playermodels/frank.mdl");
    g_Model_Ghost = PrecacheModel("models/npc/ghost.mdl");
    g_Model_Skeleton = PrecacheModel("models/skeleton.mdl");
}

public Action:Command_Fashion(client, args)
{
    if(client)
    {
        //RandomizeClientFashion(client);
        ShowFashionMenu(client);
    }

    return Plugin_Handled;
}

public Action:Command_Test(client, args)
{
    if(client)
    {
        new body_group = GetClientBodyGroup(client);
        body_group += 2;
        SetClientBodyGroup(client, body_group);

        PrintToChat(client, "%s", body_group);
    }

    return Plugin_Handled;
}

public Action:Command_Test2(client, args)
{
    if(client)
    {
        new body_group = GetClientBodyGroup(client);
        body_group -= 2;
        SetClientBodyGroup(client, body_group);

        PrintToChat(client, "%s", body_group);
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
    RecalculateBodyGroup(client);

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

GetClientBodyGroup(client)
{
    return GetEntProp(client, Prop_Data, "m_nBody");
}

SetClientBodyGroup(client, body_group)
{
    SetEntProp(client, Prop_Data, "m_nBody", body_group);
}

RecalculateBodyGroup(client)
{
    new hat = g_Hat[client];
    new bandana = g_Bandana[client];
    SetClientBodyGroup(client, (hat * HAT_OFFSET) + (bandana * BANDANA_OFFSET));
}

SetClientModelIndex(client, index)
{
    SetEntProp(client, Prop_Data, "m_nModelIndex", index, 2);
}


//Menus
ShowFashionMenu(client)
{
    new Handle:menu = CreateMenu(FashionMenuSelected);
    SetMenuTitle(menu,"Fistful of Fashion");

    AddMenuItem(menu, "1", "Hat", ITEMDRAW_DEFAULT);
    AddMenuItem(menu, "2", "Bandana", ITEMDRAW_DEFAULT);
    AddMenuItem(menu, "3", "Clothes", ITEMDRAW_DEFAULT);
    //AddMenuItem(menu, 4, "Skin", ITEMDRAW_DEFAULT);

    DisplayMenu(menu, client, 20);
}

public FashionMenuSelected(Handle:menu, MenuAction:action, param1, param2)
{
    decl String:tmp[32], selected;
    GetMenuItem(menu, param2, tmp, sizeof(tmp));
    selected = StringToInt(tmp);
    new client = param1;

    switch (action)
    {
        case MenuAction_Select:
            {
                switch (selected)
                {
                    case 1: { ChangeHatMenu(client); }
                    case 2: { ChangeBandanaMenu(client); }
                    case 3: { ChangeClothesMenu(client); }
                    //case 4: { ChangeSkinMenu(client); }

                }
            }
        case MenuAction_End: CloseHandle(menu);
    }
}

public ChangeHatMenu(client)
{
    new Handle:menu = CreateMenu(ChangeHatMenuHandler);
    SetMenuTitle(menu, "Choose your hat");

    AddMenuItem(menu , "0"  , "None");
    AddMenuItem(menu , "1"  , "Bronson");
    AddMenuItem(menu , "2"  , "Van Cleef");
    AddMenuItem(menu , "3"  , "Marvin");
    AddMenuItem(menu , "4"  , "Eastwood");
    AddMenuItem(menu , "5"  , "Wayne");
    AddMenuItem(menu , "6"  , "Tuco");
    AddMenuItem(menu , "7"  , "Lincoln");

    SetMenuPagination(menu, MENU_NO_PAGINATION);


    DisplayMenu(menu, client, 20);
}

public ChangeHatMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
    switch (action)
    {
        case MenuAction_Select:
            {
                new client = param1;
                new String:info[32];
                GetMenuItem(menu, param2, info, sizeof(info));
                g_Hat[client] = StringToInt(info);
                RecalculateBodyGroup(client);
            }
        case MenuAction_End: CloseHandle(menu);
    }
}

public ChangeBandanaMenu(client)
{
    new Handle:menu = CreateMenu(ChangeBandanaMenuHandler);
    SetMenuTitle(menu, "Choose your bandana");

    AddMenuItem(menu , "0"  , "None");
    AddMenuItem(menu , "1"  , "White");
    AddMenuItem(menu , "2"  , "Black");

    SetMenuPagination(menu, MENU_NO_PAGINATION);

    DisplayMenu(menu, client, 20);
}

public ChangeBandanaMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
    switch (action)
    {
        case MenuAction_Select:
            {
                new client = param1;
                new String:info[32];
                GetMenuItem(menu, param2, info, sizeof(info));
                g_Bandana[client] = StringToInt(info);
                RecalculateBodyGroup(client);
            }
        case MenuAction_End: CloseHandle(menu);
    }
}

public ChangeClothesMenu(client)
{
    new Handle:menu = CreateMenu(ChangeClothesMenuHandler);
    SetMenuTitle(menu, "Choose your clothes");

    AddMenuItem(menu , "0"  , "Style 1");
    AddMenuItem(menu , "1"  , "Style 2");
    AddMenuItem(menu , "2"  , "Style 3");

    SetMenuPagination(menu, MENU_NO_PAGINATION);

    DisplayMenu(menu, client, 20);
}

public ChangeClothesMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
    switch (action)
    {
        case MenuAction_Select:
            {
                new String:info[32];
                GetMenuItem(menu, param2, info, sizeof(info));
                new skin = StringToInt(info);
                new client = param1;
                SetClientSkin(client, skin);
                PrintToServer("hit changeclothes %d", skin);
            }
        case MenuAction_End: CloseHandle(menu);
    }
}
