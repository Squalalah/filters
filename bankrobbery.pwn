//////
///
//////
///
//////
///     				CE FILTERSCRIPT EST EN ETAT DE PROTOTYPE.
//////  IL N'Y A DONC AUCUNE REEL OPTIMISATION AINSI QUE D'AGENCEMENT (beaut�) DU CODE.
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


///~~~~~~~~ DEFINES ~~~~~~~~///

#define HOLDING(%0) \
	((newkeys & (%0)) == (%0)) //D�finit le fait qu'une touche est ENFONC�E
	
#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0))) //D�finit si la touch� est PRESS�E
	
#define PRESSING(%0,%1) \
	(%0 & (%1)) //D�finit si une touche est press�e ACTUELLEMENT

#define KEY_AIM KEY_HANDBRAKE //On d�finit une touche "KEY_AIM" qui voudra dire "Touche pour viser, soit le clic droit".

#define MONEYPERSEC 537 //Somme "donn� � chaque seconde" pendant que le braqueur remplit son sac dans le coffre.(n'est pas donn� chaque seconde, mais quand la personne arretera de remplir son sac)
#define TIMERACTOR 99999999 //Temps avant que l'acteur n'active l'alarme apr�s avoir �t� braqu� (en millisecondes)
#define TIMERPERCEUSE 10000 //Temps avant que la perceuse n'ouvre le coffre (en millisecondes)
#define TIMERHACKING 10000 //Temps avant que le piratage se finisse (en millisecondes)
#define TIMERC4EXPLODE 10 //Temps avant que le C4 n'explose (en secondes)
#define TIMERALARM 19 //Temps apr�s lequel l'alarme se relance
#define ERROR_BANKCODE 3 //Nombre d'erreurs possible dans le code de la banque avant que l'alerte soit donn�e.
#define MINUTE_BANK_ROB_WAIT 120 //Nombre de minutes necessaires � attendre entre deux braquages
#define SECOND_GRAB_MONEY 30 //Nombres de secondes maximum avant l'interdiction de reprendre de l'argent dans le coffre-fort

#define MAX_BAGS 2 //d�finit le nombre de sac de butin maximum en m�me temps

#define COLOR_ORANGE 0x9e5e1aFF
#define COLOR_ALARM 0xc42d2dFF
#define COLOR_HACK_SUCCESS 0x1a7a3dFF
#define COLOR_HACK_CODE "{2c7f7f}"

#define MSG_NOT_FRONT_VAULT "{c42d2d}[ERREUR] Vous n'�tes pas devant le coffre de la banque !"
#define MSG_NOT_FRONT_BAR "{c42d2d}[ERREUR] Vous n'�tes pas devant le comptoir de la banque !"
#define MSG_VAULT_ALREADY_OPEN "Le coffre est d�j� ouvert !"
#define MSG_ROBBERY_NOT_STARTED "{c42d2d}[ERREUR] Le braquage n'a pas d�marr� !"



///~~~~~~~~ ENUMS ~~~~~~~~///

enum
	bInfos
{
	actorID,
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
	code,          //Variable stockant le code g�n�r� si le piratage r�ussit
	errorcode, 	  //Variable stockant le nombre d'echec du code, une fois qu'il atteint le nombre d�finit (DEFINE ERROR_BANKCODE), l'alarme se d�clenche
	vaultvalue,  //Variable stockant le contenu de la banque (en argent pour les braqueurs)
	vaultdoor,  //Variable contenant l'id de l'objet de la porte
	moneyobject//Variable contenant l'id de l'objet du sac
	
};

enum bagInfos
{
	bagid,
	bagidpickup,
	bagcontent
}

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
	bags[MAX_BAGS][bagInfos];

	

public OnFilterScriptInit()
{
	Banque[actorID] = CreateActor(0, -1973.1815,137.6681,27.6875,267.0490); // Cr�er un acteur et place son ID dans le tableau Actor (index 0)
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
	
	SetTimer("Timer1s", 1000, true);

	print("FS bankrobbery lanc�");
	
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
 		bagbank[i] = -1;
		bagbankvalue[i] = 0;
	}
	
	label[0] = Create3DTextLabel("Position porte coffre banque", 0x008080FF, -1979.5, 136.60000610352, 27.799999237061, 40.0, 0, 0);
	label[1] = Create3DTextLabel("Position coffre banque", 0x008080FF, -1984.0999755859, 137.69999694824, 27.10000038147, 40.0, 0, 0);
	label[2] = Create3DTextLabel("Position pc pirater", 0x008080FF, -1970.0134,137.7848,27.6875, 40.0, 0, 0);
	
	Banque[vaultdoor] = CreateObject(2634, -1979.5, 136.60000610352, 27.799999237061, 0.0, 0.0, -90.0);
	Banque[moneyobject] = CreateObject(1550, -1984.0999755859, 137.69999694824, 27.10000038147, 0.0, 0.0, 0.0);

	return 1;
}

