//////
///
//////
///
//////
///     				CE FILTERSCRIPT EST EN ETAT DE PROTOTYPE.
//////  IL N'Y A DONC AUCUNE REEL OPTIMISATION AINSI QUE D'AGENCEMENT (beaut�) DU CODE.
///
//////                          Imagin� et Cod� par Squalalah
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

//SendMessageInRange(int:range, float:x, float:y, float:z, color, str[], args[])

#define SendMessageInRange(%0,%1,%2,%3,%4,%5,%6) \
	for(new i = 0, j = GetPlayerPoolSize(); i <= j;i++) if(IsPlayerInRangeOfPoint(i,(%0),(%1),(%2),(%3))) \
	    format(strrange, sizeof(strrange),(%5),(%6)), SendClientMessage(i,(%4), strrange)

#define HOLDING(%0) \
	((newkeys & (%0)) == (%0)) //D�finit le fait qu'une touche est ENFONC�E

#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0))) //D�finit si la touch� est PRESS�E
	
#define PRESSING(%0,%1) \
	(%0 & (%1)) //D�finit si une touche est press�e ACTUELLEMENT

#define KEY_AIM KEY_HANDBRAKE //On d�finit une touche "KEY_AIM" qui voudra dire "Touche pour viser, soit le clic droit".

#define MONEYPERSEC 537 			 //Somme "donn� � chaque seconde" pendant que le braqueur remplit son sac dans le coffre.(n'est pas donn� chaque seconde, mais quand la personne arretera de remplir son sac)
#define TIMERACTOR 99999999 	    //Temps avant que l'acteur n'active l'alarme apr�s avoir �t� braqu� (en millisecondes)
#define TIMERPERCEUSE 10000 	   //Temps avant que la perceuse n'ouvre le coffre (en millisecondes)
#define TIMERHACKING 10000 		  //Temps avant que le piratage se finisse (en millisecondes)
#define TIMERC4EXPLODE 10 		 //Temps avant que le C4 n'explose (en secondes)
#define TIMERGRILLCLOSED 20     //Temps minimum avant que la grille de la banque ne se ferme
#define TIMERGRILLCLOSED_MAX 10//===//Temps maximum avant que la grille de la banque ne se ferme
#define TIMERALARM 190 		   	   //Temps apr�s lequel l'alarme se relance (le son) (en secondes)
#define ERROR_BANKCODE 3 	  	  //Nombre d'erreurs possible dans le code de la banque avant que l'alerte soit donn�e.
#define MINUTE_BANK_ROB_WAIT 120 //Nombre de minutes necessaires � attendre entre deux braquages.
#define SECOND_GRAB_MONEY 30 	//Nombres de secondes maximum avant l'interdiction de reprendre de l'argent dans le coffre-fort.

#define MAX_BAGS 2 //d�finit le nombre de sac de butin maximum en m�me temps

#define COLOR_ORANGE 0x9e5e1aFF
#define COLOR_ALARM 0xc42d2dFF
#define COLOR_HACK_SUCCESS 0x1a7a3dFF
#define COLOR_HACK_CODE "{2c7f7f}"

#define MSG_NOT_FRONT_VAULT "{c42d2d}[ERREUR] Vous n'�tes pas devant le coffre de la banque !"
#define MSG_NOT_FRONT_BAR "{c42d2d}[ERREUR] Vous n'�tes pas devant le comptoir de la banque !"
#define MSG_VAULT_ALREADY_OPEN "Le coffre est d�j� ouvert !"
#define MSG_ROBBERY_NOT_STARTED "{c42d2d}[ERREUR] Le braquage n'a pas d�marr� !"

///~~~~~~~~ FORWARDS ~~~~~~~~///

forward Random(min, max);
forward Timer1s();
forward StopAudioStreamInRange(Float:radius, Float:x, Float:y, Float:z);
forward PlayAudioStreamInRange(Float:radius, Float:x, Float:y, Float:z, link[]);
forward Timerc4(playerid);
forward TimerPerceuse();
forward Timerpiratage(playerid);
forward Timeractor(id);


