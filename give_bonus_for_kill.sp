#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Give Bonus For Kill", 
	author = "babka68", 
	description = "При убийстве противника игроку будет выдан бонус.", 
	version = "1.0", 
	url = "https://vk.com/zakazserver68"
};
bool bEnable;
int iKill_add_hp, iMaximum_health_value, m_iHealth;

public void OnPluginStart()
{
	if ((m_iHealth = FindSendPropInfo("CCSPlayer", "m_iHealth")) == -1)
	{
		SetFailState("CCSPlayer::m_iHealth");
	}
	
	ConVar cvar;
	cvar = CreateConVar("sm_enable_kill_bonus", "1", "1 - Вкл, 0 - Выкл плагин.", _, true, 0.0, true, 1.0);
	cvar.AddChangeHook(CVarChanged_Enable_Kill_Bonus);
	bEnable = cvar.BoolValue;
	
	cvar = CreateConVar("sm_kill_add_hp", "10", "Сколько добавлять HP за убийство", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_Kill_Add_Hp);
	iKill_add_hp = cvar.IntValue;
	
	cvar = CreateConVar("sm_maximum_healt_value", "127", "Максимальное значение здоровья.", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_Maximum_Health_Value);
	iMaximum_health_value = cvar.IntValue;
	
	HookEvent("player_death", Event_Player_Death); // Ловим событие смерти игрока
}

public void CVarChanged_Enable_Kill_Bonus(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	bEnable = cvar.BoolValue;
}

public void CVarChanged_Kill_Add_Hp(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	iKill_add_hp = cvar.IntValue;
}

public void CVarChanged_Maximum_Health_Value(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	iMaximum_health_value = cvar.IntValue;
}

public void Event_Player_Death(Handle event, const char[] name, bool silent)
{
	if (bEnable)
	{
		int iClient = GetClientOfUserId(GetEventInt(event, "attacker"));
		if (iClient && IsPlayerAlive(iClient) && !IsFakeClient(iClient))
		{
			int iDead_Client = GetClientOfUserId(GetEventInt(event, "userid"));
			if (GetClientTeam(iClient) != GetClientTeam(iDead_Client))
			{
				int iHealth = GetClientHealth(iClient);
				if (iHealth < iMaximum_health_value)
				{
					iHealth += (iKill_add_hp);
					if (iHealth > iMaximum_health_value)iHealth = iMaximum_health_value;
					{
						SetEntData(iClient, m_iHealth, iHealth);
					}
				}
			}
		}
	}
} 
