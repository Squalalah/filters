//////
///
//////
///
//////
///     				CE FILTERSCRIPT EST EN ETAT DE PROTOTYPE.
//////  IL N'Y A DONC AUCUNE REEL OPTIMISATION AINSI QUE D'AGENCEMENT (beauté) DU CODE.²
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
#define HOLDING(%0) \
	((newkeys & (%0)) == (%0)) //Définit le fait qu'une touche est ENFONCÉ
	
#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0))) //Définit si la touché est PRESSÉ

#define KEY_AIM KEY_HANDBRAKE //On définit une touche "KEY_AIM" qui voudra dire "Touche pour viser, soit le clic droit".



new
	Actor[10], //créer un tableau pouvant contenir 10 ID d'acteur
	Text3D:label[3],
	bool:braquage = false, //Variable booléeenne déclarant si un braquage est en cours (true) ou non (false)
	bool:freeze = false, //Variable booléenne déclarant si l'acteur au comptoir de la banque a les mains en l'air (true) ou non (false)
	bool:vaultopen = false,
	bool:iscollecting[MAX_PLAYERS] = false,
	bool:hasrobmoney[MAX_PLAYERS] = false,
	bool:isdrilling = false,
	timerperceuse,
	timeractor,
	c4[MAX_PLAYERS] = 0,
	vaultvalue = 200000,
	pickupmoney[MAX_PLAYERS];
	

public OnFilterScriptInit()
{
	Actor[0] = CreateActor(0, 1590.9358, 2410.5222, 1140.0670, 0.1459); // Créer un acteur et place son ID dans le tableau Actor (index 0)
	print("FS bankrobbery lancé");
	label[0] = Create3DTextLabel("Position porte coffre banque", 0x008080FF, 1585.4679, 2419.3369, 1140.0670, 40.0, 0, 0);
	label[1] = Create3DTextLabel("Position coffre banque", 0x008080FF, 1591.4941, 2418.3335, 1140.0670, 40.0, 0, 0);
	label[2] = Create3DTextLabel("Position pc pirater", 0x008080FF, 1588.3864, 2410.6130, 1140.0670, 40.0, 0, 0);
	
	return 1;
}

