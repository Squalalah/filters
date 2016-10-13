//////
///
//////
///
//////
///     				CE FILTERSCRIPT EST EN ETAT DE PROTOTYPE.
//////  IL N'Y A DONC AUCUNE REEL OPTIMISATION AINSI QUE D'AGENCEMENT (beauté) DU CODE.
///
//////                          Imaginé et Codé par Squalalah
///
/////                       	https://github.com/Squalalah
///     ///    ///    ///    ///    ///    ///    ///    ///    ///    ///    ///    ///
//////    ///    ///    ///    ///    ///    ///    ///    ///    ///    ///    ///    ///
///    ///    ///    ///    ///v    ///    ///    ///    ///    ///    ///    ///    ///    ///
//////    ///    ///    ///    ///    ///    ///    ///    ///    ///    ///    ///    ///    ///
///    ///    ///    ///    ///    ///    ///    ///    ///    ///    ///    ///    ///    ///    ///
//////
///
//////
///
//////
///
//////
///
//////


#define FILTERSCRIPT
#include <a_samp>
#include <sscanf2>
#include <streamer>


///~~~~~~~~ DEFINES ~~~~~~~~///

//SendFormatMessageInRange(int:range, float:x, float:y, float:z, color, str[], args[])

#define SendFormatMessage(%0,%1,%2,%3) \
		(format(strformat, sizeof(strformat), (%2), %3), SendClientMessage((%0), (%1), strformat))

#define SendFormatMessageInRange(%0,%1,%2,%3,%4,%5,%6) \
	for(new i = 0, j = GetPlayerPoolSize(); i <= j;i++) if(IsPlayerInRangeOfPoint(i,(%0),(%1),(%2),(%3))) \
	    format(strrange, sizeof(strrange),(%5),(%6)), SendClientMessage(i,(%4), strrange)
	    
#define SendMessageInRange(%0,%1,%2,%3,%4,%5) \
	for(new i = 0, j = GetPlayerPoolSize(); i <= j;i++) if(IsPlayerInRangeOfPoint(i,(%0),(%1),(%2),(%3))) \
	    SendClientMessage(i,(%4), %5)

#define HOLDING(%0) \
	((newkeys & (%0)) == (%0)) //Définit le fait qu'une touche est ENFONCÉE

#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0))) //Définit si la touché est PRESSÉE
	
#define PRESSING(%0,%1) \
	(%0 & (%1)) //Définit si une touche est pressée ACTUELLEMENT

#define KEY_AIM KEY_HANDBRAKE //On définit une touche "KEY_AIM" qui voudra dire "Touche pour viser, soit le clic droit".

#define MAX_BANK_ACTOR 2
#define MAX_BANK_TIME 4
#define MONEYPERSEC 537 			 //Somme "donné à chaque seconde" pendant que le braqueur remplit son sac dans le coffre.(n'est pas donné chaque seconde, mais quand la personne arretera de remplir son sac)
#define TIMERACTOR 30	    //Temps avant que l'acteur n'active l'alarme après avoir été braqué (en secondes)
#define TIMERPERCEUSE 10 	   //Temps avant que la perceuse n'ouvre le coffre (en millisecondes)
#define TIMERHACKING 10 		  //Temps avant que le piratage se finisse (en secondes)
#define TIMERC4EXPLODE 10 		 //Temps avant que le C4 n'explose (en secondes)
#define TIMERGRILLCLOSED 20     //Temps minimum avant que la grille de la banque ne se ferme
#define TIMERGRILLCLOSED_MAX 10//===//Temps maximum avant que la grille de la banque ne se ferme
#define TIMERALARM 75 		   	   //Temps après lequel l'alarme se relance (le son) (en secondes)
#define TIMERSUSPECTED 10       //Temps à partir duquel le 2e acteur va activer l'alarme suite au tir entendu (en sec)
#define ERROR_BANKCODE 3 	  	  //Nombre d'erreurs possible dans le code de la banque avant que l'alerte soit donnée.
#define MINUTE_BANK_ROB_WAIT 120 //Nombre de minutes necessaires à attendre entre deux braquages.
#define SECOND_GRAB_MONEY 30 	//Nombres de secondes maximum avant l'interdiction de reprendre de l'argent dans le coffre-fort.


#define MAX_BAGS 2 //définit le nombre de sac de butin maximum en même temps

#define COLOR_ORANGE 0x9e5e1aFF
#define COLOR_ALARM 0xc42d2dFF
#define COLOR_HACK_SUCCESS 0x1a7a3dFF
#define COLOR_HACK_CODE "{2c7f7f}"

#define STRING_NORMAL 145

#define MSG_NOT_FRONT_VAULT Erreur(playerid, "[ERREUR] Vous n'êtes pas devant le coffre de la banque !");
#define MSG_ROBBERY_NOT_STARTED Erreur(playerid, "[ERREUR] Le braquage n'a pas démarré !");
#define MSG_NOT_FRONT_BAR Erreur(playerid, "[ERREUR] Vous n'êtes pas devant le comptoir de la banque !");
#define MSG_VAULT_ALREADY_OPEN Erreur(playerid, "Le coffre est déjà ouvert !");
#define MSG_NO_C4 Erreur(playerid, "Vous n'avez pas de pains de C4 sur vous !");


///~~~~~~~~ FORWARDS ~~~~~~~~///

forward Random(min, max);
forward Timer1s();
forward Timer1m();
forward StopAudioStreamInRange(Float:radius, Float:x, Float:y, Float:z);
forward PlayAudioStreamInRange(Float:radius, Float:x, Float:y, Float:z, link[]);


///~~~~~~~~ ENUMS ~~~~~~~~///