///~~~~~~~~ ENUMS ~~~~~~~~///

enum
	bInfos
{
	actorID[5],
	bool: isActorFreeze,  //Variable bool�enne d�clarant si l'acteur au comptoir de la banque a les mains en l'air (true) ou non (false)
	bool: isBraquage, 	 //Variable bool�eenne d�clarant si un braquage est en cours (true) ou non (false)
	bool: isVaultOpen,  //Variable bool�enne d�clarant si le coffre est ouvert ou non.
	bool: isDrilling,  //Variable bool�enne d�clarant si le coffre est en train d'�tre perc� ou non.
	bool: isExploding,// Variable bool�enne d�clarant si la porte du coffre-fort est sur le point d'exploser ou non.
	bool: alarm, 	 //Variable bool�enne d�clarant si l'alarme est activ� ou non.
	bool: ishacking,   //Variable bool�enne d�clarant si l'ordinateur du comptoir --> est en train d'�tre pirat� <--
	bool: ishacked,   //Variable bool�enne d�clarant si l'ordinateur du comptoir --> a d�j� �t� pirat� <--
	grabbingMoney,   //Variable contenant l'ID du premier joueur ayant recolt� l'argent.
	timerperceuse,  //Variable stockant le timer pour que la perceuse ouvre le coffre
	timeractor,    //Variable stockant le timer pour que l'acteur active l'alarme � la fin du timer
	timergrabmoney,   //Variable contenant le "timer" (GetTickCount), permettant de laisser x secondes au braqueur pour prendre l'argent.
	timerbraquage,   // Variable contenant le "timer" (GetTickCount) avant de repermettre le braquage
	timeralarm,     // Variable permettant de relancer l'alarme.
	timergrill,    // Variable permettant de fermer la grille al�atoirement.
	code,          //Variable stockant le code g�n�r� si le piratage r�ussit
	errorcode, 	  //Variable stockant le nombre d'echec du code, une fois qu'il atteint le nombre d�finit (DEFINE ERROR_BANKCODE), l'alarme se d�clenche
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
	VaultDoor[0][3] = {float:-1979.5, float:136.60000610352, float:27.799999237061},
	Vault[0][3] = {float:-1984.0999755859, float:137.69999694824, float:27.10000038147 },
	BankBar[0][3] = {float:-1970.0134, float:137.7848, float:27.6875},

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
	{ 1591.05286,  2389.51416,  1137.37585, 0.0, 0.0, 0.0, 13}
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
	};



///~~~~~~~~ VARS ~~~~~~~~///

new
	Text3D:label[3],
	bool:iscollecting[MAX_PLAYERS] = false,
	bool:hasrobmoney[MAX_PLAYERS] = false,
	c4[MAX_PLAYERS] = 0,
	pickupmoney[MAX_PLAYERS],
	recupmoney[MAX_PLAYERS],
	Banque[bInfos],
	bagbank[MAX_PLAYERS],
	bagbankvalue[MAX_PLAYERS],
	bags[MAX_BAGS][bagInfos],
	Actor[10],
	strrange[128];

	

