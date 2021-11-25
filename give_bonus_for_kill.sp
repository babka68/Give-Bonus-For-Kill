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
int iKill_add_hp, iKnife_Kill_add_hp, iHeadshot_Kill_add_hp, iMaximum_health_value, m_iHealth;

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
	
	cvar = CreateConVar("sm_kill_add_hp", "5", "Сколько добавлять HP за убийство", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_Kill_Add_Hp);
	iKill_add_hp = cvar.IntValue;
	
	cvar = CreateConVar("sm_maximum_healt_value", "127", "Максимальное значение здоровья.", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_Maximum_Health_Value);
	iMaximum_health_value = cvar.IntValue;
	
	cvar = CreateConVar("sm_knife_kill_add_hp", "15", "Сколько добавлять HP за убийство ножом", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_iKnife_Kill_Add_Hp);
	iKnife_Kill_add_hp = cvar.IntValue;
	
	cvar = CreateConVar("sm_knife_kill_add_hp", "10", "Сколько добавлять HP за убийство в голову", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_iHeadshot_Kill_Add_Hp);
	iHeadshot_Kill_add_hp = cvar.IntValue;
	
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

public void CVarChanged_iKnife_Kill_Add_Hp(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	iKnife_Kill_add_hp = cvar.IntValue;
}

public void CVarChanged_iHeadshot_Kill_Add_Hp(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	iHeadshot_Kill_add_hp = cvar.IntValue;
}


public void Event_Player_Death(Event event, const char[] name, bool silent)
{
	if (bEnable) // Если плагин вкл,вы полняем сценарий ниже
	{
		// Сценарий убийства игрока ножом и получения HP
		char weaponName[12];
		event.GetString("weapon", weaponName, sizeof(weaponName));
		
		if (strcmp(weaponName, "knife") == 0)
		{
			int victim = GetClientOfUserId(GetEventInt(event, "userid")); // жертва
			int attacker = GetClientOfUserId(GetEventInt(event, "attacker")); // нападающий
			
			if (victim && attacker)
			{
				if (GetClientTeam(attacker) != GetClientTeam(victim)) // Определяем команду нападавшего и проверяем нет ли в ней жертвы:
				{
					int iHealth = GetClientHealth(attacker); // Возвращаем нападавшему HP,если оно превысило iMaximum_health_value
					if (iHealth > 0)
					{
						iHealth += (iKnife_Kill_add_hp);
						if (iHealth > iMaximum_health_value)iHealth = iMaximum_health_value;
						{
							SetEntData(attacker, m_iHealth, iHealth); // Устанавливаем заданное кол-во HP
						}
					}
				}
			}
		}
		
		// Сценарий убийства игрока в голов и получения HP
		if (event.GetBool("headshot"))
		{
			int victim = GetClientOfUserId(GetEventInt(event, "userid")); // жертва
			int attacker = GetClientOfUserId(GetEventInt(event, "attacker")); // нападающий
			
			if (victim && attacker)
			{
				if (GetClientTeam(attacker) != GetClientTeam(victim)) // Определяем команду нападавшего и проверяем нет ли в ней жертвы:
				{
					int iHealth = GetClientHealth(attacker); // Возвращаем нападавшему HP,если оно превысило iMaximum_health_value
					iHealth += (iHeadshot_Kill_add_hp);
					if (iHealth > iMaximum_health_value)iHealth = iMaximum_health_value;
					{
						SetEntData(attacker, m_iHealth, iHealth); // Устанавливаем заданное кол-во HP
					}
				}
			}
		}
		
		int victim = GetClientOfUserId(GetEventInt(event, "userid"));
		int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		
		if (attacker && victim)
		{
			if (GetClientTeam(attacker) != GetClientTeam(victim))
			{
				int iHealth = GetClientHealth(attacker);
				if (iHealth > 0)
				{
					iHealth += (iKill_add_hp);
					if (iHealth > iMaximum_health_value)iHealth = iMaximum_health_value;
					{
						SetEntData(attacker, m_iHealth, iHealth);
					}
				}
			}
		}
	}
} 