enum
	bInfos
{
	actorID[MAX_BANK_ACTOR],
	bool: isActorFreeze[MAX_BANK_ACTOR],  //Variable booléenne déclarant si l'acteur au comptoir de la banque a les mains en l'air (true) ou non (false)
	bool: isActorInjured[MAX_BANK_ACTOR],//Variable booléenne qui déclaré si l'acteur est touché (mort) ou non.
	bool: isBraquage, 	 //Variable booléeenne déclarant si un braquage est en cours (true) ou non (false)
	bool: isVaultOpen,  //Variable booléenne déclarant si le coffre est ouvert ou non.
	//bool: isDrilling,  //Variable booléenne déclarant si le coffre est en train d'être percé ou non.
	bool: isExploding,// Variable booléenne déclarant si la porte du coffre-fort est sur le point d'exploser ou non.
	bool: alarm, 	 //Variable booléenne déclarant si l'alarme est activé ou non.
	bool: ishacking,   //Variable booléenne déclarant si l'ordinateur du comptoir --> est en train d'être piraté <--
	bool: ishacked,   //Variable booléenne déclarant si l'ordinateur du comptoir --> a déjà été piraté <--
	bool: isUnlocked, //Variable booléenne déclarant si la porte est dévérouillé ou non (pour la perceuse)
	grabbingMoney,   //Variable contenant l'ID du premier joueur ayant recolté l'argent.
	//timerperceuse,  //Variable stockant le timer pour que la perceuse ouvre le coffre
	timeractor,    //Variable stockant le timer pour que l'acteur active l'alarme à la fin du timer
	timersuspected,
	timergrabmoney,   //Variable contenant le "timer" (GetTickCount), permettant de laisser x secondes au braqueur pour prendre l'argent.
	timeralarm,     // Variable permettant de relancer l'alarme.
	timergrill,    // Variable permettant de fermer la grille aléatoirement.
	timerpiratage,// Variable permettant de pirater...
	timerc4,
	timerbraquage, // Variable contenant le temps avant de pouvoir rebraquer
	hacker, //variable contenant l'ID du hacker
	code,          //Variable stockant le code généré si le piratage réussit
	errorcode, 	  //Variable stockant le nombre d'echec du code, une fois qu'il atteint le nombre définit (DEFINE ERROR_BANKCODE), l'alarme se déclenche
	vaultvalue,  //Variable stockant le contenu de la banque (en argent pour les braqueurs)
	vaultdoor,  //Variable contenant l'id de l'objet de la porte
	vaultgrill,
	moneyobject//Variable contenant l'id de l'objet du sac


};

enum bagInfos
{
	bagid,
	bagidpickup,
	bagcontent
}

enum bPos
{
	Float:px,
	Float:py,
	Float:pz,
	Float:rx,
	Float:ry,
	Float:rz,
	vw
};

///~~~~~~~~ Arrays ~~~~~~~~///

new
	GTRPVaultDoor[][bPos] = {
	{1591.92883, 2390.48071, 1137.10815, 0.0, 0.0, 90.00000, 13}
	},
	
	GTRPVault[][bPos] = {
	{1595.7462, 2392.6125, 1136.6624, 0.0, 0.0, 0.0, 13}
	},

	GTRPBankHack[][bPos] = {
	{1577.09680, 2405.28979, 1139.88013, 0.0, 0.0, 0.0, 13}
	},

	GTRPVaultDoorExplode[][bPos] ={
	{1593.32300, 2390.50952, 1135.71362,90.00000, -4.00000, 88.00000, 13}
	},

	GTRPVaultDoorOpened[][bPos] = {
	{1590.98584, 2389.64233,1137.10815,0.00000, 0.00000,  163.03896, 13}
	},

	GTRPVaultDigiCode[][bPos] = {
	{ 1591.82117,  2391.55933,  1137.21594, 0.0, 0.0, 0.0, 13}
	},

	GTRPPosDisableAlarm[][bPos] = {
	{ 1579.31958,  2403.80371,  1140.46191, 0.0, 0.0, 0.0, 13}
	},

	GTRPPosActor[][bPos] = {
	{ 1585.2771,  2417.8167,  1140.0757,  270.0000, 0.0, 0.0, 13}
	},
	
	GTRPGrillOpen[][bPos] = {
	{1579.17566, 2400.87280, 1145.25708,  0.00000, 0.00000, 0.00000, 13}
	},
	
	GTRPGrillClosed[][bPos] = {
	{1579.17566, 2400.87280, 1141.73096,   0.00000, 0.00000, 0.00000, 13}
	},
	
	GTRPBankAlarmExterior[][bPos] = {
	{-2446.6992, 507.3693, 45.5625, 0.0, 0.0, 0.0, 13}
	},
	
	GTRPPosImprimerie[][bPos] = {
	{-1870.7598, -174.2585, 9.1700, 0.0, 0.0, 0.0, 0}
	};
	

///~~~~~~~~ VARS ~~~~~~~~///

new
	Text3D:label[3],
	bool:iscollecting[MAX_PLAYERS] = false,
	bool:hasrobmoney[MAX_PLAYERS] = false,
	c4[MAX_PLAYERS] = 0,
	recupmoney[MAX_PLAYERS],
	Banque[bInfos],
	bagbank[MAX_PLAYERS],
	bagbankvalue[MAX_PLAYERS],
	bags[MAX_BAGS][bagInfos],
	strrange[128],
	strformat[128],
	checkpoint[MAX_PLAYERS];

	

