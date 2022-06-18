#include <sourcemod>
#include <basecomm>
#include <warden>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Delay Giderme", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

Handle _timer;
ConVar delay_timer;

public void OnPluginStart()
{
	delay_timer = CreateConVar("sm_delay_timer", "10", "Kaç dakika arayla delay giderilmesi sorulsun?", 0, true, 1.0);
	RegConsoleCmd("sm_delay", Command_Delay);
	AutoExecConfig(true, "Delay-Giderme", "ByDexter");
}

public Action Command_Delay(int client, int args)
{
	if (!warden_iswarden(client) || !CheckCommandAccess(client, "sm_mute", ADMFLAG_CHAT))
	{
		ReplyToCommand(client, "[SM] Bu komuta erişiminiz yok.");
		return Plugin_Handled;
	}
	if (!warden_exist())
	{
		ReplyToCommand(client, "[SM] Komutçu bulunamadı.");
		return Plugin_Handled;
	}
	
	Menu menu = new Menu(Menu_callback);
	menu.SetTitle("Delay giderilsin mi?");
	menu.AddItem("0", "Evet");
	menu.AddItem("1", "Hayır");
	menu.ExitBackButton = false;
	menu.ExitButton = false;
	menu.Display(client, 10);
	return Plugin_Handled;
}

public int Menu_callback(Menu menu, MenuAction action, int client, int position)
{
	if (action == MenuAction_Select)
	{
		if (_timer != null)
		{
			delete _timer;
		}
		_timer = CreateTimer(delay_timer.FloatValue, DelaySor, _, TIMER_FLAG_NO_MAPCHANGE);
		char item[4];
		menu.GetItem(position, item, 4);
		if (StringToInt(item) == 0)
		{
			PrintCenterTextAll("Komutçunun delayı gideriliyor...");
			if (warden_iswarden(client))
			{
				PrintToChatAll("[SM] \x10%N\x01 delayının \x0Cgiderilmesini istedi.", client);
				BaseComm_SetClientMute(client, true);
			}
			else
			{
				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsValidClient(i) && warden_iswarden(i))
					{
						PrintToChatAll("[SM] \x10%N\x01 komutçunun delayının \x0Cgiderilmesini istedi.", client);
						BaseComm_SetClientMute(i, true);
					}
				}
			}
			CreateTimer(2.0, UnMute);
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action UnMute(Handle timer, any data)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && warden_iswarden(i))
		{
			BaseComm_SetClientMute(i, false);
			PrintToChatAll("[SM] \x04%d dakika\x01 sonra tekrar soracağım delayı", delay_timer.FloatValue);
		}
	}
	PrintCenterTextAll("Komutçunun delayı giderildi");
}

public void warden_OnWardenCreated(int client)
{
	if (_timer != null)
	{
		delete _timer;
	}
	_timer = CreateTimer(delay_timer.FloatValue, DelaySor, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action DelaySor(Handle timer, any data)
{
	_timer = null;
	if (warden_exist())
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && warden_iswarden(i))
			{
				Command_Delay(i, 0);
			}
		}
	}
}

bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
} 