#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>
#include <freak_fortress_2>
#include <ff2_modules/general>

public Plugin myinfo=
{
	name="Freak Fortress 2: Hit-Wall Jump",
	author="Nopied◎",
	description="",
	version="20250201",
};

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool& result)
{
    int meleeWeapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee), 
        buttons = GetClientButtons(client);

    if(meleeWeapon != weapon
        || TF2_GetClientTeam(client) == FF2_GetBossTeam() || FF2_GetBossIndex(client) != -1
        || !(buttons & IN_ATTACK) || (buttons & (IN_ATTACK2|IN_ATTACK3)) > 0)
            return Plugin_Continue;

    static float meleeRange = 80.0; // actual melee range = 66.0
    float eyePos[3], eyeAngles[3], testPos[3];
    GetClientEyePosition(client, eyePos);
    GetClientEyeAngles(client, eyeAngles);

    GetAngleVectors(eyeAngles, eyeAngles, NULL_VECTOR, NULL_VECTOR);
    ScaleVector(eyeAngles, meleeRange);

    AddVectors(eyePos, eyeAngles, testPos);

    TR_TraceRayFilter(eyePos, testPos, MASK_ALL, RayType_EndPoint, Filter_OnlyWorld);
    if(!TR_DidHit())    return Plugin_Continue;

    float velocity[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
    if(velocity[2] < -192.0)    return Plugin_Continue;
    
    // -48.0 ~ -192.0
    float multiplier = 1.0;
    if(velocity[2] < -48.0)
        multiplier = 1.0 - ((velocity[2] * -1.0) * 0.0052083); // 1/192

    velocity[2] = 700.0 * multiplier;
    SetEntPropEnt(client, Prop_Send, "m_hGroundEntity", -1);
    SetEntityFlags(client, GetEntityFlags(client) & ~FL_ONGROUND);

    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
    SetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", velocity);

    return Plugin_Continue;
}

public bool Filter_OnlyWorld(int entity, int contentsMask)
{
    return entity == 0;
}

stock bool IsBoss(int client)
{
    return FF2_GetBossIndex(client) != -1;
}