public OnFilterScriptInit()
{
	Banque[actorID][0] = CreateActor(240, GTRPPosActor[0][px], GTRPPosActor[0][py],GTRPPosActor[0][pz],GTRPPosActor[0][rx]);
	Banque[actorID][1] = CreateActor(71, 1586.5034, 2392.5320, 1137.1508, 266.000);
	
	SetActorVirtualWorld(Banque[actorID][0], GTRPPosActor[0][vw]);
	SetActorVirtualWorld(Banque[actorID][1], GTRPPosActor[0][vw]);
	
	SetActorInvulnerable(Banque[actorID][0], false);
	SetActorInvulnerable(Banque[actorID][1], false);
	
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
	    bagbank[i] = -1;
		bagbankvalue[i] = 0;
	}
	Banque[timersuspected] = -1;
	Banque[isActorInjured][0] = false;
	Banque[isActorInjured][1] = false;
	Banque[isActorFreeze][0] = false;
	Banque[isActorFreeze][1] = false;
	Banque[isBraquage] = false;
	Banque[isVaultOpen] = false;
	//Banque[isDrilling] = false;
	Banque[alarm] = false;
	Banque[ishacking] = false;
	Banque[ishacked] = false;
	Banque[isExploding] = false;
	Banque[vaultvalue] = 200000;
	Banque[errorcode] = 0;
	Banque[grabbingMoney] = -1;
	Banque[timerbraquage] = 0;
	Banque[timeralarm] = TIMERALARM;
	Banque[timergrill] = -1;
	Banque[timerc4] = -1;
	//Banque[timerperceuse] = -1;
	Banque[timerpiratage] = -1;
	Banque[hacker] = -1;
	Banque[timeractor] = -1;
	Banque[isUnlocked] = false;
	
	ApplyActorAnimation(Banque[actorID][1], "FOOD", "FF_Dam_Left", 4.1, 0, 0, 0, 1, 0);
	ApplyActorAnimation(Banque[actorID][1], "FOOD", "FF_Dam_Left", 4.1, 0, 0, 0, 1, 0);
	
	SetTimer("Timer1s", 1000, true);
	SetTimer("Timer1m", 60000, true);

	print("FS bankrobbery lancé");
	label[0] = Create3DTextLabel("Position porte coffre banque", 0x008080FF, GTRPVaultDoor[0][px], GTRPVaultDoor[0][py], GTRPVaultDoor[0][pz], 10.0, GTRPVaultDoor[0][vw], 0);
	label[1] = Create3DTextLabel("Position coffre banque", 0x008080FF, GTRPVault[0][px], GTRPVault[0][py], GTRPVault[0][pz], 10.0, GTRPVaultDoor[0][vw], 0);
	label[2] = Create3DTextLabel("Position pc pirater", 0x008080FF, GTRPBankHack[0][px],GTRPBankHack[0][py],GTRPBankHack[0][pz], 10.0, GTRPVaultDoor[0][vw], 0);
	
	
	Banque[vaultdoor] = CreateDynamicObject(2634, GTRPVaultDoor[0][px], GTRPVaultDoor[0][py], GTRPVaultDoor[0][pz],  GTRPVaultDoor[0][rx],  GTRPVaultDoor[0][ry], GTRPVaultDoor[0][rz]);
	Banque[moneyobject] = CreateDynamicObject(1550, GTRPVault[0][px], GTRPVault[0][py], GTRPVault[0][pz], 0.0, 0.0, 180.0000000);
	Banque[vaultgrill] = CreateDynamicObject(971, 	GTRPGrillOpen[0][px], 	GTRPGrillOpen[0][py], 	GTRPGrillOpen[0][pz], 	GTRPGrillOpen[0][rx], 	GTRPGrillOpen[0][ry], GTRPGrillOpen[0][rz]);
	return 1;
}

public OnFilterScriptExit()
{
	for(new i = 0; i < 3;i++) Delete3DTextLabel(label[i]);
	DestroyActor(Banque[actorID][0]);
	DestroyActor(Banque[actorID][1]);
	DestroyObject(Banque[vaultdoor]);
	DestroyObject(Banque[moneyobject]);
	return 1;
}

