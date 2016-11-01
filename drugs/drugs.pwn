#define FILTERSCRIPT

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~SYSTEME DE DROGUES~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~BY~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ SQUALALAH ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//~~~~~~~~~~~~ /INCLUDES ~~~~~~~~~~~~~~

#include <a_samp>
#include <sscanf2>
#include <streamer>

//~~~~~~~~~~~~ /DEFINES ~~~~~~~~~~~~~~~


#define VERSION 0.1

#define MAX_PLANTS_PER_FACT 30 //Nombre max de plante pour une faction
#define SCM SendClientMessage
#define TIME_DRUGS_PER_PERCENT 1 //Temps en secondes entre chaque pourcent (exemple : ici 1, donc il y aura 1 seconde qui s'écoulera entre 1% et 2% de maturité, 100*1 = 100secondes pour être à 100% de maturité)
#define PERCENT_OVER 110 //Nombre de pourcent de maturité minimum pour qu'une plante se dégrade et ne rapporte aucune graine et juste 1/2 feuilles
#define MIN_FEUILLE_OVER 1 //Minimum de feuille obtenu si la maturité dépasse PERCENT_OVER
#define MAX_FEUILLE_OVER 2 //Maximum de feuille obtenu si la maturité dépasse PERCENT_OVER
#define MIN_FEUILLE_PERFECT 1 //Minimum de feuille obtenu si la maturité est entre 100 et 110%
#define MIN_GRAINE_PERFECT 1 //Maximum de graine obtenu si la maturité est entre 100 et 110%
#define DIST 2.600000 //Range dans lequel doit être le joueur afin d'intérragir avec une plante

#define MAX_GANGS 2 //Définit cb de factions peuvent créer/ramasser de la drogue
#define ID_FACTION_GANG_1 1 //Définit quel est l'ID de la premiere faction illégale pouvant PLANTER la drogue
#define ID_FACTION_GANG_2 2 //Définit quel est l'ID de la deuxième faction illégale pouvant PLANTER la drogue

//~~~~~~~~~~~~ /ENUMS ~~~~~~~~~~~~~~~~~


enum drugInfos
{
	bool:isactive, //booléan permettant de savoir si la slot est utilisé par une plante ou non
	bool:arroser, //booléan vérifiant si la plante a été arrosé tout les 10% (timer1s)
	dId, //id de l'objet du champ
	Text3D:dIdLabel, //id du 3Dtextlabel
	dCreateur[MAX_PLAYER_NAME], //nom du createur
	Float:dX, //posX
	Float:dY, //posY
	Float:dZ, //posZ
	dMaturite, //INT - maturité de la plante (0 -> 150)
	dNbArroser, //INT - nombre de fois que la plante a été arrosée
	dTime, //temps en secondes passé entre chaque pourcent
}

//~~~~~~~~~~~~~ /VARS ~~~~~~~~~~~~~~~~~


new
	Drogue[MAX_GANGS][MAX_PLANTS_PER_FACT][drugInfos];
	
new
	pFaction[MAX_PLAYERS],
	Graines[MAX_PLAYERS],
	Feuilles[MAX_PLAYERS];
	


//~~~~~~~~~~~~~ /VARS ~~~~~~~~~~~~~~~~~


forward Timer1s();



//~~~~~~~~~~~ /CALLBACKS ~~~~~~~~~~~~~~




