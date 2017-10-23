/**
 * vim: set ts=4 :
 * =============================================================================
 * fashion_fof
 * The Dress-up simulator for Fistful of Frags that no one wanted.
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
#include <clientprefs>

#define PLUGIN_VERSION "1.0.2"
#define PLUGIN_NAME "[FoF] Fashion"

public Plugin:myinfo =
{
    name = PLUGIN_NAME,
    author = "CrimsonTautology",
    description = "Customize the player models for Fistful of Frags",
    version = PLUGIN_VERSION,
    url = "https://github.com/CrimsonTautology/sm_fashion_fof"
};

#define MAX_CLOTHES 3
#define MAX_MASKS 3
#define MAX_HATS 8
#define MAX_MODELS 6

#define HAT_OFFSET 2
#define MASK_OFFSET 16

new g_Clothes[MAXPLAYERS+1] = {0, ...};
new g_Hat[MAXPLAYERS+1]     = {0, ...};
new g_Mask[MAXPLAYERS+1]    = {0, ...};

new Handle:g_Cookie_Clothes       = INVALID_HANDLE;
new Handle:g_Cookie_Hat           = INVALID_HANDLE;
new Handle:g_Cookie_Mask          = INVALID_HANDLE;
new Handle:g_Cookie_WasRandomized = INVALID_HANDLE;


new g_Model_Vigilante;
new g_Model_Desperado;
new g_Model_Bandido;
new g_Model_Ranger;
new g_Model_Ghost;
new g_Model_Skeleton;
new g_Model_Zombie;

new Handle:g_Cvar_Enabled = INVALID_HANDLE;
new Handle:g_Cvar_Teamplay = INVALID_HANDLE;

public OnPluginStart()
{
    CreateConVar("sm_fashion_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
    g_Cvar_Enabled = CreateConVar("sm_fashion_enabled", "1", "Enabled");
    g_Cvar_Teamplay = FindConVar("mp_teamplay");

    RegConsoleCmd("sm_fashion", Command_Fashion, "Change your Style");

    HookEvent("player_spawn", Event_PlayerSpawn);

    g_Cookie_Clothes = RegClientCookie("fashion_clothes", "Selected player clothes", CookieAccess_Private);
    g_Cookie_Hat  = RegClientCookie("fashion_hat",  "Selected player hat",  CookieAccess_Private);
    g_Cookie_Mask = RegClientCookie("fashion_mask", "Selected player mask", CookieAccess_Private);
    g_Cookie_WasRandomized = RegClientCookie("fashion_was_randomized", "Was this client auto randomized", CookieAccess_Private);

    AutoExecConfig();
}

public OnClientCookiesCached(client)
{
    new String:buffer[11];
    new type_of;

    GetClientCookie(client, g_Cookie_Clothes, buffer, sizeof(buffer));
    type_of = StringToInt(buffer);
    if (strlen(buffer) > 0 && type_of < MAX_CLOTHES){
        g_Clothes[client] = type_of;
    }else{
        g_Clothes[client] = 0;
    }

    GetClientCookie(client, g_Cookie_Hat, buffer, sizeof(buffer));
    type_of = StringToInt(buffer);
    if (strlen(buffer) > 0 && type_of < MAX_HATS){
        g_Hat[client] = type_of;
    }else{
        g_Hat[client] = 0;
    }

    GetClientCookie(client, g_Cookie_Mask, buffer, sizeof(buffer));
    type_of = StringToInt(buffer);
    if (strlen(buffer) > 0 && type_of < MAX_MASKS){
        g_Mask[client] = type_of;
    }else{
        g_Mask[client] = 0;
    }

    GetClientCookie(client, g_Cookie_WasRandomized, buffer, sizeof(buffer));
    if (!bool:StringToInt(buffer)){
        RandomizeClientFashion(client);
    }
}


public OnMapStart()
{
    g_Model_Vigilante = PrecacheModel("models/playermodels/player1.mdl");
    g_Model_Desperado = PrecacheModel("models/playermodels/player2.mdl");
    g_Model_Bandido = PrecacheModel("models/playermodels/bandito.mdl");
    g_Model_Ranger = PrecacheModel("models/playermodels/frank.mdl");
    g_Model_Ghost = PrecacheModel("models/npc/ghost.mdl");
    g_Model_Skeleton = PrecacheModel("models/skeleton.mdl");
    g_Model_Zombie = PrecacheModel("models/zombies/fof_zombie.mdl");
}

public Action:Command_Fashion(client, args)
{
    if(client)
    {
        ShowFashionMenu(client);
    }

    return Plugin_Handled;
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event, "userid"));

    if(!IsFashionEnabled()) return;

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

RandomizeModel(client)
{
    new model = GetRandomInt(0, MAX_MODELS - 1);

    switch (model)
    {
        case 0: { SetClientModelIndex(client, g_Model_Vigilante); }
        case 1: { SetClientModelIndex(client, g_Model_Desperado); }
        case 2: { SetClientModelIndex(client, g_Model_Bandido); }
        case 3: { SetClientModelIndex(client, g_Model_Ranger); }
        case 4: { SetClientModelIndex(client, g_Model_Ghost); }
        case 5: { SetClientModelIndex(client, g_Model_Skeleton); }
        case 6: { SetClientModelIndex(client, g_Model_Zombie); }
    }
}

RandomizeClientFashion(client)
{
    new clothes = GetRandomInt(0, MAX_CLOTHES - 1);
    SetClothes(client, clothes);

    new mask = GetRandomInt(0, MAX_MASKS - 1);
    SetMask(client, mask);

    new hat = GetRandomInt(0, MAX_HATS - 1);
    SetHat(client, hat);

    SetClientCookie(client, g_Cookie_WasRandomized, "1");
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

SetHat(client, hat)
{
    if(hat < 0 || hat >= MAX_HATS) return;

    new String:tmp[11];
    IntToString(hat, tmp, sizeof(tmp));

    g_Hat[client] = hat;
    SetClientCookie(client, g_Cookie_Hat, tmp);
}

SetMask(client, mask)
{
    if(mask < 0 || mask >= MAX_MASKS) return;

    new String:tmp[11];
    IntToString(mask, tmp, sizeof(tmp));

    g_Mask[client] = mask;
    SetClientCookie(client, g_Cookie_Mask, tmp);
}

SetClothes(client, clothes)
{
    if(clothes < 0 || clothes >= MAX_CLOTHES) return;

    new String:tmp[11];
    IntToString(clothes, tmp, sizeof(tmp));

    g_Clothes[client] = clothes;
    SetClientCookie(client, g_Cookie_Clothes, tmp);
}

RecalculateFashion(client)
{
    new hat = g_Hat[client];
    new mask = g_Mask[client];
    new clothes = g_Clothes[client];
    new model = GetClientModelIndex(client);

    //Bandidos and Rangers can not have non-default skins
    if(model == g_Model_Bandido || model == g_Model_Ranger)
    {
        clothes = 0;
    }

    //Vigilantes need to invert the first two hats
    if(model == g_Model_Vigilante && hat == 1)
    {
        hat = 2;
    }else if(model == g_Model_Vigilante && hat == 2)
    {
        hat = 1;
    }

    //Skeletons can only have one type of hat, and must be manually set
    if(model == g_Model_Skeleton && hat > 0)
    {
        SetClientSkin(client, clothes);
        SetClientBodyGroup(client, 1);
        return;
    }

    //Rangers can not have the first(white) hat but there is nothing to address here
    //Bandidos and Rangers can not have the second(black) mask but there is nothing to address here

    SetClientSkin(client, clothes);
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
    AddMenuItem(menu, "4", "Model", GetConVarBool(g_Cvar_Teamplay) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

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
    AddMenuItem(menu , "1"  , "Harmonica White", 1 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    AddMenuItem(menu , "2"  , "Angel Eyes Black", 2 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    AddMenuItem(menu , "3"  , "Wanderin' Star", 3 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    AddMenuItem(menu , "4"  , "The Hat With No Name", 4 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    AddMenuItem(menu , "5"  , "A Pilgrim's Silverbelly", 5 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    AddMenuItem(menu , "6"  , "Ugly Sombrero", 6 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    AddMenuItem(menu , "7"  , "Abe's Topper", 7 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

    SetMenuPagination(menu, MENU_NO_PAGINATION);
    SetMenuExitBackButton(menu, true);

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
                SetHat(client, StringToInt(info));
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
    SetMenuExitBackButton(menu, true);

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
                SetMask(client, StringToInt(info));
                RecalculateFashion(client);
            }
        case MenuAction_End: CloseHandle(menu);
    }
}

public ChangeClothesMenu(client)
{
    new Handle:menu = CreateMenu(ChangeClothesMenuHandler);
    new selected = g_Clothes[client];

    SetMenuTitle(menu, "Choose your clothes");

    AddMenuItem(menu , "0"  , "Buono", 0 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    AddMenuItem(menu , "1"  , "Brutto", 1 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    AddMenuItem(menu , "2"  , "Cattivo", 2 == selected ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

    SetMenuPagination(menu, MENU_NO_PAGINATION);
    SetMenuExitBackButton(menu, true);

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
                SetClothes(client, StringToInt(info));
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
    AddMenuItem(menu , "6"  , "Zombie");

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
                    case 6: { SetClientModelIndex(client, g_Model_Zombie); }
                }

            }
        case MenuAction_End: CloseHandle(menu);
    }
}