public OnPlayerConnect(playerid)
{
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(hasrobmoney[playerid])
	{
	    RemovePlayerAttachedObject(playerid, 0);
	    DestroyDynamicObject(bagbank[playerid]);
		
		SendFormatMessage(playerid, COLOR_ALARM, "Vous avez perdu les %i$ recoltés durant le braquage.", bagbankvalue[playerid]);
		bagbank[playerid] = -1;
		bagbankvalue[playerid] = 0;
		hasrobmoney[playerid] = false;
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/testposerc4", cmdtext, true) == 0)
	{
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, GTRPVaultDoor[0][px], GTRPVaultDoor[0][py], GTRPVaultDoor[0][pz])) return MSG_NOT_FRONT_VAULT
		//Si le joueur est à la banque, à la porte du coffre fort.
  		if(!Banque[isBraquage]) return MSG_ROBBERY_NOT_STARTED
	    if(c4[playerid] != 3) return MSG_NO_C4
	    if(Banque[isVaultOpen]) return SendClientMessage(playerid, COLOR_ORANGE, "Pourquoi vouloir détruire une porte ouvert ?!");
	    if(Banque[isExploding]) return SendClientMessage(playerid, COLOR_ORANGE, "3 pains de C4 sont posés sur la porte et émmètent un bip de plus en plus fort...");
		if(!Banque[isActorInjured][1] && !Banque[isActorFreeze][1] && !Banque[alarm])
		{
		    BankAlarm();
			SendMessageInRange(30.0, GTRPVaultDigiCode[0][px], GTRPVaultDigiCode[0][py], GTRPVaultDigiCode[0][pz], COLOR_ALARM, "Vous avez tenté de poser un pain de c4 devant un agent de securité...");
			return 1;
		}
		SendFormatMessage(playerid, COLOR_HACK_SUCCESS, "Les pains de C4 ont bien été posés, ceux-ci exploseront dans %i secondes", TIMERC4EXPLODE);
		Banque[isExploding] = true;
		Banque[timerc4] = TIMERC4EXPLODE;
		c4[playerid] = 0;
		return 1;
	}

	if (strcmp("/testgetc4", cmdtext, true) == 0)
	{
	    SendClientMessage(playerid, -1, "Vous avez obtenu 3 pains de C4");
	    c4[playerid] = 3;
	    return 1;
	}
	
	/*if (strcmp("/testposerperceuse", cmdtext, true) == 0)
	{
	    if(!IsPlayerInRangeOfPoint(playerid, 2.0, GTRPVaultDoor[0][px], GTRPVaultDoor[0][py], GTRPVaultDoor[0][pz])) return MSG_NOT_FRONT_VAULT
	    if(!Banque[isBraquage]) return MSG_ROBBERY_NOT_STARTED
		if(Banque[isDrilling]) return SendClientMessage(playerid, COLOR_ORANGE, "Une perceuse est déjà en marche !");
		if(Banque[isVaultOpen]) return MSG_VAULT_ALREADY_OPEN
		if(!Banque[isActorInjured][1] && !Banque[isActorFreeze][1] && !Banque[alarm])
		{
		    BankAlarm();
			SendMessageInRange(30.0, GTRPVaultDigiCode[0][px], GTRPVaultDigiCode[0][py], GTRPVaultDigiCode[0][pz], COLOR_ALARM, "Vous avez tenté de poser une perceuse devant un agent de securité...");
			return 1;
		}
		Banque[isDrilling] = true;
		SendClientMessage(playerid, -1, "[DEBUG] La perceuse est lancée");
		Banque[timerperceuse] = TIMERPERCEUSE;
		
		return 1;
	}*/
	
	if(strcmp("/testpirater", cmdtext, true) == 0)
	{
	    if(!IsPlayerInRangeOfPoint(playerid, 2.0, GTRPBankHack[0][px], GTRPBankHack[0][py], GTRPBankHack[0][pz])) return MSG_NOT_FRONT_BAR
	    if(!Banque[isBraquage]) return MSG_ROBBERY_NOT_STARTED
	    if(Banque[alarm]) return SendClientMessage(playerid, COLOR_ALARM, "L'alarme a coupé l'accès aux données");
	    if(Banque[ishacking]) return SendClientMessage(playerid, COLOR_ORANGE, "L'ordinateur est déjà en cours de piratage !");
	    if(Banque[ishacked]) return SendClientMessage(playerid, COLOR_ORANGE, "L'ordinateur a déjà été piraté !");
	    
		TogglePlayerControllable(playerid, 0);
		Banque[hacker] = playerid;
		GameTextForPlayer(playerid, "Piratage en cours...", TIMERHACKING*1000, 1);
		Banque[timerpiratage] = TIMERHACKING;
		Banque[ishacking] = true;
		return 1;
	}

	if(strcmp("/testalarme", cmdtext, true) == 0)
	{
	    if(!IsPlayerInRangeOfPoint(playerid, 2.0, GTRPPosDisableAlarm[0][px], GTRPPosDisableAlarm[0][py], GTRPPosDisableAlarm[0][pz])) return SendClientMessage(playerid, -1, "Vous n'êtes pas au bon endroit !");
	    if(!Banque[alarm]) return SendClientMessage(playerid, COLOR_ALARM, "L'alarme est déjà coupée !");
	    
		Banque[alarm] = false;
		Banque[isActorFreeze][0] = false;
		Banque[isActorFreeze][1] = false;
		ClearActorAnimations(Banque[actorID][0]);
		
		MoveDynamicObject(Banque[vaultgrill], GTRPGrillOpen[0][px], GTRPGrillOpen[0][py], GTRPGrillOpen[0][pz], 1.0, GTRPGrillOpen[0][rx], GTRPGrillOpen[0][ry], GTRPGrillOpen[0][rz]);
		Banque[timergrill] = -1;
		
		StopAudioStreamInRange(60.0, GTRPBankAlarmExterior[0][px], GTRPBankAlarmExterior[0][py], GTRPBankAlarmExterior[0][pz]);
		StopAudioStreamInRange(60.0, GTRPVaultDigiCode[0][px], GTRPVaultDigiCode[0][py], GTRPVaultDigiCode[0][pz]);
		
		SendClientMessage(playerid, COLOR_ALARM, "L'alarme a été desactivée !");
		return 1;
	}
	
 	if(strcmp(cmdtext, "/testcode", true, 9) == 0)
	{
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, GTRPVaultDigiCode[0][px], GTRPVaultDigiCode[0][py], GTRPVaultDigiCode[0][pz])) return MSG_NOT_FRONT_VAULT
		if(!Banque[isBraquage]) return MSG_ROBBERY_NOT_STARTED
		if(Banque[alarm]) return SendClientMessage(playerid, COLOR_ALARM, "L'alarme a désactivé l'ouverture de la porte magnétiquement");
		if(Banque[isVaultOpen]) return MSG_VAULT_ALREADY_OPEN
		new
			mdp,
			str[128];
		if(sscanf(cmdtext, "si", str, mdp)) return Usage(playerid, "Usage: /code <code>");
		
        if(!Banque[isActorInjured][1] && !Banque[isActorFreeze][1] && !Banque[alarm])
		{
		    BankAlarm();
			SendMessageInRange(30.0, GTRPVaultDigiCode[0][px], GTRPVaultDigiCode[0][py], GTRPVaultDigiCode[0][pz], COLOR_ALARM, "Vous avez tenté d'écrire un code devant un agent de securité...");
			return 1;
		}
		
		if(mdp != Banque[code])
		{
		    Banque[errorcode]++;
			SendClientMessage(playerid, COLOR_ALARM, "[ERREUR] : Code incorrect !");
			if(Banque[errorcode] == ERROR_BANKCODE)
			{
				Banque[errorcode] = 0;
				BankAlarm();
				return SendClientMessage(playerid, COLOR_ALARM, "Une alarme retentie, peut-être à cause de vos échecs répétés au mot de passe ?");
				
			}
			return 1;
		}
		SendClientMessage(playerid, COLOR_HACK_SUCCESS, "[SUCCES] Code validé !");
		MoveDynamicObject(Banque[vaultdoor], GTRPVaultDoorOpened[0][px], GTRPVaultDoorOpened[0][py], GTRPVaultDoorOpened[0][pz], 3.0, GTRPVaultDoorOpened[0][rx], GTRPVaultDoorOpened[0][ry], GTRPVaultDoorOpened[0][rz]);
		Banque[isVaultOpen] = true;
		return 1;
	}

	if(strcmp("/testbraquage", cmdtext, true) == 0)
	{
	    if(IsBraquageAvailable()) return SendClientMessage(playerid, -1, "Le braquage de banque est disponible !");
	    else SendClientMessage(playerid, -1, "Le braquage de banque est indisponible !");
	    return 1;
	}
	
	if(strcmp("/testposerbutin", cmdtext, true) == 0)
	{
	    if(bagbank[playerid] == -1) return SendClientMessage(playerid, -1, "Vous n'avez aucun sac de butin !");
	    if(bagbankvalue[playerid] <= 0) return SendClientMessage(playerid, -1, "Votre sac de butin est vide !");
		new
			Float:pos[3],
			str[200];
			
		RemovePlayerAttachedObject(playerid, 0);
	 	DestroyDynamicObject(bagbank[playerid]);
		GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	 	
		bags[0][bagid] = CreateDynamicObject(1550, pos[0]+2, pos[1], pos[2], 0.0, 0.0, 180.00000, GetPlayerVirtualWorld(playerid));
		bags[0][bagcontent] = bagbankvalue[playerid];
		bags[0][bagidpickup] = CreateDynamicPickup(1210, 8, pos[0]+2, pos[1], pos[2], GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
		hasrobmoney[playerid] = false;
		format(str, sizeof(str), "Vous avez laissé tomber votre sac de butin contenant %i$.", bagbankvalue[playerid]);
		SendClientMessage(playerid, -1, str);
		bagbankvalue[playerid] = 0;
		return 1;
	}
	
	if(strcmp("/fermer", cmdtext, true) == 0) return MoveDynamicObject(Banque[vaultdoor], -1979.5, 136.60000610352, 27.799999237061, 3.0);
	if(strcmp("/arme", cmdtext, true) == 0) return GivePlayerWeapon(playerid, 25, 9999);
	if(strcmp("/testreset", cmdtext, true) == 0)
	{
	
	    Banque[isActorFreeze][0] = false;
		Banque[isActorFreeze][1] = false;
		Banque[isBraquage] = false;
		Banque[isVaultOpen] = false;
		//Banque[isDrilling] = false;
		Banque[alarm] = false;
		Banque[ishacking] = false;
		Banque[ishacked] = false;
		Banque[isExploding] = false;
		Banque[isUnlocked] = false;
		Banque[vaultvalue] = 200000;
		Banque[errorcode] = 0;
		Banque[grabbingMoney] = -1;
		Banque[timerbraquage] = 0;
		Banque[timeralarm] = TIMERALARM;
		Banque[timergrill] = -1;
		Banque[timerc4] = -1;
		//Banque[timerperceuse] = -1;
		Banque[timerpiratage] = -1;
		Banque[hacker] = -1;
		
		ClearActorAnimations(Banque[actorID][0]);
		MoveDynamicObject(Banque[vaultgrill], GTRPGrillOpen[0][px], GTRPGrillOpen[0][py], GTRPGrillOpen[0][pz], 1.0, GTRPGrillOpen[0][rx], GTRPGrillOpen[0][ry], GTRPGrillOpen[0][rz]);
		MoveDynamicObject(Banque[vaultdoor], GTRPVaultDoor[0][px], GTRPVaultDoor[0][py], GTRPVaultDoor[0][pz], 1.0, GTRPVaultDoor[0][rx], GTRPVaultDoor[0][ry], GTRPVaultDoor[0][rz]);
		return 1;
	}
	return 0;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	for(new i = 0; i < MAX_BAGS; i++)
	{
	    if(pickupid == bags[i][bagidpickup])
		{
		    SendClientMessage(playerid, -1, "Le pickup a été récupéré !");
		    bagbank[playerid] = SetPlayerAttachedObject(playerid, 0, 1550, 1, 0.129999, -0.257999, 0.000000, 4.200002, 83.499992, 155.999984);
		    DestroyDynamicObject(bags[i][bagid]);
		    bagbankvalue[playerid] = bags[i][bagcontent];
			new
			    str[126];
			format(str, sizeof(str), "Vous avez trouvé %i$.", bagbankvalue[playerid]);
			SendClientMessage(playerid, -1, str);
			DestroyDynamicPickup(pickupid);
			hasrobmoney[playerid] = true;
			return 1;
		}
	}
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys == KEY_AIM) //Si le joueur appuie sur le clic droit correspond au clic droit par défaut.
	{
	    new
			id = GetPlayerTargetActor(playerid); //On récupère l'id de l'acteur qu'il vise (ou pas)
			
	    if(id != INVALID_ACTOR_ID)// Si l'ID recupéré est invalide (le joueur ne vise pas un acteur), on va directement à la fin de la Callback.
		{
	     	if(id == Banque[actorID][0]) //Si l'ID récupéré est le même que dans le tableau Actor (index 0), donc le banquier.
	     	{
				if(!Banque[isActorFreeze][0] && !Banque[isBraquage]) // Si le banquier n'a pas les mains en l'air et que le braquage n'est pas lancé
				{
	     	    	ApplyActorAnimation(Banque[actorID][0], "ped", "handsup", 4.1, 0, 0, 0, 1, 0);
	     	    	ApplyActorAnimation(Banque[actorID][0], "ped", "handsup", 4.1, 0, 0, 0, 1, 0);
	     	    	SendClientMessageToAll(-1, "Le banquier a été braqué !");
	     	    	SendClientMessageToAll(-1, "[DEBUG] Le braquage a commencé, il faut maintenant : poser C4 sur le coffre, le percer ou pirater le PC du comptoir");
	     	    	Banque[timeractor] = TIMERACTOR;
	     	    	Banque[isActorFreeze][0] = true;
	     	    	Banque[isBraquage] = true;
					Banque[timerbraquage] = MAX_BANK_TIME;
	     	    	return 1;
				}
				else if(Banque[isActorFreeze][0] && !Banque[alarm] && !Banque[isActorInjured][0]) //Si il a déjà les mains en l'air et/ou que le braquage est lancé, on relance le timer avant qu'il active l'alarme.
				{
					Banque[timeractor] = TIMERACTOR;
					SendClientMessage(playerid, -1, "Vous avez rebraqué le banquier !");
					return 1;
				}
				if(!IsBraquageAvailable() && Banque[isActorFreeze][0]) return SendClientMessage(playerid, -1, "Le braquage de banque est indisponible (en cours)");
	     	}
	     	else if(id == Banque[actorID][1])
	     	{
                if(!IsBraquageAvailable() && Banque[isActorFreeze][0]) return SendClientMessage(playerid, -1, "Le braquage de banque est indisponible (en cours)");
				if(!Banque[isActorFreeze][1] && !Banque[isActorInjured][1])
				{
		     	    Banque[isActorFreeze][1] = true;
		     	    ApplyActorAnimation(Banque[actorID][1], "ped", "handsup", 4.1, 0, 0, 0, 1, 0);
		     	    ApplyActorAnimation(Banque[actorID][1], "ped", "handsup", 4.1, 0, 0, 0, 1, 0);
	     	    	SendClientMessageToAll(-1, "L'agent de sécurité a été braqué !");
	     	    	if(!Banque[isBraquage])
	     	    	{
	     	    	    Banque[isBraquage] = true;
	     	    	    SendClientMessageToAll(-1, "[DEBUG] Le braquage a commencé, il faut maintenant : poser C4 sur le coffre, le percer ou pirater le PC du comptoir");
	     	    	}
	     	    	return 1;
				}
	     	}
		 }
	}
	
	if(PRESSED(KEY_NO))
	{
	    if(IsPlayerInRangeOfPoint(playerid, 2.0, GTRPVault[0][px], GTRPVault[0][py], GTRPVault[0][pz])) //Si le joueur est dans le coffre
	    {
	        if(iscollecting[playerid]) return 1;
	        if(!Banque[isVaultOpen]) return 1;
	        if(Banque[vaultvalue] == 0) return SendClientMessage(playerid, -1, "Il n'y a plus d'argent !");
	        if(Banque[grabbingMoney] != playerid && Banque[grabbingMoney] != -1) return SendClientMessage(playerid, -1, "Quelqu'un d'autre a déjà commencé à prendre l'argent du coffre !");
	        if(Banque[grabbingMoney] == playerid && GetTickCount() - Banque[timergrabmoney] > SECOND_GRAB_MONEY*1000)
			{
				SendClientMessage(playerid, -1, "Vous ne pouvez plus prendre de l'argent !");
				return 1;
			}

			if(Banque[grabbingMoney] == -1) Banque[grabbingMoney] = playerid;
	        
	        SendClientMessage(playerid, -1, "[DEBUG] Vous collectez l'argent");
	        ApplyAnimation(playerid, "POLICE", "CopTraf_Come", 4.1, 1, 1, 1, 0, 0, 0); //Animation où le joueur prend l'argent devant lui, celle-ci continuera jusqu'à appuyer sur ENTRER.
            GameTextForPlayer(playerid, "ENTRER pour quitter le mode collecte", 5000, 1);
            TogglePlayerControllable(playerid, 0);
            iscollecting[playerid] = true;
            recupmoney[playerid] = GetTickCount();
            return 1;
	    }
	    
	    /*if(IsPlayerInRangeOfPoint(playerid, 3.0, GTRPVaultDoor[0][px], GTRPVaultDoor[0][py], GTRPVaultDoor[0][pz])) //Si le joueur est devant la porte du coffre qui a été percé !
	    {
	        if(!Banque[isBraquage]) return 1;
	        //if(Banque[isDrilling]) return 1;
	        if(Banque[isVaultOpen]) return 1;
	        if(!Banque[isUnlocked]) return 1;
			SendClientMessageToAll(-1, "[DEBUG] La porte s'ouvre !");
			MoveDynamicObject(Banque[vaultdoor], GTRPVaultDoorOpened[0][px], GTRPVaultDoorOpened[0][py], GTRPVaultDoorOpened[0][pz], 3.0, GTRPVaultDoorOpened[0][rx], GTRPVaultDoorOpened[0][ry], GTRPVaultDoorOpened[0][rz]);
			Banque[isVaultOpen] = true;

			//Code pour moove la porte
			return 1;
	    }*/
	    
	    if(IsPlayerInRangeOfPoint(playerid, 3.0, GTRPPosImprimerie[0][px], GTRPPosImprimerie[0][py], GTRPPosImprimerie[0][pz])) //Si il est devant la blanchisserie de billet !
	    {
	        if(hasrobmoney[playerid] && bagbank[playerid] == -1)  return Erreur(playerid, "Vous n'avez plus votre sac de butin !");
            if(bagbank[playerid] == -1) return Erreur(playerid, "Vous ne pouvez rien faire ici.");
            new
                value = bagbankvalue[playerid];
			GivePlayerMoney(playerid, value);
			RemovePlayerAttachedObject(playerid, 0);
			SendFormatMessage(playerid, COLOR_HACK_SUCCESS,"Bravo ! vous avez récupéré un montant total de %i$", value);
			bagbank[playerid] = -1;
			bagbankvalue[playerid] = 0;
			hasrobmoney[playerid] = false;
			DestroyDynamicCP(checkpoint[playerid]);
			return 1;
	    }
	}
	
	if(PRESSED(KEY_SECONDARY_ATTACK)) // Si il appuie sur ENTRER
	{
	    if(IsPlayerInRangeOfPoint(playerid, 2.0, GTRPVault[0][px], GTRPVault[0][py], GTRPVault[0][pz])) //Si le joueur est dans le coffre
	    {
	        if(!Banque[isBraquage]) return 1;
	        if(!iscollecting[playerid]) return 1;
	        new
	            timerob = GetTickCount(),
	            diff = timerob - recupmoney[playerid],
	            result = floatround((diff/1000)*MONEYPERSEC, floatround_round),
	            money,
	            str[256],
				db[126]; //str de debug pour afficher le contenu des vars
				
			format(db, 256, "timerob = %i, recupmoney[playerid] = %i, difference = %i, resultat = %i", timerob, recupmoney[playerid], diff, result);
			SendClientMessage(playerid, -1, db);
			
			if(result > Banque[vaultvalue])
			{
			    //GivePlayerMoney(playerid, Banque[vaultvalue]);
				bagbankvalue[playerid] += Banque[vaultvalue];
				money = Banque[vaultvalue];
				Banque[vaultvalue] = 0;
				SendClientMessage(playerid, -1, "Vous semblez avoir pris les derniers billets !");
			}
			else
			{
			    //GivePlayerMoney(playerid, result);
			    bagbankvalue[playerid] += result;
			    money = result;
			    Banque[vaultvalue] -= result;
			}
			
			format(str, sizeof(str), "Vous avez rempli votre sac avec %i$", money);
			SendClientMessage(playerid, -1, str);
			format(str, sizeof(str), "Vous disposez de %i secondes pour reremplir votre sac", SECOND_GRAB_MONEY);
			
			SendClientMessage(playerid, -1, str);
	        SendClientMessage(playerid, -1, "[DEBUG] Vous pouvez vous enfuir !");
			if(!IsValidDynamicCP(checkpoint[playerid]))
			{
				checkpoint[playerid] = CreateDynamicCP(GTRPPosImprimerie[0][px],GTRPPosImprimerie[0][py],GTRPPosImprimerie[0][pz], 3.0, 0, 0);
				TogglePlayerDynamicCP(playerid, checkpoint[playerid], true);
				SendClientMessage(playerid, -1, "Rendez vous au checkpoint pour blanchir votre argent ! Une fois arrivé, appuyez sur N");
			}

	        if(bagbank[playerid] == -1) bagbank[playerid] = SetPlayerAttachedObject(playerid, 0, 1550, 1, 0.129999, -0.257999, 0.000000, 4.200002, 83.499992, 155.999984);
	        Banque[timergrabmoney] = GetTickCount();
	        TogglePlayerControllable(playerid, 1);
			printf("[DEBUG] bagbankvalue[playerid] = %i", bagbankvalue[playerid]);
	        
	        hasrobmoney[playerid] = true; //Il a bien volé de l'argent !
         	iscollecting[playerid] = false;
	        return 1;
	    }
	}
	return 1;
}

