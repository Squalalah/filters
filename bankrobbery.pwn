//////
///
//////
///
//////
///     				CE FILTERSCRIPT EST EN ETAT DE PROTOTYPE.
//////  IL N'Y A DONC AUCUNE REEL OPTIMISATION AINSI QUE D'AGENCEMENT (beauté) DU CODE.
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
	((newkeys & (%0)) == (%0)) //Définit le fait qu'une touche est ENFONCÉE
	
#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0))) //Définit si la touché est PRESSÉE
	
#define PRESSING(%0,%1) \
	(%0 & (%1)) //Définit si une touche est pressée ACTUELLEMENT

#define KEY_AIM KEY_HANDBRAKE //On définit une touche "KEY_AIM" qui voudra dire "Touche pour viser, soit le clic droit".
#define MONEYPERSEC 500 //Somme "donné à chaque seconde" pendant que le braqueur remplit son sac dans le coffre.(n'est pas donné chaque seconde, mais quand la personne arretera de remplir son sac)
#define TIMERACTOR 99999999 //Temps avant que l'acteur n'active l'alarme après avoir été braqué (en millisecondes)
#define TIMERPERCEUSE 10000 //Temps avant que la perceuse n'ouvre le coffre (en millisecondes)
#define TIMERHACKING 10000 //Temps avant que le piratage se finisse (en millisecondes)
#define ERROR_BANKCODE 3 //Nombre d'erreurs possible dans le code de la banque avant que l'alerte soit donnée.

///~~~~~~~~ ENUMS ~~~~~~~~///

enum
	bInfos
{
	actorID,
	bool: isActorFreeze, //Variable booléenne déclarant si l'acteur au comptoir de la banque a les mains en l'air (true) ou non (false)
	bool: isBraquage, //Variable booléeenne déclarant si un braquage est en cours (true) ou non (false)
	bool: isVaultOpen, //Variable booléenne déclarant si le coffre est ouvert ou non.
	bool: isDrilling, //Variable booléenne déclarant si le coffre est en train d'être percé ou non.
	bool: alarm, //Variable booléenne déclarant si l'alarme est activé ou non.
	bool: ishacking, //Variable booléenne déclarant si l'ordinateur du comptoir --> est en train d'être piraté <--
	bool: ishacked, //Variable booléenne déclarant si l'ordinateur du comptoir --> a déjà été piraté <--
	timerperceuse, //Variable stockant le timer pour que la perceuse ouvre le coffre
	timeractor, //Variable stockant le timer pour que l'acteur active l'alarme à la fin du timer
	code, //Variable stockant le code généré si le piratage réussit
	errorcode,//Variable stockant le nombre d'echec du code, une fois qu'il atteint le nombre définit (DEFINE ERROR_BANKCODE), l'alarme se déclenche
	vaultvalue, //Variable stockant le contenu de la banque (en argent pour les braqueurs)
	vaultdoor,
	moneyobject
};

///~~~~~~~~ VARS ~~~~~~~~///

new
	Text3D:label[3],
	bool:iscollecting[MAX_PLAYERS] = false,
	bool:hasrobmoney[MAX_PLAYERS] = false,
	c4[MAX_PLAYERS] = 0,
	pickupmoney[MAX_PLAYERS],
	recupmoney[MAX_PLAYERS],
	Banque[bInfos];
	

