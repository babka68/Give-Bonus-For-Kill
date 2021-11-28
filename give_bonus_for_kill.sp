#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =  {
	name = "Give Bonus For Kill", 
	author = "babka68", 
	description = "За убийство игрока получает определённый бонус.", 
	version = "1.0", 
	url = "https://vk.com/zakazserver68"
};

bool g_bEnable;
int g_ikill_Hp, g_iknife_Kill_Hp, g_ihegrenade_Kill_Hp, g_iheadshot_Kill_Hp, g_imax_Health_Value, m_iHealth;

public void OnPluginStart() {
	
	if ((m_iHealth = FindSendPropInfo("CCSPlayer", "m_iHealth")) == -1) {
		SetFailState("CCSPlayer::m_iHealth");
	}
	
	ConVar cvar;
	cvar = CreateConVar("sm_enable_kill_bonus", "1", "1 - Включить, 0 - Выключить плагин.", _, true, 0.0, true, 1.0);
	cvar.AddChangeHook(CVarChanged_Enable_Kill_Bonus);
	g_bEnable = cvar.BoolValue;
	
	cvar = CreateConVar("sm_kill_hp", "2", "Количество HP дающееся за обычное убийство (По умолчанию: 2)", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_Kill_Hp);
	g_ikill_Hp = cvar.IntValue;
	
	cvar = CreateConVar("sm_knife_hp", "15", "Количество HP дающееся за убийство ножом (По умолчанию: 15)", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_g_iknife_Kill_Hp);
	g_iknife_Kill_Hp = cvar.IntValue;
	
	cvar = CreateConVar("sm_headshot_hp", "5", "Количество HP дающееся за убийство в голову (По умолчанию: 5).", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_g_iheadshot_Kill_Hp);
	g_iheadshot_Kill_Hp = cvar.IntValue;
	
	cvar = CreateConVar("sm_hegrenade_hp", "10", "Количество HP дающееся за убийство гранатой (По умолчанию: 10).", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_g_ihegrenade_Kill_Hp);
	g_ihegrenade_Kill_Hp = cvar.IntValue;
	
	cvar = CreateConVar("sm_max_healt_value", "127", "Максимальное количество HP у игрока (По умолчанию: 127).", _, true, 0.0, true, 127.0);
	cvar.AddChangeHook(CVarChanged_Max_Health_Value);
	g_imax_Health_Value = cvar.IntValue;
	
	HookEvent("player_death", Event_Player_Death); // Ловим событие смерти игрока
}

public void CVarChanged_Enable_Kill_Bonus(ConVar cvar, const char[] oldValue, const char[] newValue) {
	g_bEnable = cvar.BoolValue;
}

public void CVarChanged_Kill_Hp(ConVar cvar, const char[] oldValue, const char[] newValue) {
	g_ikill_Hp = cvar.IntValue;
}

public void CVarChanged_g_iknife_Kill_Hp(ConVar cvar, const char[] oldValue, const char[] newValue) {
	g_iknife_Kill_Hp = cvar.IntValue;
}

public void CVarChanged_g_iheadshot_Kill_Hp(ConVar cvar, const char[] oldValue, const char[] newValue) {
	g_iheadshot_Kill_Hp = cvar.IntValue;
}

public void CVarChanged_g_ihegrenade_Kill_Hp(ConVar cvar, const char[] oldValue, const char[] newValue) {
	g_ihegrenade_Kill_Hp = cvar.IntValue;
}

public void CVarChanged_Max_Health_Value(ConVar cvar, const char[] oldValue, const char[] newValue) {
	g_imax_Health_Value = cvar.IntValue;
}

public void Event_Player_Death(Event event, const char[] name, bool silent) {
	
	if (g_bEnable) {  // Если плагин включен идем дальше.
		
		int attacker = GetClientOfUserId(event.GetInt("attacker")); // Нападающий
		if (attacker && IsClientInGame(attacker)) {  // Если нападающий жив и в игре продолжаем.
			
			int iHealth = GetClientHealth(attacker); // Возвращаем нападавшему HP,если оно превысило g_imax_Health_Value
			if (iHealth > 0 && iHealth < g_imax_Health_Value) {
				
				int victim = GetClientOfUserId(event.GetInt("userid")); // жертва
				if (victim && GetClientTeam(attacker) != GetClientTeam(victim)) {  // Определяем команду нападавшего и проверяем нет ли в ней жертвы:D
					
					if (event.GetBool("headshot")) {  // Событие убийства в голову
						iHealth += g_iheadshot_Kill_Hp;
					}
					
					else {
						char sWeapon[12];
						event.GetString("sWeapon", sWeapon, sizeof(sWeapon));
						
						if (!strcmp(sWeapon, "hegrenade")) {  // Событие убийства с гранатой
							iHealth += g_ihegrenade_Kill_Hp;
						}
						
						else if (!strcmp(sWeapon, "knife")) {  // Событие убийства с ножом
							iHealth += g_iknife_Kill_Hp;
						}
						
						else {  // Событие обычного убийства
							iHealth += g_ikill_Hp;
						}
					}
					
					if (iHealth > g_imax_Health_Value) {
						iHealth = g_imax_Health_Value;
					}
					
					SetEntData(attacker, m_iHealth, iHealth);
				}
			}
		}
	}
} 
