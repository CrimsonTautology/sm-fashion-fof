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

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <clientprefs>

#define PLUGIN_VERSION "1.10.1"
#define PLUGIN_NAME "[FoF] Fashion"

public Plugin myinfo =
{
    name = PLUGIN_NAME,
    author = "CrimsonTautology",
    description = "Customize the player models for Fistful of Frags",
    version = PLUGIN_VERSION,
    url = "https://github.com/CrimsonTautology/sm-fashion-fof"
};

int g_VigilanteModelIndex;
int g_DesperadoModelIndex;
int g_BandidoModelIndex;
int g_RangerModelIndex;
int g_GhostModelIndex;
int g_SkeletonModelIndex;
int g_ZombieModelIndex;

#include "fashion/clients.sp"
#include "fashion/menus.sp"

ConVar g_EnabledCvar;
ConVar g_TeamplayCvar;

public void OnPluginStart()
{
    CreateConVar("sm_fashion_version", PLUGIN_VERSION, PLUGIN_NAME,
            FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
    g_EnabledCvar = CreateConVar("sm_fashion_enabled", "1", "Enabled");
    g_TeamplayCvar = FindConVar("mp_teamplay");

    RegConsoleCmd("sm_fashion", Command_Fashion, "Change your Style");

    HookEvent("player_spawn", Event_PlayerSpawn);

    g_ClothesCookie = new Cookie("fashion_clothes", "Selected player clothes",
            CookieAccess_Private);
    g_HatCookie = new Cookie("fashion_hat", "Selected player hat",
            CookieAccess_Private);
    g_MaskCookie = new Cookie("fashion_mask", "Selected player mask",
            CookieAccess_Private);
    g_WasRandomizedCookie = new Cookie("fashion_was_randomized",
            "Was this client auto randomized", CookieAccess_Private);

    AutoExecConfig();
}

public void OnClientCookiesCached(int client)
{
    FashionableClient fclient = FashionableClient(client);
    fclient.LoadFromCookies();
}

public void OnMapStart()
{
    g_VigilanteModelIndex = PrecacheModel("models/playermodels/player1.mdl");
    g_DesperadoModelIndex = PrecacheModel("models/playermodels/player2.mdl");
    g_BandidoModelIndex = PrecacheModel("models/playermodels/bandito.mdl");
    g_RangerModelIndex = PrecacheModel("models/playermodels/frank.mdl");
    g_GhostModelIndex = PrecacheModel("models/npc/ghost.mdl");
    g_SkeletonModelIndex = PrecacheModel("models/skeleton.mdl");
    g_ZombieModelIndex = PrecacheModel("models/zombies/fof_zombie.mdl");
}

Action Command_Fashion(int client, int args)
{
    if(!(0 < client <= MaxClients)) return Plugin_Handled;

    FashionableClient fclient = FashionableClient(client);
    ShowFashionMenu(fclient);

    return Plugin_Handled;
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    if(!IsFashionEnabled()) return;

    int userid = event.GetInt("userid");
    RequestFrame(PlayerSpawnDelay, userid);
}

void PlayerSpawnDelay(int userid)
{
    int client = GetClientOfUserId(userid);
    if(!(0 < client <= MaxClients)) return;

    FashionableClient fclient = FashionableClient(client);
    fclient.Refresh();
}

bool IsFashionEnabled()
{
    return g_EnabledCvar.BoolValue;
}

bool IsModelEnabled()
{
    // do not allow change of model when in a teamplay gamemode
    return !g_TeamplayCvar.BoolValue;
}