public OnFilterScriptInit()
{
	Banque[actorID] = CreateActor(0, -1973.1815,137.6681,27.6875,267.0490); // Créer un acteur et place son ID dans le tableau Actor (index 0)
	Banque[isActorFreeze] = false;
	Banque[isBraquage] = false;
	Banque[isVaultOpen] = false;
	Banque[isDrilling] = false;
	Banque[alarm] = false;
	Banque[ishacking] = false;
	Banque[ishacked] = false;
	Banque[vaultvalue] = 200000;
	Banque[errorcode] = 0;

	print("FS bankrobbery lancé");
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
	if (strcmp("/poserc4", cmdtext, true) == 0)
	{
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, -1979.5, 136.60000610352, 27.799999237061)) return SendClientMessage(playerid, -1, "Vous n'êtes pas devant le coffre !");
		//Si le joueur est à la banque, à la porte du coffre fort.
  		if(!Banque[isBraquage]) return SendClientMessage(playerid, -1, "Le braquage n'est pas lancé !");
	    if(c4[playerid] != 3) return SendClientMessage(playerid, -1, "Vous n'avez pas 3 pains de c4 sur vous !");
	    if(Banque[isVaultOpen]) return SendClientMessage(playerid, -1, "Pourquoi vouloir détruire une porte ouvert ?!");

	    SendClientMessage(playerid, -1, "C4 posé, celui-ci a explosé");
	    SendClientMessage(playerid, -1, "En entendant un énorme bruit d'explosion, les voisins ont appelés la police");
		SendClientMessage(playerid, -1, "[DEBUG] la porte s'ouvre !");
		Banque[isVaultOpen] = true; //Le coffre est ouvert !
		c4[playerid] = 0;
		
		MoveObject(Banque[vaultdoor], -1979.5999755859, 139.30000305176, 27.799999237061, 3.0);
			//MoveObject sur la porte afin qu'elle s'ouvre, ou explose...
		return 1;
	}

	if (strcmp("/getc4", cmdtext, true) == 0)
	{
	    SendClientMessage(playerid, -1, "Vous avez obtenu 3 pains de C4");
	    c4[playerid] = 3;
	    return 1;
	}
	
	if (strcmp("/poserperceuse", cmdtext, true) == 0)
	{
		if(Banque[isDrilling]) return SendClientMessage(playerid, -1, "Une perceuse est déjà en marche !");
		if(Banque[isVaultOpen]) return SendClientMessage(playerid, -1, "Le coffre fort est déjà ouvert !");
	    Banque[isDrilling] = true;
	    
		SendClientMessage(playerid, -1, "[DEBUG] La perceuse est lancée");
		Banque[timerperceuse] = SetTimer("TimerPerceuse", TIMERPERCEUSE, false);
		return 1;
	}
	
	if(strcmp("/pirater", cmdtext, true) == 0)
	{
	    if(!IsPlayerInRangeOfPoint(playerid, 2.0, -1970.0134,137.7848,27.6875)) return SendClientMessage(playerid, -1, "Vous n'êtes pas devant le comptoir !");
	    if(!Banque[isBraquage]) return SendClientMessage(playerid, -1, "La banque n'est pas braquée !");
	    if(Banque[alarm]) return SendClientMessage(playerid, -1, "L'alarme a coupé l'accès aux données");
	    if(Banque[ishacking]) return SendClientMessage(playerid, -1, "L'ordinateur est déjà en cours de piratage !");
	    if(Banque[ishacked]) return SendClientMessage(playerid, -1, "L'ordinateur a déjà été piraté !");
	    
		TogglePlayerControllable(playerid, 0);
		GameTextForPlayer(playerid, "Piratage en cours...", TIMERHACKING, 1);
		SetTimerEx("Timerpiratage", TIMERHACKING, false, "i", playerid); // timer permettant de pirater
		Banque[ishacking] = true;
		return 1;
	}

	if(strcmp("/alarme", cmdtext, true) == 0)
	{
	    if(!Banque[alarm]) return SendClientMessage(playerid, -1, "L'alarme est déjà coupée !");

		Banque[alarm] = false;
		SendClientMessage(playerid, -1, "L'alarme a été desactivée !");
		return 1;
	}
	
	if(strcmp("/code", cmdtext, true, 5) == 0)
	{
	    new
	        mdp;
		if(sscanf(cmdtext[6], "i", mdp)) return SendClientMessage(playerid, -1, "Utilisation : /code <code>");
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, -1979.5, 136.60000610352, 27.799999237061)) return SendClientMessage(playerid, -1, "Vous n'êtes pas devant le coffre !");
		if(!Banque[isBraquage]) return SendClientMessage(playerid, -1, "La banque n'est pas braqué !");
		if(Banque[alarm]) return SendClientMessage(playerid, -1, "L'alarme a desactivé l'ouverture de la porte magnétiquement");
		if(Banque[isVaultOpen]) return SendClientMessage(playerid, -1, "Le coffre est déjà ouvert !");
		if(mdp != Banque[code])
		{
		    Banque[errorcode]++;
			SendClientMessage(playerid, -1, "[ERREUR] : Code incorrect !");
			if(Banque[errorcode] == ERROR_BANKCODE)
			{
				Banque[errorcode] = 0;
				Banque[alarm] = true;
				return SendClientMessage(playerid, -1, "Une alarme retentie, peut-être à cause de vos echecs répétés au mot de passe ?");
			}
			return 1;
		}
		SendClientMessage(playerid, -1, "[SUCCES] Code validé !");
		MoveObject(Banque[vaultdoor], -1979.5999755859, 139.30000305176, 27.799999237061, 3.0);
		Banque[isVaultOpen] = true;
		
	    return 1;
	}
	if(strcmp("/fermer", cmdtext, true) == 0) return MoveObject(Banque[vaultdoor], -1979.5, 136.60000610352, 27.799999237061, 3.0);
	if(strcmp("/arme", cmdtext, true) == 0) return GivePlayerWeapon(playerid, 25, 9999);
	return 0;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{

	for(new i = 0, j = GetPlayerPoolSize(); i < j; i++)
	{
	    if(pickupmoney[i] == pickupid)
	    {
	        GivePlayerMoney(playerid, 200000);
	        SendClientMessage(playerid, -1, "Vous avez récupéré un sac rempli d'argent... vous vous étonnez vous mêmes.");
	        break;
	    }
	}
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(HOLDING(KEY_AIM)) //Si le joueur enfonce la touche "KEY_AIM" correspond au clic droit par défaut.
	{
	    new
			id = GetPlayerTargetActor(playerid); //On récupère l'id de l'acteur qu'il vise (ou pas)
			
	    if(id != INVALID_ACTOR_ID)// Si l'ID recupéré est invalide (le joueur ne vise pas un acteur), on va directement à la fin de la Callback.
		{
	     	if(id == Banque[actorID]) //Si l'ID récupéré est le même que dans le tableau Actor (index 0), donc le banquier.
	     	{
				if(!Banque[isActorFreeze] && !Banque[isBraquage]) // Si le banquier n'a pas les mains en l'air et que le braquage n'est pas lancé
				{
	     	    	ApplyActorAnimation(Banque[actorID], "ped", "handsup", 4.1, 0, 0, 0, 1, 0);
	     	    	SendClientMessageToAll(-1, "Le banquier a été braqué !");
	     	    	SendClientMessageToAll(-1, "[DEBUG] Le braquage a commencé, il faut maintenant : poser C4 sur le coffre, le percer ou pirater le PC du comptoir");
	     	    	Banque[timeractor] = SetTimerEx("Timeractor", TIMERACTOR, false, "i", Banque[actorID]); // On lance un timer qui s'executera dans 15 secondes, si il n'a pas été rebraqué par la suite.
	     	    	Banque[isActorFreeze] = true;
	     	    	Banque[isBraquage] = true;
	     	    	return 1;
				}
				else if(Banque[isBraquage] && Banque[isActorFreeze] && !Banque[alarm]) //Si il a déjà les mains en l'air et/ou que le braquage est lancé, on relance le timer avant qu'il active l'alarme.
				{
					KillTimer(Banque[timeractor]);
					Banque[timeractor] = SetTimerEx("Timeractor", TIMERACTOR, false, "i", Banque[actorID]);
					SendClientMessage(playerid, -1, "Vous l'avez rebraqué !");
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
	        
	        SendClientMessage(playerid, -1, "[DEBUG] Vous collectez l'argent");
	        ApplyAnimation(playerid, "POLICE", "CopTraf_Come", 4.1, 1, 1, 1, 0, 0, 0); //Animation où le joueur prend l'argent devant lui, celle-ci continuera jusqu'à appuyer sur ENTRER.
            GameTextForPlayer(playerid, "ENTRER pour quitter le mode collecte", 5000, 1);
            TogglePlayerControllable(playerid,0);
            iscollecting[playerid] = true;
            recupmoney[playerid] = GetTickCount();
            return 1;
	    }
	    
	    if(IsPlayerInRangeOfPoint(playerid, 3.0, -1979.5999755859, 136.30000305176, 27.799999237061)) //Si le joueur est devant la porte du coffre qui a été percé !
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
			    GivePlayerMoney(playerid, Banque[vaultvalue]);
				money = Banque[vaultvalue];
				Banque[vaultvalue] = 0;
				SendClientMessage(playerid, -1, "Vous semblez avoir pris les derniers billets !");
			}
			else
			{
			    GivePlayerMoney(playerid, result);
			    money = result;
			    Banque[vaultvalue] -= result;
			}
			
			format(str, sizeof(str), "Vous avez rempli votre sac avec %i$", money);
			SendClientMessage(playerid, -1, str);
	        SendClientMessage(playerid, -1, "[DEBUG] Vous pouvez vous enfuir !");
	        TogglePlayerControllable(playerid, 1);
	        hasrobmoney[playerid] = true; //Il a bien volé de l'argent !
         	iscollecting[playerid] = false;
	        return 1;
	    }
	}
	return 1;
}