public OnFilterScriptExit()
{
	for(new i = 0; i < 3;i++) Delete3DTextLabel(label[i]);
	DestroyActor(Banque[actorID]);
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
		ResetPlayerMoney(playerid);
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
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, -1979.5, 136.60000610352, 27.799999237061)) return SendClientMessage(playerid, -1, MSG_NOT_FRONT_VAULT);
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
	    if(!IsPlayerInRangeOfPoint(playerid, 2.0, -1979.5, 136.60000610352, 27.799999237061)) return SendClientMessage(playerid, -1, MSG_NOT_FRONT_VAULT);
		if(Banque[isDrilling]) return SendClientMessage(playerid, -1, "Une perceuse est d�j� en marche !");
		if(Banque[isVaultOpen]) return SendClientMessage(playerid, -1, MSG_VAULT_ALREADY_OPEN);

		Banque[isDrilling] = true;
		SendClientMessage(playerid, -1, "[DEBUG] La perceuse est lanc�e");
		Banque[timerperceuse] = SetTimer("TimerPerceuse", TIMERPERCEUSE, false);
		
		return 1;
	}
	
	if(strcmp("/testpirater", cmdtext, true) == 0)
	{
	    if(!IsPlayerInRangeOfPoint(playerid, 2.0, -1970.0134,137.7848,27.6875)) return SendClientMessage(playerid, COLOR_ORANGE, MSG_NOT_FRONT_BAR);
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
	    if(!Banque[alarm]) return SendClientMessage(playerid, COLOR_ALARM, "L'alarme est d�j� coup�e !");

		Banque[alarm] = false;
		SendClientMessage(playerid, COLOR_ALARM, "L'alarme a �t� desactiv�e !");
		return 1;
	}
	
	if(strcmp("/testcode", cmdtext, true, 5) == 0)
	{
	    new
	        mdp;
		if(sscanf(cmdtext[6], "i", mdp)) return SendClientMessage(playerid, -1, "Utilisation : /code <code>");
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, -1979.5, 136.60000610352, 27.799999237061)) return SendClientMessage(playerid, -1, MSG_NOT_FRONT_VAULT);
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
				Banque[alarm] = true;
                PlayAudioStreamInRange(60.0, -1969.6277, 137.9382, 27.6875, "https://gtrp.fr/media/uploads/alarmbank.mp3");
				return SendClientMessage(playerid, COLOR_ALARM, "Une alarme retentie, peut-�tre � cause de vos echecs r�p�t�s au mot de passe ?");

			}
			return 1;
		}
		SendClientMessage(playerid, -1, "[SUCCES] Code valid� !");
		MoveObject(Banque[vaultdoor], -1979.5999755859, 139.30000305176, 27.799999237061, 3.0);
		Banque[isVaultOpen] = true;
		
	    return 1;
	}
	if(strcmp("/testbraquage", cmdtext, true) == 0)
	{
	    if(IsBraquageAvailable()) return SendClientMessage(playerid, -1, "Le braquage de banque est disponible !");
	    else return SendClientMessage(playerid, -1, "Le braquage de banque est indisponible !");
	}
	
	if(strcmp("/testposerbutin", cmdtext, true) == 0)
	{
	    if(bagbank[playerid] == -1) return SendClientMessage(playerid, -1, "Vous n'avez aucun sac de butin !");
	    if(bagbankvalue[playerid] <= 0) return SendClientMessage(playerid, -1, "Votre sac de butin est vide !");
		new
			Float:pos[3],
			str[200];
			
		RemovePlayerAttachedObject(playerid, 0);
	 	DestroyObject(bagbank[playerid]);
		GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	 	
		bags[0][bagid] = CreateObject(1550, pos[0]+2, pos[1], pos[2], 0.0, 0.0, 0.0);
		bags[0][bagcontent] = bagbankvalue[playerid];
		bags[0][bagidpickup] = CreatePickup(1210, 8, pos[0]+2, pos[1], pos[2], GetPlayerVirtualWorld(playerid));
		
		format(str, sizeof(str), "Vous avez laiss� tomber votre sac de butin contenant %i$.", bagbankvalue[playerid]);
		SendClientMessage(playerid, -1, str);
		bagbankvalue[playerid] = 0;
		return 1;
	}
	if(strcmp("/testfermer", cmdtext, true) == 0) return MoveObject(Banque[vaultdoor], -1979.5, 136.60000610352, 27.799999237061, 3.0);
	if(strcmp("/testarme", cmdtext, true) == 0) return GivePlayerWeapon(playerid, 25, 9999);
	return 0;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{

	for(new i = 0, j = GetPlayerPoolSize(); i < j; i++)
	{
	    if(pickupmoney[i] == pickupid)
	    {
	        GivePlayerMoney(playerid, 200000);
	        SendClientMessage(playerid, -1, "Vous avez r�cup�r� un sac rempli d'argent... vous vous �tonnez vous m�mes.");
	        break;
	    }
	    return 1;
	}
	
	for(new i = 0; i < MAX_BAGS; i++)
	{
	    if(pickupid == bags[i][bagidpickup])
		{
		    bagbank[playerid] = SetPlayerAttachedObject(playerid, 0, 1550, 1, 0.129999, -0.257999, 0.000000, 4.200002, 83.499992, 155.999984);
		    DestroyObject(bags[i][bagid]);
		    bagbankvalue[playerid] = bags[0][bagcontent];
			new
			    str[126];
			format(str, sizeof(str), "Vous avez trouv� %i$.", bagbankvalue[playerid]);
			SendClientMessage(playerid, -1, str);
			DestroyPickup(pickupid);
		}
	}
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(HOLDING(KEY_AIM)) //Si le joueur enfonce la touche "KEY_AIM" correspond au clic droit par d�faut.
	{
	    new
			id = GetPlayerTargetActor(playerid); //On r�cup�re l'id de l'acteur qu'il vise (ou pas)
			
	    if(id != INVALID_ACTOR_ID)// Si l'ID recup�r� est invalide (le joueur ne vise pas un acteur), on va directement � la fin de la Callback.
		{
	     	if(id == Banque[actorID]) //Si l'ID r�cup�r� est le m�me que dans le tableau Actor (index 0), donc le banquier.
	     	{
	     	    if(!IsBraquageAvailable()) return SendClientMessage(playerid, -1, "Le braquage de banque est indisponible");
				if(!Banque[isActorFreeze] && !Banque[isBraquage]) // Si le banquier n'a pas les mains en l'air et que le braquage n'est pas lanc�
				{
	     	    	ApplyActorAnimation(Banque[actorID], "ped", "handsup", 4.1, 0, 0, 0, 1, 0);
	     	    	SendClientMessageToAll(-1, "Le banquier a �t� braqu� !");
	     	    	SendClientMessageToAll(-1, "[DEBUG] Le braquage a commenc�, il faut maintenant : poser C4 sur le coffre, le percer ou pirater le PC du comptoir");
	     	    	Banque[timeractor] = SetTimerEx("Timeractor", TIMERACTOR, false, "i", Banque[actorID]); // On lance un timer qui s'executera dans 15 secondes, si il n'a pas �t� rebraqu� par la suite.
	     	    	Banque[isActorFreeze] = true;
	     	    	Banque[isBraquage] = true;
					Banque[timerbraquage] = GetTickCount();
	     	    	return 1;
				}
				else if(Banque[isBraquage] && Banque[isActorFreeze] && !Banque[alarm]) //Si il a d�j� les mains en l'air et/ou que le braquage est lanc�, on relance le timer avant qu'il active l'alarme.
				{
					KillTimer(Banque[timeractor]);
					Banque[timeractor] = SetTimerEx("Timeractor", TIMERACTOR, false, "i", Banque[actorID]);
					SendClientMessage(playerid, -1, "Vous l'avez rebraqu� !");
					return 1;
				}
	     	}
		 }
	}
	
	if(PRESSED(KEY_NO))
	{
	    if(IsPlayerInRangeOfPoint(playerid, 2.0, -1984.0999755859, 137.69999694824, 27.10000038147)) //Si le joueur est dans le coffre
	    {
	        if(!Banque[isBraquage]) return 1;
	        if(iscollecting[playerid]) return 1;
	        if(!Banque[isVaultOpen]) return 1;
	        if(Banque[vaultvalue] == 0) return SendClientMessage(playerid, -1, "Il n'y a plus d'argent !");
	        if(Banque[grabbingMoney] != playerid && Banque[grabbingMoney] != -1) return SendClientMessage(playerid, -1, "Quelqu'un d'autre a d�j� commenc� � prendre l'argent du coffre !");
	        if(Banque[grabbingMoney] == playerid && GetTickCount() - Banque[timergrabmoney] > SECOND_GRAB_MONEY*1000)
			{
				SendClientMessage(playerid, -1, "Vous ne pouvez plus prendre de l'argent !");
				Banque[isBraquage] = false;
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
	    
	    if(IsPlayerInRangeOfPoint(playerid, 3.0, -1979.5999755859, 136.30000305176, 27.799999237061)) //Si le joueur est devant la porte du coffre qui a �t� perc� !
	    {
	        if(!Banque[isBraquage]) return 1;
	        if(!Banque[isDrilling]) return 1;
	        if(Banque[isVaultOpen]) return 1;
			SendClientMessageToAll(-1, "[DEBUG] La porte s'ouvre !");
			MoveObject(Banque[vaultdoor], -1979.5999755859, 139.30000305176, 27.799999237061, 3.0);
			Banque[isVaultOpen] = false;
			//Code pour moove la porte
			return 1;
	    
	    }
	}
	
	if(PRESSED(KEY_SECONDARY_ATTACK)) // Si il appuie sur ENTRER
	{
	    if(IsPlayerInRangeOfPoint(playerid, 2.0, -1984.0999755859, 137.69999694824, 27.10000038147)) //Si le joueur est dans le coffre
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


forward Timeractor(id);

public Timeractor(id)
{
	SendClientMessageToAll(-1, "Le banquier a donn� l'alerte grace au bouton sous le guichet");
	Banque[alarm] = true;
	PlayAudioStreamInRange(60.0, -1969.6277, 137.9382, 27.6875, "https://gtrp.fr/media/uploads/alarmbank.mp3");
	ClearActorAnimations(id);
	return 1;
}

forward Timerpiratage(playerid);
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
	    	new
	    	    rando[5],
	    	    str[126];
			for(new i = 0; i < 5; i++) rando[i] = random(10);
			format(str, sizeof(str), "%i%i%i%i%i", rando[0], rando[1], rando[2], rando[3], rando[4]);
			Banque[code] = strval(str);
			format(str, sizeof(str), "{1a7a3d}Acc�s autoris�, code de s�curit� : "COLOR_HACK_CODE" %i%i%i%i%i", rando[0], rando[1], rando[2], rando[3], rando[4]);
			SendClientMessage(playerid, -1, str);

	    }
		default:
		{
		    SendClientMessage(playerid, COLOR_ALARM, "Durant la tentative de piratage, les services ont d�tect�s une intrusion et l'alarme a �t� activ� !");
		    Banque[alarm] = true;
		    PlayAudioStreamInRange(60.0, -1969.6277, 137.9382, 27.6875, "https://gtrp.fr/media/uploads/alarmbank.mp3");
		}
	}
	Banque[ishacking] = false;
	Banque[ishacked] = true;
	TogglePlayerControllable(playerid, 1);
	return 1;
}

forward TimerPerceuse();
public TimerPerceuse()
{
	SendClientMessageToAll(-1, "La perceuse s'est arret�... tout semble s'�tre bien deroul�");
	SendClientMessageToAll(-1, "[DEBUG] La porte est d�bloqu�, elle s'ouvrira avec la touche N");
	return 1;
}

forward Timerc4(playerid);
public Timerc4(playerid)
{
	SendClientMessage(playerid, -1, "C4 pos�, celui-ci a explos�");
	SendClientMessage(playerid, -1, "En entendant un �norme bruit d'explosion, les voisins ont appel�s la police");
	SendClientMessageToAll(-1, "[DEBUG] la porte s'ouvre !");
	
	Banque[isExploding] = false;
	Banque[isVaultOpen] = true; //Le coffre est ouvert !
	
	MoveObject(Banque[vaultdoor], -1979.5999755859, 139.30000305176, 27.799999237061, 3.0);
	CreateExplosion(-1979.5999755859, 136.30000305176, 27.799999237061, 12, 5.0);
	
}

stock IsBraquageAvailable()
{
	if(GetTickCount() - Banque[timerbraquage] > MINUTE_BANK_ROB_WAIT*60000) return true;
	else return false;
}


forward PlayAudioStreamInRange(Float:radius, Float:x, Float:y, Float:z, link[]);
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

forward Timer1s();
public Timer1s()
{
	if(Banque[alarm])
	{
	    if(Banque[timeralarm] > 0) Banque[timeralarm]--;
	    else
	    {
	        Banque[timeralarm] = TIMERALARM;
	        PlayAudioStreamInRange(60.0, -1969.6277, 137.9382, 27.6875, "https://gtrp.fr/media/uploads/alarmbank.mp3");
	    }
	}
	return 1;
}