public OnPlayerGiveDamageActor(playerid, damaged_actorid, Float: amount, weaponid, bodypart)
{

	for(new i = 0; i < MAX_BANK_ACTOR;i++)
	{
		if(damaged_actorid == Banque[actorID][i])
		{
		    if(Banque[isActorInjured][i])
		    {
		        ApplyActorAnimation(Banque[actorID][i], "CRACK",  "crckidle2", 4.1, 0, 0, 0, 1, 0);
		        ApplyActorAnimation(Banque[actorID][i], "CRACK",  "crckidle2", 4.1, 0, 0, 0, 1, 0);
			}
		    else
		    {
				ClearActorAnimations(Banque[actorID][i]);
				ApplyActorAnimation(Banque[actorID][i], "CRACK",  "crckidle2", 4.1, 0, 0, 0, 1, 0);
				ApplyActorAnimation(Banque[actorID][i], "CRACK",  "crckidle2", 4.1, 0, 0, 0, 1, 0);
				Banque[isActorInjured][i] = true;
				Banque[timeractor] = -1;
				Banque[timersuspected] = TIMERSUSPECTED;
				SendClientMessage(playerid, -1, "L'acteur est en PLS");
				SetActorInvulnerable(Banque[actorID][i], true);
		    }
 			new
				cpt = 0;
		    
		    for(new j = 0; j < MAX_BANK_ACTOR;j++)
			{
   				if(Banque[isActorInjured][j]) cpt++;
			}

			if(cpt == MAX_BANK_ACTOR)
			{
				Banque[timersuspected] = -1;
		     	Banque[timeractor] = -1;
			}
			return 1;
		}
	}

	return 1;
}


