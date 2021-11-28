#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =  {
	name = "Give Bonus For Kill", 
	author = "babka68", 
	description = "За убийство игрока получает определённый бонус.", 
	version = "1.0", 
	url = "https://vk.com/zakazserver68"
};

bool bEnable;
int iKill_hp, iKnife_kill_hp, iHegrenade_kill_hp, iHeadshot_kill_hp, iMax_health_value, m_iHealth;

public void OnPluginStart() {
	
	if ((m_iHealth = FindSendPropInfo("CCSPlayer", "m_iHealth")) == -1) {
		SetFailState("CCSPlayer::m_iHealth");
	}
	
	ConVar cvar;
	cvar = CreateConVar("sm_enable_kill_bonus", "1", "1 - Включить, 0 - Выключить плагин.", _, true, 0.0, true, 1.0);
	cvar.AddChangeHook(CVarChanged_Enable_Kill_Bonus);
	bEnable = cvar.BoolValue;
	
	cvar = CreateConVar("sm_kill_hp", "2", "Количество HP дающееся за обычное убийство (По умолчанию: 2)", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_Kill_Hp);
	iKill_hp = cvar.IntValue;
	
	cvar = CreateConVar("sm_knife_hp", "15", "Количество HP дающееся за убийство ножом (По умолчанию: 15)", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_iKnife_kill_hp);
	iKnife_kill_hp = cvar.IntValue;
	
	cvar = CreateConVar("sm_headshot_hp", "5", "Количество HP дающееся за убийство в голову (По умолчанию: 5).", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_iHeadshot_kill_hp);
	iHeadshot_kill_hp = cvar.IntValue;
	
	cvar = CreateConVar("sm_hegrenade_hp", "10", "Количество HP дающееся за убийство гранатой (По умолчанию: 10).", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_iHegrenade_kill_hp);
	iHegrenade_kill_hp = cvar.IntValue;
	
	cvar = CreateConVar("sm_max_healt_value", "127", "Максимальное количество HP у игрока (По умолчанию: 127).", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_Max_Health_Value);
	iMax_health_value = cvar.IntValue;
	
	HookEvent("player_death", Event_Player_Death); // Ловим событие смерти игрока
}

public void CVarChanged_Enable_Kill_Bonus(ConVar cvar, const char[] oldValue, const char[] newValue) {
	bEnable = cvar.BoolValue;
}

public void CVarChanged_Kill_Hp(ConVar cvar, const char[] oldValue, const char[] newValue) {
	iKill_hp = cvar.IntValue;
}

public void CVarChanged_iKnife_kill_hp(ConVar cvar, const char[] oldValue, const char[] newValue) {
	iKnife_kill_hp = cvar.IntValue;
}

public void CVarChanged_iHeadshot_kill_hp(ConVar cvar, const char[] oldValue, const char[] newValue) {
	iHeadshot_kill_hp = cvar.IntValue;
}

public void CVarChanged_iHegrenade_kill_hp(ConVar cvar, const char[] oldValue, const char[] newValue) {
	iHegrenade_kill_hp = cvar.IntValue;
}

public void CVarChanged_Max_Health_Value(ConVar cvar, const char[] oldValue, const char[] newValue) {
	iMax_health_value = cvar.IntValue;
}

public void Event_Player_Death(Event event, const char[] name, bool silent) {
	
	if (bEnable) {  // Если плагин включен идем дальше.
		
		int attacker = GetClientOfUserId(event.GetInt("attacker")); // Нападающий
		if (attacker && IsClientInGame(attacker)) {  // Если нападающий жив и в игре продолжаем.
			
			int iHealth = GetClientHealth(attacker); // Возвращаем нападавшему HP,если оно превысило iMax_health_value
			if (iHealth > 0 && iHealth < iMax_health_value) {
				
				int victim = GetClientOfUserId(event.GetInt("userid")); // жертва
				if (victim && GetClientTeam(attacker) != GetClientTeam(victim)) {  // Определяем команду нападавшего и проверяем нет ли в ней жертвы:D
					
					if (event.GetBool("headshot")) {  // Событие убийства в голову
						iHealth += iHeadshot_kill_hp;
					}
					
					else {
						char weapon[12];
						event.GetString("weapon", weapon, sizeof(weapon));
						
						if (!strcmp(weapon, "hegrenade")) {  // Событие убийства с гранатой
							iHealth += iHegrenade_kill_hp;
						}
						
						else if (!strcmp(weapon, "knife")) {  // Событие убийства с ножом
							iHealth += iKnife_kill_hp;
						}
						
						else {  // Событие обычного убийства
							iHealth += iKill_hp;
						}
					}
					
					if (iHealth > iMax_health_value) {
						iHealth = iMax_health_value;
					}
					
					SetEntData(attacker, m_iHealth, iHealth);
				}
			}
		}
	}
} 
