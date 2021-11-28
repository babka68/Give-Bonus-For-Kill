#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Give Bonus For Kill", 
	author = "babka68", 
	description = "За убийстве игрока получает определённых бонус.", 
	version = "1.0", 
	url = "https://vk.com/zakazserver68"
};
bool bEnable;
int iKill_hp, iKnife_kill_hp, iHegrenade_kill_hp, iHeadshot_kill_hp, iMax_health_value, m_iHealth;

public void OnPluginStart()
{
	if ((m_iHealth = FindSendPropInfo("CCSPlayer", "m_iHealth")) == -1)
	{
		SetFailState("CCSPlayer::m_iHealth");
	}
	
	ConVar cvar;
	cvar = CreateConVar("sm_enable_kill_bonus", "1", "1 - Включить, 0 - Выключить плагин.", _, true, 1.0, true, 1.0);
	cvar.AddChangeHook(CVarChanged_Enable_Kill_Bonus);
	bEnable = cvar.BoolValue;
	
	cvar = CreateConVar("sm_kill_hp", "2", "Количество HP дающееся за обычное убийство (По умолчанию: 2)", _, true, 1.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_Kill_Hp);
	iKill_hp = cvar.IntValue;
	
	cvar = CreateConVar("sm_knifehp", "15", "Количество HP дающееся за убийство ножом (По умолчанию: 15)", _, true, 1.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_iKnife_kill_hp);
	iKnife_kill_hp = cvar.IntValue;
	
	cvar = CreateConVar("sm_headshot_hp", "5", "Количество HP дающееся за убийство в голову (По умолчанию: 5).", _, true, 1.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_iHeadshot_kill_hp);
	iHeadshot_kill_hp = cvar.IntValue;
	
	cvar = CreateConVar("sm_hegrenade_hp", "10", "Количество HP дающееся за убийство гранатой (По умолчанию: 10).", _, true, 1.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_iHegrenade_kill_hp);
	iHegrenade_kill_hp = cvar.IntValue;
	
	cvar = CreateConVar("sm_max_healt_value", "127", "Максимальное количество HP у игрока (По умолчанию: 127).", _, true, 1.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_Max_Health_Value);
	iMax_health_value = cvar.IntValue;
	
	HookEvent("player_death", Event_Player_Death); // Ловим событие смерти игрока
}

public void CVarChanged_Enable_Kill_Bonus(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	bEnable = cvar.BoolValue;
}

public void CVarChanged_Kill_Hp(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	iKill_hp = cvar.IntValue;
}

public void CVarChanged_iKnife_kill_hp(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	iKnife_kill_hp = cvar.IntValue;
}

public void CVarChanged_iHeadshot_kill_hp(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	iHeadshot_kill_hp = cvar.IntValue;
}

public void CVarChanged_iHegrenade_kill_hp(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	iHegrenade_kill_hp = cvar.IntValue;
}

public void CVarChanged_Max_Health_Value(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	iMax_health_value = cvar.IntValue;
}

public void Event_Player_Death(Event event, const char[] name, bool silent)
{
	if (bEnable) // Если плагин включен идем дальше.
	{
		int victim = GetClientOfUserId(GetEventInt(event, "userid")); // жертва
		int attacker = GetClientOfUserId(GetEventInt(event, "attacker")); // Нападающий
		bool headshot = GetEventBool(event, "headshot"); // Инициализируем логическую переменную headshot и записываем в неё событие headshot
		
		if (GetClientTeam(attacker) != GetClientTeam(victim)) // Определяем команду нападавшего и проверяем нет ли в ней жертвы: // Определяем команду нападавшего и проверяем нет ли в ней жертвы:
		{
			if (attacker && victim)
			{
				int iHealth = GetClientHealth(attacker); // Возвращаем нападавшему HP,если оно превысило iMax_health_value
				if (iHealth > 0) // Если мы дошли сюда,значит игрок жив и есть смысл выдавать HP
				{
					char Weapon[32];
					event.GetString("weapon", Weapon, sizeof(Weapon));
					
					if (!strcmp(Weapon, "hegrenade", false)) // Убийство игрока с HE гранаты
					{
						iHealth += (iHegrenade_kill_hp);
						if (iHealth > iMax_health_value)iHealth = iMax_health_value;
						{
							SetEntData(attacker, m_iHealth, iHealth); // Устанавливаем заданное кол-во HP
						}
					}
					
					else if (!strcmp(Weapon, "knife", false)) // Убийство игрока с ножа
					{
						iHealth += (iKnife_kill_hp);
						if (iHealth > iMax_health_value)iHealth = iMax_health_value;
						{
							SetEntData(attacker, m_iHealth, iHealth); // Устанавливаем заданное кол-во HP
						}
					}
					
					else if (headshot) // Событие с убийством в голову
					{
						iHealth += (iHeadshot_kill_hp);
						if (iHealth > iMax_health_value)iHealth = iMax_health_value;
						{
							SetEntData(attacker, m_iHealth, iHealth); // Устанавливаем заданное кол-во HP
						}
					}
					
					else // Простое убийство игрока
					{
						iHealth += (iKill_hp);
						if (iHealth > iMax_health_value)iHealth = iMax_health_value;
						{
							SetEntData(attacker, m_iHealth, iHealth);
						}
					}
					
				}
			}
			
		}
	}
} 