stock IsBraquageAvailable()
{
	if(Banque[timerbraquage] == 0) return true;
	else return false;
}


public PlayAudioStreamInRange(Float:radius, Float:x, Float:y, Float:z, link[])
{
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(IsPlayerInRangeOfPoint(i, radius, x, y, z))
		{
 			PlayAudioStreamForPlayer(i, link, x, y, z, radius, 1);
		}
	}
	return 1;
}

public StopAudioStreamInRange(Float:radius, Float:x, Float:y, Float:z)
{
    for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(IsPlayerInRangeOfPoint(i, radius, x, y, z))
		{
			StopAudioStreamForPlayer(i);
		}
	}
	return 1;
}


public Timer1m()
{
	if(Banque[timerbraquage] > 0)
	{
	    Banque[timerbraquage]--;
	}
	if(Banque[timerbraquage] == 0)
	{
	    for(new i = 0; i < MAX_BANK_ACTOR; i++)
	    {
		    Banque[isActorFreeze][i] = false;  //Variable booléenne déclarant si l'acteur au comptoir de la banque a les mains en l'air (true) ou non (false)
			Banque[isActorInjured][i] = false;//Variable booléenne qui déclaré si l'acteur est touché (mort) ou non.
			ClearActorAnimations(Banque[actorID][i]);
		}
		
		Banque[isBraquage] = false;	 //Variable booléeenne déclarant si un braquage est en cours (true) ou non (false)
		Banque[isVaultOpen] = false;//Variable booléenne déclarant si le coffre est ouvert ou non.
		//Banque[isDrilling] = false;  //Variable booléenne déclarant si le coffre est en train d'être percé ou non.
		Banque[isExploding] = false;// Variable booléenne déclarant si la porte du coffre-fort est sur le point d'exploser ou non.
		Banque[alarm] = false;	 //Variable booléenne déclarant si l'alarme est activé ou non.
		Banque[ishacking] = false;  //Variable booléenne déclarant si l'ordinateur du comptoir --> est en train d'être piraté <--
		Banque[ishacked] = false;  //Variable booléenne déclarant si l'ordinateur du comptoir --> a déjà été piraté <--
		Banque[isUnlocked] = false; //Variable booléenne déclarant si la porte est dévérouillé ou non (pour la perceuse)
		Banque[grabbingMoney] = INVALID_PLAYER_ID;  //Variable contenant l'ID du premier joueur ayant recolté l'argent.
		Banque[hacker] = INVALID_PLAYER_ID;
		Banque[code] = 8913475;          //Variable stockant le code généré si le piratage réussit
		Banque[errorcode] = 0; 	  //Variable stockant le nombre d'echec du code, une fois qu'il atteint le nombre définit (DEFINE ERROR_BANKCODE), l'alarme se déclenche
		Banque[vaultvalue] = 200000;  //Variable stockant le contenu de la banque (en argent pour les braqueurs)

		MoveDynamicObject(Banque[vaultdoor], GTRPVaultDoor[0][px], GTRPVaultDoor[0][py], GTRPVaultDoor[0][pz], 1.0, GTRPVaultDoor[0][rx], GTRPVaultDoor[0][ry], GTRPVaultDoor[0][rz]);
		 //Variable contenant l'id de l'objet de la porte
		MoveDynamicObject(Banque[vaultgrill], GTRPGrillOpen[0][px], GTRPGrillOpen[0][py], GTRPGrillOpen[0][pz], 1.0 , GTRPGrillOpen[0][rx], GTRPGrillOpen[0][ry], GTRPGrillOpen[0][rz]);
	}
	return 1;

}