public OnFilterScriptInit()
{
	Banque[actorID][0] = CreateActor(240, GTRPPosActor[0][px], GTRPPosActor[0][py],GTRPPosActor[0][pz],GTRPPosActor[0][rx]);
	Actor[0] = CreateActor(71, 1586.5034, 2392.5320, 1137.1508, 266.000);
	SetActorVirtualWorld(Banque[actorID][0], GTRPPosActor[0][vw]);
	SetActorVirtualWorld(Actor[0], 13);
	Banque[isActorFreeze] = false;
	Banque[isBraquage] = false;
	Banque[isVaultOpen] = false;
	Banque[isDrilling] = false;
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
	
	ApplyActorAnimation(Actor[0], "FOOD", "FF_Dam_Left", 4.1, 0, 0, 0, 1, 0);
	ApplyActorAnimation(Actor[0], "FOOD", "FF_Dam_Left", 4.1, 0, 0, 0, 1, 0);
	
	SetTimer("Timer1s", 1000, true);

	print("FS bankrobbery lanc�");
	
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
 		bagbank[i] = -1;
		bagbankvalue[i] = 0;
	}
	
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
	DestroyActor(Actor[0]);
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
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, GTRPVaultDoor[0][px], GTRPVaultDoor[0][py], GTRPVaultDoor[0][pz])) return SendClientMessage(playerid, -1, MSG_NOT_FRONT_VAULT);
		//Si le joueur est � la banque, � la porte du coffre fort.
  		if(!Banque[isBraquage]) return SendClientMessage(playerid, -1, MSG_ROBBERY_NOT_STARTED);
	    if(c4[playerid] != 3) return SendClientMessage(playerid, -1, "Vous n'avez pas 3 pains de c4 sur vous !");
	    if(Banque[isVaultOpen]) return SendClientMessage(playerid, -1, "Pourquoi vouloir d�truire une porte ouvert ?!");
	    if(Banque[isExploding]) return SendClientMessage(playerid, -1, "3 pains de C4 sont pos�s sur la porte et �mm�tent un bip de plus en plus fort...");
		new
		    str[126];
		format(str, sizeof(str), "Les pains de C4 ont bien �t� pos�s, ceux-ci exploseront dans %i secondes", TIMERC4EXPLODE);
		SendClientMessage(playerid, -1, str);
		
		Banque[isExploding] = true;
		SetTimerEx("Timerc4", TIMERC4EXPLODE*1000, false, "i", playerid);
		c4[playerid] = 0;
		return 1;
	}

	if (strcmp("/testgetc4", cmdtext, true) == 0)
	{
	    SendClientMessage(playerid, -1, "Vous avez obtenu 3 pains de C4");
	    c4[playerid] = 3;
	    return 1;
	}
	
	if (strcmp("/testposerperceuse", cmdtext, true) == 0)
	{
	    if(!IsPlayerInRangeOfPoint(playerid, 2.0, GTRPVaultDoor[0][px], GTRPVaultDoor[0][py], GTRPVaultDoor[0][pz])) return SendClientMessage(playerid, -1, MSG_NOT_FRONT_VAULT);
	    if(!Banque[isBraquage]) return SendClientMessage(playerid, -1, MSG_ROBBERY_NOT_STARTED);
		if(Banque[isDrilling]) return SendClientMessage(playerid, -1, "Une perceuse est d�j� en marche !");
		if(Banque[isVaultOpen]) return SendClientMessage(playerid, -1, MSG_VAULT_ALREADY_OPEN);

		Banque[isDrilling] = true;
		SendClientMessage(playerid, -1, "[DEBUG] La perceuse est lanc�e");
		Banque[timerperceuse] = SetTimer("TimerPerceuse", TIMERPERCEUSE, false);
		
		return 1;
	}
	
	if(strcmp("/testpirater", cmdtext, true) == 0)
	{
	    if(!IsPlayerInRangeOfPoint(playerid, 2.0, GTRPBankHack[0][px], GTRPBankHack[0][py], GTRPBankHack[0][pz])) return SendClientMessage(playerid, COLOR_ORANGE, MSG_NOT_FRONT_BAR);
	    if(!Banque[isBraquage]) return SendClientMessage(playerid, COLOR_ORANGE, MSG_ROBBERY_NOT_STARTED);
	    if(Banque[alarm]) return SendClientMessage(playerid, COLOR_ALARM, "L'alarme a coup� l'acc�s aux donn�es");
	    if(Banque[ishacking]) return SendClientMessage(playerid, COLOR_ORANGE, "L'ordinateur est d�j� en cours de piratage !");
	    if(Banque[ishacked]) return SendClientMessage(playerid, COLOR_ORANGE, "L'ordinateur a d�j� �t� pirat� !");
	    
		TogglePlayerControllable(playerid, 0);
		GameTextForPlayer(playerid, "Piratage en cours...", TIMERHACKING, 1);
		SetTimerEx("Timerpiratage", TIMERHACKING, false, "i", playerid); // timer permettant de pirater
		Banque[ishacking] = true;
		return 1;
	}

	if(strcmp("/testalarme", cmdtext, true) == 0)
	{
	    if(!IsPlayerInRangeOfPoint(playerid, 2.0, GTRPPosDisableAlarm[0][px], GTRPPosDisableAlarm[0][py], GTRPPosDisableAlarm[0][pz])) return SendClientMessage(playerid, -1, "Vous n'�tes pas au bon endroit !");
	    if(!Banque[alarm]) return SendClientMessage(playerid, COLOR_ALARM, "L'alarme est d�j� coup�e !");
	    
		Banque[alarm] = false;
		Banque[isActorFreeze] = false;
		ClearActorAnimations(Banque[actorID][0]);
		
		MoveDynamicObject(Banque[vaultgrill], GTRPGrillOpen[0][px], GTRPGrillOpen[0][py], GTRPGrillOpen[0][pz], 1.0, GTRPGrillOpen[0][rx], GTRPGrillOpen[0][ry], GTRPGrillOpen[0][rz]);
		Banque[timergrill] = -1;
		
		StopAudioStreamInRange(60.0, GTRPBankAlarmExterior[0][px], GTRPBankAlarmExterior[0][py], GTRPBankAlarmExterior[0][pz]);
		StopAudioStreamInRange(60.0, GTRPVaultDigiCode[0][px], GTRPVaultDigiCode[0][py], GTRPVaultDigiCode[0][pz]);
		
		SendClientMessage(playerid, COLOR_ALARM, "L'alarme a �t� desactiv�e !");
		return 1;
	}
	
 	if(strcmp(cmdtext, "/testcode", true) == 9)
	{
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, GTRPVaultDigiCode[0][px], GTRPVaultDigiCode[0][py], GTRPVaultDigiCode[0][pz])) return SendClientMessage(playerid, -1, MSG_NOT_FRONT_VAULT);
		if(!Banque[isBraquage]) return SendClientMessage(playerid, -1, MSG_ROBBERY_NOT_STARTED);
		if(Banque[alarm]) return SendClientMessage(playerid, COLOR_ALARM, "L'alarme a desactiv� l'ouverture de la porte magn�tiquement");
		if(Banque[isVaultOpen]) return SendClientMessage(playerid, -1, MSG_VAULT_ALREADY_OPEN);
		new
			mdp,
			str[128];
		if(sscanf(cmdtext, "si", str, mdp)) SendClientMessage(playerid, -1, "Usage: /code <code>");

		if(mdp != Banque[code])
		{
		    Banque[errorcode]++;
			SendClientMessage(playerid, COLOR_ALARM, "[ERREUR] : Code incorrect !");
			if(Banque[errorcode] == ERROR_BANKCODE)
			{
				Banque[errorcode] = 0;
				return SendClientMessage(playerid, COLOR_ALARM, "Une alarme retentie, peut-�tre � cause de vos echecs r�p�t�s au mot de passe ?");
			}
			return 1;
		}
		SendClientMessage(playerid, COLOR_HACK_SUCCESS, "[SUCCES] Code valid� !");
		MoveDynamicObject(Banque[vaultdoor], GTRPVaultDoorOpened[0][px], GTRPVaultDoorOpened[0][py], GTRPVaultDoorOpened[0][pz], 3.0, GTRPVaultDoorOpened[0][rx], GTRPVaultDoorOpened[0][ry], GTRPVaultDoorOpened[0][rz]);
		Banque[isVaultOpen] = true;
		return 1;
	}
	/*if(strcmp("/testcode", cmdtext, true) == 0)
	{
	    new
	        mdp;
		if(sscanf(cmdtext[6], "i", mdp)) return SendClientMessage(playerid, -1, "Utilisation : /code <code>");
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, GTRPVaultDigiCode[0][px], GTRPVaultDigiCode[0][py], GTRPVaultDigiCode[0][pz])) return SendClientMessage(playerid, -1, MSG_NOT_FRONT_VAULT);
		if(!Banque[isBraquage]) return SendClientMessage(playerid, -1, MSG_ROBBERY_NOT_STARTED);
		if(Banque[alarm]) return SendClientMessage(playerid, COLOR_ALARM, "L'alarme a desactiv� l'ouverture de la porte magn�tiquement");
		if(Banque[isVaultOpen]) return SendClientMessage(playerid, -1, MSG_VAULT_ALREADY_OPEN);
		if(mdp != Banque[code])
		{
		    Banque[errorcode]++;
			SendClientMessage(playerid, -1, "[ERREUR] : Code incorrect !");
			if(Banque[errorcode] == ERROR_BANKCODE)
			{
				Banque[errorcode] = 0;
				return SendClientMessage(playerid, COLOR_ALARM, "Une alarme retentie, peut-�tre � cause de vos echecs r�p�t�s au mot de passe ?");

			}
			return 1;
		}
		SendClientMessage(playerid, -1, "[SUCCES] Code valid� !");
		MoveDynamicObject(Banque[vaultdoor], GTRPVaultDoorOpened[0][px], GTRPVaultDoorOpened[0][py], GTRPVaultDoorOpened[0][pz], 3.0, GTRPVaultDoorOpened[0][rx], GTRPVaultDoorOpened[0][ry], GTRPVaultDoorOpened[0][rz]);
		Banque[isVaultOpen] = true;
		
	    return 1;
	}*/
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
		
		format(str, sizeof(str), "Vous avez laiss� tomber votre sac de butin contenant %i$.", bagbankvalue[playerid]);
		SendClientMessage(playerid, -1, str);
		bagbankvalue[playerid] = 0;
		return 1;
	}
	if(strcmp("/fermer", cmdtext, true) == 0) return MoveDynamicObject(Banque[vaultdoor], -1979.5, 136.60000610352, 27.799999237061, 3.0);
	if(strcmp("/arme", cmdtext, true) == 0) return GivePlayerWeapon(playerid, 25, 9999);
	return 0;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	for(new i = 0; i < MAX_BAGS; i++)
	{
	    if(pickupid == bags[i][bagidpickup])
		{
		    bagbank[playerid] = SetPlayerAttachedObject(playerid, 0, 1550, 1, 0.129999, -0.257999, 0.000000, 4.200002, 83.499992, 155.999984);
		    DestroyDynamicObject(bags[i][bagid]);
		    bagbankvalue[playerid] = bags[0][bagcontent];
			new
			    str[126];
			format(str, sizeof(str), "Vous avez trouv� %i$.", bagbankvalue[playerid]);
			SendClientMessage(playerid, -1, str);
			DestroyDynamicPickup(pickupid);
		}
	}
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys == KEY_AIM) //Si le joueur appuie sur le clic droit correspond au clic droit par d�faut.
	{
	    new
			id = GetPlayerTargetActor(playerid); //On r�cup�re l'id de l'acteur qu'il vise (ou pas)
			
	    if(id != INVALID_ACTOR_ID)// Si l'ID recup�r� est invalide (le joueur ne vise pas un acteur), on va directement � la fin de la Callback.
		{
	     	if(id == Banque[actorID][0]) //Si l'ID r�cup�r� est le m�me que dans le tableau Actor (index 0), donc le banquier.
	     	{
	     	    if(!IsBraquageAvailable() && Banque[isActorFreeze]) return SendClientMessage(playerid, -1, "Le braquage de banque est indisponible (en cours)");
				if(!Banque[isActorFreeze] && !Banque[isBraquage]) // Si le banquier n'a pas les mains en l'air et que le braquage n'est pas lanc�
				{
	     	    	ApplyActorAnimation(Banque[actorID][0], "ped", "handsup", 4.1, 0, 0, 0, 1, 0);
	     	    	SendClientMessageToAll(-1, "Le banquier a �t� braqu� !");
	     	    	SendClientMessageToAll(-1, "[DEBUG] Le braquage a commenc�, il faut maintenant : poser C4 sur le coffre, le percer ou pirater le PC du comptoir");
	     	    	Banque[timeractor] = SetTimerEx("Timeractor", TIMERACTOR, false, "i", Banque[actorID][0]); // On lance un timer qui s'executera dans 15 secondes, si il n'a pas �t� rebraqu� par la suite.
	     	    	Banque[isActorFreeze] = true;
	     	    	Banque[isBraquage] = true;
					Banque[timerbraquage] = GetTickCount();
	     	    	return 1;
				}
				else if(Banque[isActorFreeze] && !Banque[alarm]) //Si il a d�j� les mains en l'air et/ou que le braquage est lanc�, on relance le timer avant qu'il active l'alarme.
				{
					KillTimer(Banque[timeractor]);
					Banque[timeractor] = SetTimerEx("Timeractor", TIMERACTOR, false, "i", Banque[actorID][0]);
					SendClientMessage(playerid, -1, "Vous l'avez rebraqu� !");
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
	        if(Banque[grabbingMoney] != playerid && Banque[grabbingMoney] != -1) return SendClientMessage(playerid, -1, "Quelqu'un d'autre a d�j� commenc� � prendre l'argent du coffre !");
	        if(Banque[grabbingMoney] == playerid && GetTickCount() - Banque[timergrabmoney] > SECOND_GRAB_MONEY*1000)
			{
				SendClientMessage(playerid, -1, "Vous ne pouvez plus prendre de l'argent !");
				return 1;
			}

			if(Banque[grabbingMoney] == -1) Banque[grabbingMoney] = playerid;
	        
	        SendClientMessage(playerid, -1, "[DEBUG] Vous collectez l'argent");
	        ApplyAnimation(playerid, "POLICE", "CopTraf_Come", 4.1, 1, 1, 1, 0, 0, 0); //Animation o� le joueur prend l'argent devant lui, celle-ci continuera jusqu'� appuyer sur ENTRER.
            GameTextForPlayer(playerid, "ENTRER pour quitter le mode collecte", 5000, 1);
            TogglePlayerControllable(playerid, 0);
            iscollecting[playerid] = true;
            recupmoney[playerid] = GetTickCount();
            return 1;
	    }
	    
	    if(IsPlayerInRangeOfPoint(playerid, 3.0, GTRPVaultDoor[0][px], GTRPVaultDoor[0][py], GTRPVaultDoor[0][pz])) //Si le joueur est devant la porte du coffre qui a �t� perc� !
	    {
	        if(!Banque[isBraquage]) return 1;
	        if(!Banque[isDrilling]) return 1;
	        if(Banque[isVaultOpen]) return 1;
			SendClientMessageToAll(-1, "[DEBUG] La porte s'ouvre !");
			MoveDynamicObject(Banque[vaultdoor], GTRPVaultDoorOpened[0][px], GTRPVaultDoorOpened[0][py], GTRPVaultDoorOpened[0][pz], 3.0, GTRPVaultDoorOpened[0][rx], GTRPVaultDoorOpened[0][ry], GTRPVaultDoorOpened[0][rz]);
			Banque[isVaultOpen] = false;
			//Code pour moove la porte
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
        	Banque[isBraquage] = false;

	        if(bagbank[playerid] == -1) bagbank[playerid] = SetPlayerAttachedObject(playerid, 0, 1550, 1, 0.129999, -0.257999, 0.000000, 4.200002, 83.499992, 155.999984);
	        Banque[timergrabmoney] = GetTickCount();
	        TogglePlayerControllable(playerid, 1);
			printf("[DEBUG] bagbankvalue[playerid] = %i", bagbankvalue[playerid]);
	        
	        hasrobmoney[playerid] = true; //Il a bien vol� de l'argent !
         	iscollecting[playerid] = false;
	        return 1;
	    }
	}
	return 1;
}


public Timeractor(id)
{
	SendClientMessageToAll(-1, "Le banquier a donn� l'alerte grace au bouton sous le guichet");
	BankAlarm();
	ClearActorAnimations(id);
	return 1;
}

public Timerpiratage(playerid)
{
	new
		rand = random(4);
	switch(rand)
	{
	    case 0: SendClientMessage(playerid, -1, "Le piratage a r�ussit mais vous n'avez trouv� aucun code !");
	    case 1:
	    {
	    	SendClientMessage(playerid, COLOR_HACK_SUCCESS, "Le piratage a r�ussit et vous avez trouv� les codes !");
	    	new rando = Random(10000,90000);
			new
				str[128];
			format(str, sizeof(str), "{1a7a3d}Acc�s autoris�, code de s�curit� : "COLOR_HACK_CODE" %s", rando);
			SendClientMessage(playerid, -1, str);

	    }
		default:
		{
		    SendClientMessage(playerid, COLOR_ALARM, "Durant la tentative de piratage, les services ont d�tect�s une intrusion et l'alarme a �t� activ� !");
		    BankAlarm();
		}
	}
	Banque[ishacking] = false;
	Banque[ishacked] = true;
	TogglePlayerControllable(playerid, 1);
	return 1;
}

public TimerPerceuse()
{
	SendClientMessageToAll(-1, "La perceuse s'est arret�... tout semble s'�tre bien deroul�");
	SendClientMessageToAll(-1, "[DEBUG] La porte est d�bloqu�, elle s'ouvrira avec la touche N");
	return 1;
}

public Timerc4(playerid)
{
	SendClientMessage(playerid, -1, "C4 pos�, celui-ci a explos�");
	SendClientMessage(playerid, -1, "En entendant un �norme bruit d'explosion, les voisins ont appel�s la police");
	SendClientMessageToAll(-1, "[DEBUG] la porte s'ouvre !");
	
	BankAlarm();
	Banque[isExploding] = false;
	Banque[isVaultOpen] = true; //Le coffre est ouvert !
	
	MoveDynamicObject(Banque[vaultdoor], GTRPVaultDoorExplode[0][px], GTRPVaultDoorExplode[0][py], GTRPVaultDoorExplode[0][pz], 3.0, GTRPVaultDoorExplode[0][rx], GTRPVaultDoorExplode[0][ry], GTRPVaultDoorExplode[0][rz]);
	CreateExplosion(GTRPVaultDoor[0][px], GTRPVaultDoor[0][py], GTRPVaultDoor[0][pz], 12, 5.0);
	
}

stock IsBraquageAvailable()
{
	if(GetTickCount() - Banque[timerbraquage] > MINUTE_BANK_ROB_WAIT*60000) return true;
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

public Timer1s()
{
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
			Banque[timergrill]--;
			if(Banque[timergrill] == 15)
			{
			    SendClientMessageToAll(-1, "La grille va se fermer dans 15 secondes !");
			    SendMessageInRange(10.0,GTRPGrillClosed[0][px], GTRPGrillClosed[0][py], GTRPGrillClosed[0][pz], -1, "La grille va se fermer dans %i secondes !", Banque[timergrill]);
			}
		}
	    else if(Banque[timergrill] == 0)
	    {
	        MoveDynamicObject(Banque[vaultgrill], GTRPGrillClosed[0][px], GTRPGrillClosed[0][py], GTRPGrillClosed[0][pz], 1.0, GTRPGrillClosed[0][rx], GTRPGrillClosed[0][ry], GTRPGrillClosed[0][rz]);
			Banque[timergrill] = -1;
	    }
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
	RandomTimeGrill();
	PlayAudioStreamInRange(60.0, GTRPVaultDigiCode[0][px], GTRPVaultDigiCode[0][py], GTRPVaultDigiCode[0][pz], "https://gtrp.fr/media/uploads/alarmbank.mp3");
	PlayAudioStreamInRange(60.0, GTRPBankAlarmExterior[0][px], GTRPBankAlarmExterior[0][py], GTRPBankAlarmExterior[0][pz], "https://gtrp.fr/media/uploads/alarmbank.mp3");
	return 1;
}

strtok(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offset = index;
	new result[20];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}