public OnFilterScriptExit()
{
	for(new i = 0; i < 3;i++) Delete3DTextLabel(label[i]);
	DestroyActor(Actor[0]);
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
	if (strcmp("/poserc4", cmdtext, true) == 0)
	{
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, 1585.4679, 2419.3369, 1140.0670)) return SendClientMessage(playerid, -1, "Vous n'êtes pas devant le coffre !");
		//Si le joueur est à la banque, à la porte du coffre fort.
  		if(!braquage) return SendClientMessage(playerid, -1, "Le braquage n'est pas lancé !");
	    if(c4[playerid] != 3) return SendClientMessage(playerid, -1, "Vous n'avez pas 3 pains de c4 sur vous !");
	    if(vaultopen) return SendClientMessage(playerid, -1, "Pourquoi vouloir détruire une porte ouvert ?!");

	    c4[playerid] = 0;
	    SendClientMessage(playerid, -1, "C4 posé, celui-ci a explosé");
	    SendClientMessage(playerid, -1, "En entendant un énorme bruit d'explosion, les voisins ont appelés la police");
		SendClientMessage(playerid, -1, "[DEBUG] la porte s'ouvre !");
		vaultopen = true; //Le coffre est ouvert !
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
		if(isdrilling) return SendClientMessage(playerid, -1, "Une perceuse est déjà en marche !");
	    isdrilling = true;
	    
		SendClientMessage(playerid, -1, "[DEBUG] La perceuse est lancée");
		timerperceuse = SetTimer("TimerPerceuse", 180000, false);
		return 1;
	}
	
	if(strcmp("/pirater", cmdtext, true) == 0)
	{
	    if(!IsPlayerInRangeOfPoint(playerid, 2.0, 1590.9358, 2410.5222, 1140.0670)) return SendClientMessage(playerid, -1, "Vous n'êtes pas devant le comptoir !");
	    if(!braquage) return SendClientMessage(playerid, -1, "La banque n'est pas braquée !");
	    if(!freeze) return SendClientMessage(playerid, -1, "L'alarme a coupé l'accès aux données");
	    
		TogglePlayerControllable(playerid, 0);
		GameTextForPlayer(playerid, "Piratage en cours...", 30000, 2);
		SetTimerEx("Timer30s", 30000, false, "i", playerid);
		
		return 1;
	}
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
	    new id = GetPlayerTargetActor(playerid); //On récupère l'id de l'acteur qu'il vise (ou pas)
	    if(id == INVALID_ACTOR_ID) return 1; // Si l'ID recupéré est invalide (le joueur ne vise pas un acteur), on va directement à la fin de la Callback.
	    
     	if(id == Actor[0]) //Si l'ID récupéré est le même que dans le tableau Actor (index 0), donc le banquier.
     	{
			if(!freeze && !braquage) // Si le banquier n'a pas les mains en l'air et que le braquage n'est pas lancé
			{
     	    	ApplyActorAnimation(Actor[0], "ped", "handsup", 4.1, 0, 0, 0, 1, 0);
     	    	SendClientMessageToAll(-1, "Le banquier a été braqué !");
     	    	SendClientMessageToAll(-1, "[DEBUG] Le braquage a commencé, il faut maintenant : poser C4 sur le coffre, le percer ou pirater le PC du comptoir");
     	    	timeractor = SetTimerEx("Timer15s", 15000, false, "i", Actor[0]); // On lance un timer qui s'executera dans 15 secondes, si il n'a pas été rebraqué par la suite.
     	    	freeze = true;
     	    	braquage = true;
     	    	return 1;
			}
			else if(braquage && freeze) //Si il a déjà les mains en l'air et/ou que le braquage est lancé, on relance le timer avant qu'il active l'alarme.
			{
				KillTimer(timeractor);
				timeractor = SetTimerEx("Timer15s", 15000, false, "i", Actor[0]);
				return 1;
			}
     	}
	}
	
	if(PRESSED(KEY_NO))
	{
	    if(IsPlayerInRangeOfPoint(playerid, 2.0, 1591.4941, 2418.3335, 1140.0670)) //Si le joueur est dans le coffre
	    {
	        if(!braquage) return 1;
	        if(iscollecting[playerid]) return 1;
	        if(vaultvalue == 0) return SendClientMessage(playerid, -1, "Il n'y a plus d'argent !");
	        
	        iscollecting[playerid] = true;
	        SendClientMessage(playerid, -1, "[DEBUG]Vous collectez l'argent");
	        TogglePlayerControllable(playerid,0);
	        ApplyAnimation(playerid, "POLICE", "CopTraf_Come", 4.1, 1, 1, 1, 0, 0, 0); //Animation où le joueur prend l'argent devant lui, celle-ci continuera jusqu'à appuyer sur ENTRER.

            GameTextForPlayer(playerid, "ENTRER pour quitter le mode collecte", 5000, 2);
            return 1;
	    }
	    
	    if(IsPlayerInRangeOfPoint(playerid, 2.0, 1585.4679, 2419.3369, 1140.0670)) //Si le joueur est devant la porte du coffre qui a été percé !
	    {
	        if(!braquage) return 1;
	        if(!isdrilling) return 1;
	        
			SendClientMessageToAll(-1, "[DEBUG] La porte s'ouvre !");
			//Code pour moove la porte
			return 1;
	    
	    }
	}
	
	if(PRESSED(KEY_SECONDARY_ATTACK)) // Si il appuie sur ENTRER
	{
	    if(IsPlayerInRangeOfPoint(playerid, 2.0, 1591.4941, 2418.3335, 1140.0670)) //Si le joueur est dans le coffre
	    {
	        if(!braquage) return 1;
	        if(!iscollecting[playerid]) return 1;
	        
	        iscollecting[playerid] = false;
	        SendClientMessage(playerid, -1, "[DEBUG] Le joueur récolte 200.000 dollars");
	        GivePlayerMoney(playerid, 200000);
	        vaultvalue = 0;
	        SendClientMessage(playerid, -1, "[DEBUG] Vous pouvez vous enfuir !");
	        TogglePlayerControllable(playerid, 1);
	        hasrobmoney[playerid] = true; //Il a bien volé de l'argent !
	        
	        return 1;
	    }
	    
	}

	return 1;
}


forward Timer15s(id);

public Timer15s(id)
{
	SendClientMessageToAll(-1, "Le banquier a donné l'alerte grace au bouton sous le guichet");
	ClearActorAnimations(id);
	return 1;
}

forward Timer30s(playerid);
public Timer30s(playerid)
{
	new
		rand = random(4);
	switch(rand)
	{
	    case 0:
	    {
	        SendClientMessage(playerid, -1, "Le piratage a réussit mais vous n'avez trouvé aucun code !");
	    }
	    case 1:
	    {
	    	SendClientMessage(playerid, -1, "Le piratage a réussit et vous avez trouvé les codes !");
	    	new
	    	    rando[5],
	    	    str[30];
			for(new i = 0; i < 5; i++)
			{
			    rando[i] = random(10);
			}
			format(str, sizeof(str), "%i%i%i%i%i", rando[0], rando[1], rando[2], rando[3], rando[4]);

	    }
		default:
		{
		    SendClientMessage(playerid, -1, "Durant la tentative de piratage, les services ont détectés une intrusion et l'alarme a été activé !");
		    //la police est alerté
		}
	}
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

