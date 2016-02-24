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

 masks
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
#define MAX_MASKS 3
#define MAX_HATS 8
#define MAX_BODY_GROUPS 512

#define HAT_OFFSET 2
#define MASK_OFFSET 16

new bool:g_IsFashionEnabled[MAXPLAYERS+1] = {false, ...};

new g_Skin[MAXPLAYERS+1]      = {0, ...};
new g_Hat[MAXPLAYERS+1] = {0, ...};
new g_Mask[MAXPLAYERS+1] = {0, ...};

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

    g_Skin[client] = 0;
    g_Hat[client] = 0;
    g_Mask[client] = 0;
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

    RecalculateFashion(client);

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

    new mask = GetRandomInt(0, MAX_MASKS - 1);
    g_Mask[client] = mask;

    new hat = GetRandomInt(0, MAX_HATS - 1);
    g_Hat[client] = hat;
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

GetClientModelIndex(client)
{
    return GetEntProp(client, Prop_Data, "m_nModelIndex");
}

SetClientModelIndex(client, index)
{
    SetEntProp(client, Prop_Data, "m_nModelIndex", index, 2);
}

RecalculateFashion(client)
{
    new hat = g_Hat[client];
    new mask = g_Mask[client];
    new skin = g_Skin[client];
    new model = GetClientModelIndex(client);

    //Bandidos and rangers can not have non-default skins
    if(model == g_Model_Bandido || model == g_Model_Ranger)
    {
        skin = 0;
    }

    SetClientSkin(client, skin);
    SetClientBodyGroup(client, (hat * HAT_OFFSET) + (mask * MASK_OFFSET));
}



//Menus
ShowFashionMenu(client)
{
    new Handle:menu = CreateMenu(FashionMenuSelected);
    SetMenuTitle(menu,"Fistful of Fashion");

    AddMenuItem(menu, "1", "Hat", ITEMDRAW_DEFAULT);
    AddMenuItem(menu, "2", "Mask", ITEMDRAW_DEFAULT);
    AddMenuItem(menu, "3", "Clothes", ITEMDRAW_DEFAULT);
    AddMenuItem(menu, "4", "Model", ITEMDRAW_DEFAULT);

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
                    case 2: { ChangeMaskMenu(client); }
                    case 3: { ChangeClothesMenu(client); }
                    case 4: { ChangeModelMenu(client); }

                }
            }
        case MenuAction_End: CloseHandle(menu);
    }
}

public ChangeHatMenu(client)
{
    new Handle:menu = CreateMenu(ChangeHatMenuHandler);
    new selected = g_Hat[client];

    SetMenuTitle(menu, "Choose Your Hat");

    AddMenuItem(menu , "0"  , "None", 0 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    AddMenuItem(menu , "1"  , "Bronson", 1 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    AddMenuItem(menu , "2"  , "Van Cleef", 2 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    AddMenuItem(menu , "3"  , "Marvin", 3 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    AddMenuItem(menu , "4"  , "Eastwood", 4 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    AddMenuItem(menu , "5"  , "Wayne", 5 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    AddMenuItem(menu , "6"  , "Tuco", 6 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    AddMenuItem(menu , "7"  , "Lincoln", 7 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

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
                RecalculateFashion(client);
            }
        case MenuAction_End: CloseHandle(menu);
    }
}

public ChangeMaskMenu(client)
{
    new Handle:menu = CreateMenu(ChangeMaskMenuHandler);
    new selected = g_Mask[client];

    SetMenuTitle(menu, "Choose Your Mask");

    AddMenuItem(menu , "0"  , "None", 0 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    AddMenuItem(menu , "1"  , "White", 1 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    AddMenuItem(menu , "2"  , "Black", 2 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

    SetMenuPagination(menu, MENU_NO_PAGINATION);

    DisplayMenu(menu, client, 20);
}

public ChangeMaskMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
    switch (action)
    {
        case MenuAction_Select:
            {
                new client = param1;
                new String:info[32];
                GetMenuItem(menu, param2, info, sizeof(info));
                g_Mask[client] = StringToInt(info);
                RecalculateFashion(client);
            }
        case MenuAction_End: CloseHandle(menu);
    }
}

public ChangeClothesMenu(client)
{
    new Handle:menu = CreateMenu(ChangeClothesMenuHandler);
    new selected = g_Skin[client];

    SetMenuTitle(menu, "Choose your clothes");

    AddMenuItem(menu , "0"  , "Buono", 0 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    AddMenuItem(menu , "1"  , "Brutto", 1 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    AddMenuItem(menu , "2"  , "Cattivo", 2 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

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
                new client = param1;
                g_Skin[client] = StringToInt(info);
                RecalculateFashion(client);
            }
        case MenuAction_End: CloseHandle(menu);
    }
}

public ChangeModelMenu(client)
{
    new Handle:menu = CreateMenu(ChangeModelMenuHandler);
    SetMenuTitle(menu, "Choose your Model");

    AddMenuItem(menu , "0"  , "Vigilante");
    AddMenuItem(menu , "1"  , "Desperado");
    AddMenuItem(menu , "2"  , "Bandido");
    AddMenuItem(menu , "3"  , "Ranger");
    AddMenuItem(menu , "4"  , "Ghost");
    AddMenuItem(menu , "5"  , "Skeleton");

    SetMenuPagination(menu, MENU_NO_PAGINATION);

    DisplayMenu(menu, client, 20);
}

public ChangeModelMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
    switch (action)
    {
        case MenuAction_Select:
            {
                new String:info[32];
                GetMenuItem(menu, param2, info, sizeof(info));
                new model = StringToInt(info);
                new client = param1;

                switch (model)
                {
                    case 0: { SetClientModelIndex(client, g_Model_Vigilante); }
                    case 1: { SetClientModelIndex(client, g_Model_Desperado); }
                    case 2: { SetClientModelIndex(client, g_Model_Bandido); }
                    case 3: { SetClientModelIndex(client, g_Model_Ranger); }
                    case 4: { SetClientModelIndex(client, g_Model_Ghost); }
                    case 5: { SetClientModelIndex(client, g_Model_Skeleton); }
                }

            }
        case MenuAction_End: CloseHandle(menu);
    }
}