public Timer1s()
{
	if(Banque[timeractor] > 0)
	{
		Banque[timeractor]--;
	}
	if(Banque[timeractor] == 0)
	{
		Banque[timeractor] = -1;
		SendMessageInRange(30.0, GTRPVaultDigiCode[0][px], GTRPVaultDigiCode[0][py], GTRPVaultDigiCode[0][pz], COLOR_ALARM, "Un des employés de la banque a entendu un tir et a activé l'alarme !");
		BankAlarm();
		ClearActorAnimations(Banque[actorID][0]);
	}
	if(Banque[timersuspected] > 0)
	{
		Banque[timersuspected]--;
	}
	if(Banque[timersuspected] == 0)
	{
		Banque[timersuspected] = -1;
		BankAlarm();
		SendMessageInRange(30.0, GTRPVaultDigiCode[0][px], GTRPVaultDigiCode[0][py], GTRPVaultDigiCode[0][pz], COLOR_ALARM, "Un des employés de la banque a entendu un tir et a activé l'alarme !");
	}
	if(Banque[alarm])
	{
	    if(Banque[timeralarm] > 0) Banque[timeralarm]--;
	    else
	    {
	        Banque[timeralarm] = TIMERALARM;
	        PlayAudioStreamInRange(60.0, GTRPBankHack[0][px], GTRPBankHack[0][py], GTRPBankHack[0][pz], "https://gtrp.fr/media/uploads/alarmbank.mp3");
	    }
	    if(Banque[timergrill] > 0)
		{
			if(Banque[timergrill] == 15)
			{
			    SendFormatMessageInRange(10.0,GTRPGrillClosed[0][px], GTRPGrillClosed[0][py], GTRPGrillClosed[0][pz], -1, "La grille va se fermer dans %i secondes !", Banque[timergrill]);
			}
			Banque[timergrill]--;
		}
	    if(Banque[timergrill] == 0)
	    {
	        MoveDynamicObject(Banque[vaultgrill], GTRPGrillClosed[0][px], GTRPGrillClosed[0][py], GTRPGrillClosed[0][pz], 1.0, GTRPGrillClosed[0][rx], GTRPGrillClosed[0][ry], GTRPGrillClosed[0][rz]);
			Banque[timergrill] = -1;
	    }
	}
	
	if(Banque[timerc4] > 0)
 	{
  		Banque[timerc4]--;
    }
	if(Banque[timerc4] == 0)
	{
 		Banque[timerc4] = -1;
		SendMessageInRange(20.0, GTRPVaultDoor[0][px], GTRPVaultDoor[0][py], GTRPVaultDoor[0][pz], COLOR_ALARM, "Une explosion surgit !");
		SendMessageInRange(20.0, GTRPVaultDoor[0][px], GTRPVaultDoor[0][py], GTRPVaultDoor[0][pz], COLOR_ALARM, "Une explosion surgit, les voisins ont appelés la police");
		printf("[DEBUG] la porte du coffre-fort s'ouvre !");

		BankAlarm();
		Banque[isExploding] = false;
		Banque[isVaultOpen] = true; //Le coffre est ouvert !

		MoveDynamicObject(Banque[vaultdoor], GTRPVaultDoorExplode[0][px], GTRPVaultDoorExplode[0][py], GTRPVaultDoorExplode[0][pz], 3.0, GTRPVaultDoorExplode[0][rx], GTRPVaultDoorExplode[0][ry], GTRPVaultDoorExplode[0][rz]);
		CreateExplosion(GTRPVaultDoor[0][px], GTRPVaultDoor[0][py], GTRPVaultDoor[0][pz], 12, 5.0);
	}
	/*if(Banque[timerperceuse] > 0)
	{
	  Banque[timerperceuse]--;
	}
	if(Banque[timerperceuse] == 0)
	{
		SendMessageInRange(20.0, GTRPVaultDoor[0][px], GTRPVaultDoor[0][py], GTRPVaultDoor[0][pz], COLOR_ALARM, "La perceuse s'est arreté... tout semble s'être bien deroulé");
		printf("[DEBUG] La porte est débloqué, elle s'ouvrira avec la touche N");
		Banque[isUnlocked] = true;
		Banque[timerperceuse]= -1;
		//Banque[isDrilling] = false;
	}*/
	if(Banque[timerpiratage] > 0)
	{
		Banque[timerpiratage]--;
	}
	if(Banque[timerpiratage] == 0)
	{
		Banque[timerpiratage] = -1;
		new
			rand = random(4);
		switch(rand)
		{
			case 0: SendClientMessage(Banque[hacker], -1, "Le piratage a réussit mais vous n'avez trouvé aucun code !");
			case 1:
			{
				SendClientMessage(Banque[hacker], COLOR_HACK_SUCCESS, "Le piratage a réussit et vous avez trouvé les codes !");
				new rando = Random(10000,90000),
					str[129];
				format(str, sizeof(str), "{1a7a3d}Accès autorisé, code de sécurité : "COLOR_HACK_CODE" %s", rando);
				SendClientMessage(Banque[hacker], -1, str);

			}
			default:
			{
				SendClientMessage(Banque[hacker], COLOR_ALARM, "Durant la tentative de piratage, les services ont détectés une intrusion et l'alarme a été activé !");
				BankAlarm();
			}
		}
		Banque[ishacking] = false;
		Banque[ishacked] = true;
		TogglePlayerControllable(Banque[hacker], 1);
		Banque[hacker] = -1;
	}
	return 1;
}