public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Système de drogue by Squalalah !");
	printf("VERSION -> %f", VERSION);
	print("--------------------------------------\n");
	SendClientMessageToAll(-1, "Ce message prouvant l'homosexualité de Leïto annonce que le filterscript a bien été chargé !");
	
	for(new i = 0; i < MAX_PLANTS_PER_FACT;i++)
	{
		for(new a = 0; a < MAX_GANGS; a++)
		{
	    	Drogue[a][i][isactive] = false;
		}
	}
	SetTimer("Timer1s", 1000, true);
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{
	pFaction[playerid] = -1;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/planter", cmdtext, true, 8) == 0)
	{
	    //PETIT CHAMP = 3409
		if(pFaction[playerid] == -1) return SCM(playerid, -1, "Vous n'êtes pas un thug !");
		if(Graines[playerid] <= 0) return SCM(playerid, -1, "Vous n'avez pas de graine !");
		if(GetDrogueDispo(playerid) == -1) return SCM(playerid, -1, "Le maximum de plantes a déjà été posé !");
		new
			champid = GetDrogueDispo(playerid),
			Float:pos[3],
			vw = GetPlayerVirtualWorld(playerid),
			interior = GetPlayerInterior(playerid),
			str[100],
			idgang = GetFac(playerid);
			
		GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		
		
		format(str, sizeof(str), "Champ de drogue n°%i.%i \n Maturite = 0% \n Elle semble asséchée", champid, idgang);

		Drogue[idgang][champid][isactive] = true;
		Drogue[idgang][champid][arroser] = false;
		Drogue[idgang][champid][dId] = CreateDynamicObject(19473, pos[0], pos[1], pos[2]-2.5, 0.0, 0.0, 0.0, vw, interior);
		Drogue[idgang][champid][dIdLabel] = Create3DTextLabel(str, 0x008080FF, pos[0], pos[1], pos[2], 10.0, vw, interior);
		Drogue[idgang][champid][dCreateur] = GetName(playerid);
		Drogue[idgang][champid][dX] = pos[0];
		Drogue[idgang][champid][dY] = pos[1];
		Drogue[idgang][champid][dZ] = pos[2];
		Drogue[idgang][champid][dMaturite] = 0;
		Drogue[idgang][champid][dNbArroser] = 0;
		Drogue[idgang][champid][dTime] = 0;
		Graines[playerid]--;
		//printf("Plante arrosé dans Drogue[%i], id %i et arroser = %b", idgang, champid, Drogue[idgang][champid][arroser]);
		return 1;
	}
	if (strcmp("/graine", cmdtext, true, 6) == 0)
	{
		if(pFaction[playerid] == -1) return SCM(playerid, -1, "Vous n'êtes pas un thug !");
		Graines[playerid] = 10;
		SCM(playerid, -1, "Vous avez eu 10 graines !");

		return 1;
	}
	
	if(strcmp("/thug", cmdtext, true, 5) == 0)
	{
		new
		    cmd[6],
		    id;
		if(sscanf(cmdtext, "s[6]i", cmd, id)) return SCM(playerid, -1, "Usage: /thug <id>");
		if(id < 0 || id > MAX_GANGS) return SCM(playerid, -1, "ID incorrect !");
		if(id != ID_FACTION_GANG_1 && id != ID_FACTION_GANG_2) return SCM(playerid, -1, "Cette faction n'existe pas !");
		
		if(id == ID_FACTION_GANG_1) pFaction[playerid] = 0;
		else if(id == ID_FACTION_GANG_2) pFaction[playerid] = 1;
	    SCM(playerid, -1, "Vous êtes devenu un énorme THUUUUG !");
	
	    return 1;
	}
	
	if(strcmp("/createur", cmdtext, true, 9) == 0)
	{
	    new
	        cmd[10],
			idchamp,
			idgang,
			str[100];
	        
	    if(sscanf(cmdtext, "s[10]ii", cmd, idchamp, idgang)) return SCM(playerid, -1, "Usage: /createur <idchamp> <idgang> (n°0.1 -> /createur 0 1)");
	    if(idchamp < 0 || idchamp >= MAX_PLANTS_PER_FACT) return SCM(playerid, -1, "ID champ incorrect !");
		if(idgang < 0 || idgang >= MAX_GANGS) return SCM(playerid, -1, "ID gang incorrect !");
		if(!Drogue[idgang][idchamp][isactive]) return SCM(playerid, -1, "Cette plante n'éxiste pas !");
		
	    format(str, sizeof(str), "Créateur de cette plante -> %s", GetCreatorDrogue(idchamp, idgang));
	    SCM(playerid, -1, str);
	    
	    return 1;
	}
	
	if(strcmp("/ramasser", cmdtext, true, 9) == 0)
	{
	    if(pFaction[playerid] == -1) return SCM(playerid, -1, "Vous n'êtes pas un THUG !");
	    new
			_:distance = GetNearestPlant(playerid);
	    //printf("distance /ramasser = %f", distance);
	    if(floatcmp(_:distance, _:DIST) == 1 || floatcmp(_:distance, _:0.0) == -1) return SendClientMessage(playerid, -1, "Aucune plante à proximité ou n'appartenant pas à votre faction !");
		new
		    id = GetNearestPlantId(playerid),
		    idgang = GetFac(playerid);

		if(Drogue[idgang][id][dMaturite] < 100) return SCM(playerid, -1, "Cela ne sert à rien de récolter une plante qui n'est pas arrivé à maturité !");

        Drogue[idgang][id][isactive] = false;
        Drogue[idgang][id][arroser] = false;
        DestroyDynamicObject(Drogue[idgang][id][dId]);
        Delete3DTextLabel(Drogue[idgang][id][dIdLabel]);
        Drogue[idgang][id][dX] = 0.0;
        Drogue[idgang][id][dY] = 0.0;
        Drogue[idgang][id][dZ] = 0.0;
		
		Drogue[idgang][id][dNbArroser] = 0;
		Drogue[idgang][id][dTime] = 0;
		
		new
  			str[128];
		if(Drogue[idgang][id][dMaturite] > PERCENT_OVER)
		{
  			new
			  	fe = Random(MIN_FEUILLE_OVER,MAX_FEUILLE_OVER);

			Feuilles[playerid] += fe;
		    SCM(playerid, -1, "La plante, n'ayant pas été traitée à temps, s'est détériorée.");
		    format(str, sizeof(str), "Vous obtenez aucune graine et %i feuilles.", fe);
		    SCM(playerid, -1, str);
		}
		else
		{
		    new
				nb = Random(MIN_GRAINE_PERFECT,2),
		        fe = Random(MIN_FEUILLE_PERFECT,Drogue[idgang][id][dNbArroser]);
		        
			if(Drogue[idgang][id][dNbArroser] == 0)
			{
				SCM(playerid, -1, "La plante, n'ayant jamais été arrosée, ne vous donne absolument rien");
			}
			else
			{
	            Graines[playerid] += nb;
	            Feuilles[playerid] += fe;
				format(str, sizeof(str), "Vous avez obtenu %i graines et %i feuilles.", nb, fe);
				SCM(playerid, -1, str);
			}
		}

		Drogue[idgang][id][dMaturite] = 0;

		return 1;
	}
	
	if(strcmp("/arroser", cmdtext, true, 8) == 0)
	{
	    if(pFaction[playerid] == -1) return SCM(playerid, -1, "Vous n'êtes pas un THUG !");
	    new
			_:distance = GetNearestPlant(playerid),
			str[128],
			idgang = GetFac(playerid);
			
	    //printf("distance /ramasser = %f", distance);
	    if(floatcmp(_:distance, _:DIST) == 1  || floatcmp(_:distance, _:0.0) == -1) return SendClientMessage(playerid, -1, "Aucune plante à proximité ou n'appartennant pas à votre faction !");
	    new
		    id = GetNearestPlantId(playerid);
		if(Drogue[idgang][id][dMaturite] >= 100) return SCM(playerid, -1, "Cela ne sert à rien d'arroser une plante étant déjà arrivée à maturité !");
		if(Drogue[idgang][id][arroser]) return SCM(playerid, -1, "La plante semble avoir suffisemment d'eau pour l'instant");
		
		format(str, sizeof(str), "Champ de drogue n°%i.%i \n Maturite = %i % \n Elle semble fraîche", id, idgang, Drogue[idgang][id][dMaturite]);
		Update3DTextLabelText(Drogue[idgang][id][dIdLabel], 0x008080FF, str);
		
		Drogue[idgang][id][arroser] = true;
		SCM(playerid, -1, "La plante a bien été arrosée !");
		//printf("Plante arrosé dans Drogue[%i], id %i et arroser = %b", idgang, id, Drogue[idgang][id][arroser]);
		return 1;
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public Timer1s()
{
	for(new a = 0; a < MAX_GANGS;a++)
	{
		for(new i = 0; i < MAX_PLANTS_PER_FACT;i++)
		{
		    Drogue[a][i][dTime]++;
		    if(Drogue[a][i][dTime] == TIME_DRUGS_PER_PERCENT)
		    {
			    if(Drogue[a][i][isactive])
			    {
					if(Drogue[a][i][dMaturite] < 100)
					{
						new
							Float:pos[3];
						GetDynamicObjectPos(Drogue[a][i][dId], pos[0], pos[1], pos[2]);

					    Drogue[a][i][dX] = pos[0];
					    Drogue[a][i][dY] = pos[1];
					    Drogue[a][i][dZ] = pos[2]+0.1;

					    new
							str[128];
						Drogue[a][i][dMaturite]++;
						//printf("Maturité plante n°%i.%i = %i", i, a, Drogue[a][i][dMaturite]);

						if(Drogue[a][i][arroser])
						{
						    format(str, sizeof(str), "Champ de drogue n°%i.%i \n Maturite = %i % \n Elle semble fraîche", i, a, Drogue[a][i][dMaturite]);
							Update3DTextLabelText(Drogue[a][i][dIdLabel], 0x008080FF, str);
						}
						else
						{
						    format(str, sizeof(str), "Champ de drogue n°%i.%i \n Maturite = %i %\nElle semble asséchée", i, a, Drogue[a][i][dMaturite]);
							Update3DTextLabelText(Drogue[a][i][dIdLabel], 0x008080FF, str);
						}

						switch(Drogue[a][i][dMaturite])
					    {
					        case 10:
					        {
					            SetDynamicObjectPos(Drogue[a][i][dId], pos[0], pos[1], pos[2]+0.1);
					            if(Drogue[a][i][arroser]) Drogue[a][i][dNbArroser]++;

								format(str, sizeof(str), "Champ de drogue n°%i.%i\n Maturite = %i%\nElle semble asséchée", i, a, Drogue[a][i][dMaturite]);
								Update3DTextLabelText(Drogue[a][i][dIdLabel], 0x008080FF, str);
								Drogue[a][i][arroser] = false;

							}
					        case 20:
					        {
					            SetDynamicObjectPos(Drogue[a][i][dId], pos[0], pos[1], pos[2]+0.1);
					            if(Drogue[a][i][arroser]) Drogue[a][i][dNbArroser]++;

								format(str, sizeof(str), "Champ de drogue n°%i.%i\n Maturite = %i%\nElle semble asséchée", i, a, Drogue[a][i][dMaturite]);
								Update3DTextLabelText(Drogue[a][i][dIdLabel], 0x008080FF, str);
								Drogue[a][i][arroser] = false;

							}
					        case 30:
					        {
					            SetDynamicObjectPos(Drogue[a][i][dId], pos[0], pos[1], pos[2]+0.1);
					            if(Drogue[a][i][arroser]) Drogue[a][i][dNbArroser]++;

								format(str, sizeof(str), "Champ de drogue n°%i.%i\n Maturite = %i%\nElle semble asséchée", i, a, Drogue[a][i][dMaturite]);
								Update3DTextLabelText(Drogue[a][i][dIdLabel], 0x008080FF, str);
								Drogue[a][i][arroser] = false;
								
							}
					        case 40:
					        {
					            SetDynamicObjectPos(Drogue[a][i][dId], pos[0], pos[1], pos[2]+0.1);
					            if(Drogue[a][i][arroser]) Drogue[a][i][dNbArroser]++;

								format(str, sizeof(str), "Champ de drogue n°%i.%i\n Maturite = %i%\nElle semble asséchée", i, a, Drogue[a][i][dMaturite]);
								Update3DTextLabelText(Drogue[a][i][dIdLabel], 0x008080FF, str);
								Drogue[a][i][arroser] = false;
								
							}
					        case 50:
					        {
					            SetDynamicObjectPos(Drogue[a][i][dId], pos[0], pos[1], pos[2]+0.1);
					            if(Drogue[a][i][arroser]) Drogue[a][i][dNbArroser]++;

								format(str, sizeof(str), "Champ de drogue n°%i.%i\n Maturite = %i%\nElle semble asséchée", i, a, Drogue[a][i][dMaturite]);
								Update3DTextLabelText(Drogue[a][i][dIdLabel], 0x008080FF, str);
								Drogue[a][i][arroser] = false;
								
							}
					        case 60:
					        {
					            SetDynamicObjectPos(Drogue[a][i][dId], pos[0], pos[1], pos[2]+0.1);
					            if(Drogue[a][i][arroser]) Drogue[a][i][dNbArroser]++;

								format(str, sizeof(str), "Champ de drogue n°%i.%i\n Maturite = %i%\nElle semble asséchée", i, a, Drogue[a][i][dMaturite]);
								Update3DTextLabelText(Drogue[a][i][dIdLabel], 0x008080FF, str);
								Drogue[a][i][arroser] = false;
								
							}
					        case 70:
					        {
					            SetDynamicObjectPos(Drogue[a][i][dId], pos[0], pos[1], pos[2]+0.1);
					            if(Drogue[a][i][arroser]) Drogue[a][i][dNbArroser]++;

								format(str, sizeof(str), "Champ de drogue n°%i.%i\n Maturite = %i%\nElle semble asséchée", i, a, Drogue[a][i][dMaturite]);
								Update3DTextLabelText(Drogue[a][i][dIdLabel], 0x008080FF, str);
								Drogue[a][i][arroser] = false;
								
							}
					        case 80:
					        {
					            SetDynamicObjectPos(Drogue[a][i][dId], pos[0], pos[1], pos[2]+0.1);
					            if(Drogue[a][i][arroser]) Drogue[a][i][dNbArroser]++;

								format(str, sizeof(str), "Champ de drogue n°%i.%i\n Maturite = %i%\nElle semble asséchée", i, a, Drogue[a][i][dMaturite]);
								Update3DTextLabelText(Drogue[a][i][dIdLabel], 0x008080FF, str);
								Drogue[a][i][arroser] = false;
								
							}
					        case 90:
					        {
					            SetDynamicObjectPos(Drogue[a][i][dId], pos[0], pos[1], pos[2]+0.1);
					            if(Drogue[a][i][arroser]) Drogue[a][i][dNbArroser]++;

								format(str, sizeof(str), "Champ de drogue n°%i.%i\n Maturite = %i%\nElle semble asséchée", i, a, Drogue[a][i][dMaturite]);
								Update3DTextLabelText(Drogue[a][i][dIdLabel], 0x008080FF, str);
								Drogue[a][i][arroser] = false;
								
							}
					    }
                        Drogue[a][i][dTime] = 0;
					}
					else if(Drogue[a][i][dMaturite] >= 100 && Drogue[a][i][dMaturite] < 150)
					{
					    new
					        str[128];
					    Drogue[a][i][dMaturite]++;
					    format(str, sizeof(str), "Champ de drogue n°%i.%i\n Maturite = %i%\nElle semble se dégrader", i, a, Drogue[a][i][dMaturite]);
					    Update3DTextLabelText(Drogue[a][i][dIdLabel], 0x008080FF, str);
					    Drogue[a][i][dTime] = 0;
					}
			    }
			}
		}
	}
	return 1;
}

stock GetDrogueDispo(playerid) //retourne l'index le plus proche de zéro ayant un champ de drogue vide (qui n'existe pas)
{

	for(new i = 0; i < MAX_PLANTS_PER_FACT;i++)
	{
		if(!Drogue[pFaction[playerid]][i][isactive]) return i;
	}
	return -1;
}

stock GetName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	return name;
}

stock GetCreatorDrogue(idchamp, idgang)
{
	return Drogue[idgang][idchamp][dCreateur];
}

stock GetNearestPlant(playerid)
{
	new
	    Float:stk = -1.0;

	for(new i = 0; i < MAX_PLANTS_PER_FACT; i++)
	{
 		if(Drogue[pFaction[playerid]][i][isactive])
 		{
 			new Float:dist = GetPlayerDistanceFromPoint(playerid, Drogue[pFaction[playerid]][i][dX], Drogue[pFaction[playerid]][i][dY], Drogue[pFaction[playerid]][i][dZ]);
 			if(stk == -1.0) stk = dist;
 			else if(stk > dist) stk = dist;
 			//printf("dist plant = %f", dist);
 		}
	}
	//printf("dist plant stk = %f", stk);
	return _:stk;
}

stock GetNearestPlantId(playerid)
{
    new
	    Float:stk = -1.0,
	    id;
	for(new i = 0; i < MAX_PLANTS_PER_FACT; i++)
	{
  		if(Drogue[pFaction[playerid]][i][isactive])
  		{
      		new Float:dist = GetPlayerDistanceFromPoint(playerid, Drogue[pFaction[playerid]][i][dX], Drogue[pFaction[playerid]][i][dY], Drogue[pFaction[playerid]][i][dZ]);
      		if(stk == -1.0)
			{
			 	stk = dist;
			 	id = i;
			}
    		else if(stk > dist)
			{
				stk = dist;
				id = i;
			}

		}
	}
	return id;
}

stock Random(min, max)
{
    new a = random(max - min) + min;
    return a;
}

stock GetFac(playerid)
{
	return pFaction[playerid];
}
