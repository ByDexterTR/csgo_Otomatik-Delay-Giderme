#include <sourcemod>
#include <warden>
#include <basecomm>
/*
#include <dexter>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <multicolors>
#include <devzones>
#include <clientprefs>
#include <customplayerskins>
#include <overlays>
#include <store>
#include <emitsoundany>
*/

/*
	HookEvent("round_start", RoundStart);   
	HookEvent("round_end", RoundEnd);
	HookEvent("player_spawn", OnClientSpawn);
	HookEvent("player_death", OnClientDead);
	HookEvent("player_hurt", OnClientHurt);
	HookEvent("weapon_fire", WeaponFire);
*/

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Komutçu Otomatik Delay Giderme", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

Handle Delaytimer[MAXPLAYERS + 1] = null;
ConVar delay_sure = null;

public void OnPluginStart()
{
	AddCommandListener(Control_ExitWarden, "sm_uw");
	AddCommandListener(Control_ExitWarden, "sm_unwarden");
	AddCommandListener(Control_ExitWarden, "sm_uc");
	AddCommandListener(Control_ExitWarden, "sm_uncommander");
	RegConsoleCmd("sm_delay", Command_Delay);
	delay_sure = CreateConVar("sm_delay_timer", "5", "Kaç dakika arayla komutçuya sorsun delay giderilsin mi diye?", FCVAR_NOTIFY, true, 1.0);
}

public Action Control_ExitWarden(int client, const char[] command, int argc)
{
	if (warden_iswarden(client))
	{
		if (Delaytimer[client] != null)
		{
			delete Delaytimer[client];
			Delaytimer[client] = null;
		}
	}
}

public Action Command_Delay(int client, int args)
{
	if (warden_iswarden(client))
	{
		if (Delaytimer[client] != null)
		{
			delete Delaytimer[client];
			Delaytimer[client] = null;
		}
		Menu menu = new Menu(Menu_Callback);
		menu.SetTitle("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\n^-^ Delay Giderilsin mi?\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\n ");
		menu.AddItem("evet", "Evet Delay giderilsin!");
		menu.AddItem("hayir", "Hayır Delay giderilmesin!");
		menu.ExitBackButton = false;
		menu.ExitButton = false;
		menu.Display(client, MENU_TIME_FOREVER);
		return Plugin_Handled;
	}
	else
	{
		ReplyToCommand(client, "[SM] \x01Bu komutu sadece komutçu kullanabilir!");
		return Plugin_Handled;
	}
}

public void warden_OnWardenCreated(int client)
{
	Delaytimer[client] = CreateTimer(delay_sure.FloatValue * 60.0, DelaySOR, client, TIMER_FLAG_NO_MAPCHANGE);
}

public void warden_OnWardenRemoved(int client)
{
	if (warden_iswarden(client))
	{
		if (Delaytimer[client] != null)
		{
			delete Delaytimer[client];
			Delaytimer[client] = null;
		}
	}
}

public Action DelaySOR(Handle timer, int client)
{
	FakeClientCommand(client, "sm_delay");
}

public Action Delaykaldir(Handle timer, int client)
{
	BaseComm_SetClientMute(client, false);
	PrintToChatAll("[SM] \x01Komutçunun delayı \x04giderildi!");
	PrintHintTextToAll("Komutçunun delayı giderildi!");
	Delaytimer[client] = CreateTimer(delay_sure.FloatValue * 60.0, DelaySOR, client, TIMER_FLAG_NO_MAPCHANGE);
	PrintToChat(client, "[SM] \x04%d dakika \x01sonra sorucam sana", delay_sure.IntValue);
}

public int Menu_Callback(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select)
	{
		char Item[32];
		menu.GetItem(select, Item, sizeof(Item));
		if (StrEqual(Item, "evet", true))
		{
			BaseComm_SetClientMute(client, true);
			CreateTimer(3.0, Delaykaldir, client, TIMER_FLAG_NO_MAPCHANGE);
			PrintToChatAll("[SM] \x01Komutçunun delayı \x0Cgideriliyor!");
		}
		else if (StrEqual(Item, "hayir", true))
		{
			Delaytimer[client] = CreateTimer(delay_sure.FloatValue * 60.0, DelaySOR, client, TIMER_FLAG_NO_MAPCHANGE);
			PrintToChat(client, "[SM] \x04%d dakika \x01sonra sorucam sana", delay_sure.IntValue);
		}
		delete menu;
	}
} 