public Random(min, max)
{
    new a = random(max - min) + min;
    return a;
}


stock   RandomTimeGrill()
{
	new
	    rand = random(TIMERGRILLCLOSED_MAX),
	    result = TIMERGRILLCLOSED+rand;
	    
	return Banque[timergrill] = result;
}

stock BankAlarm()
{
    Banque[alarm] = true;
	if(Banque[timergrill] == -1) RandomTimeGrill();
	PlayAudioStreamInRange(60.0, GTRPVaultDigiCode[0][px], GTRPVaultDigiCode[0][py], GTRPVaultDigiCode[0][pz], "https://gtrp.fr/media/uploads/alarmbank.mp3");
	PlayAudioStreamInRange(60.0, GTRPBankAlarmExterior[0][px], GTRPBankAlarmExterior[0][py], GTRPBankAlarmExterior[0][pz], "https://gtrp.fr/media/uploads/alarmbank.mp3");
	return 1;
}

stock Usage(playerid, msg[])
{
    static
		string[STRING_NORMAL];
		
    format(string, sizeof(string), "[Usage]{BFC0C2} %s", msg);
    SendClientMessage(playerid, 0xd74d4dAA, string);
    return 1;
}

stock Erreur(playerid, msg[])
{
    static
		string[STRING_NORMAL];
    format(string, sizeof(string), "[Erreur]{d74d4d} %s", msg);
    SendClientMessage(playerid,0xb62525AA,string);
    return 1;
}