forward Timeractor(id);

public Timeractor(id)
{
	SendClientMessageToAll(-1, "Le banquier a donné l'alerte grace au bouton sous le guichet");
	Banque[alarm] = true;
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
	    case 0: SendClientMessage(playerid, -1, "Le piratage a réussit mais vous n'avez trouvé aucun code !");
	    case 1:
	    {
	    	SendClientMessage(playerid, -1, "Le piratage a réussit et vous avez trouvé les codes !");
	    	new
	    	    rando[5],
	    	    str[126];
			for(new i = 0; i < 5; i++) rando[i] = random(10);
			format(str, sizeof(str), "%i%i%i%i%i", rando[0], rando[1], rando[2], rando[3], rando[4]);
			Banque[code] = strval(str);
			format(str, sizeof(str), "Accès autorisé, code de sécurité : %i%i%i%i%i", rando[0], rando[1], rando[2], rando[3], rando[4]);
			SendClientMessage(playerid, -1, str);

	    }
		default:
		{
		    SendClientMessage(playerid, -1, "Durant la tentative de piratage, les services ont détectés une intrusion et l'alarme a été activé !");
		    Banque[alarm] = true;
		    //la police est alerté
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
	SendClientMessageToAll(-1, "La perceuse s'est arreté... tout semble s'être bien deroulé");
	SendClientMessageToAll(-1, "[DEBUG] La porte est débloqué, elle s'ouvrira avec la touche N");
	return 1;
}

