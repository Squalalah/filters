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
#define FIRE_TIME_SEC 15 //Temps en seconde pendant lequel une plante prend feu puis disparait
#define PERCENT_OVER 110 //Nombre de pourcent de maturité minimum pour qu'une plante se dégrade et ne rapporte aucune graine et juste 1/2 feuilles
#define MIN_FEUILLE_OVER 1 //Minimum de feuille obtenu si la maturité dépasse PERCENT_OVER
#define MAX_FEUILLE_OVER 2 //Maximum de feuille obtenu si la maturité dépasse PERCENT_OVER
#define MIN_FEUILLE_PERFECT 1 //Minimum de feuille obtenu si la maturité est entre 100 et 110%
#define MIN_GRAINE_PERFECT 1 //Maximum de graine obtenu si la maturité est entre 100 et 110%
#define POLICE_FAC_ID 4
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
	dFire,
	dFireTime
}

//~~~~~~~~~~~~~ /VARS ~~~~~~~~~~~~~~~~~


new
	Drogue[MAX_GANGS][MAX_PLANTS_PER_FACT][drugInfos];
	
new
	pFaction[MAX_PLAYERS],
	Graines[MAX_PLAYERS],
	Feuilles[MAX_PLAYERS],
	bool:isMakingMeth[MAX_PLAYERS];
	
new PlayerText:Textdraw0[MAX_PLAYERS];
new PlayerText:Textdraw1[MAX_PLAYERS];
new PlayerText:Textdraw2[MAX_PLAYERS];
new PlayerText:Textdraw3[MAX_PLAYERS];
new PlayerText:Textdraw4[MAX_PLAYERS];
new PlayerText:Textdraw5[MAX_PLAYERS];
new PlayerText:Textdraw6[MAX_PLAYERS];
new PlayerText:Textdraw7[MAX_PLAYERS];
new PlayerText:Textdraw8[MAX_PLAYERS];
new PlayerText:Textdraw9[MAX_PLAYERS];
new PlayerText:Textdraw10[MAX_PLAYERS];
new PlayerText:Textdraw11[MAX_PLAYERS];
new PlayerText:Textdraw12[MAX_PLAYERS];
new PlayerText:Textdraw13[MAX_PLAYERS];
new PlayerText:Textdraw14[MAX_PLAYERS];
new PlayerText:Textdraw15[MAX_PLAYERS];
new PlayerText:Textdraw16[MAX_PLAYERS];
new PlayerText:Textdraw17[MAX_PLAYERS];
new PlayerText:Textdraw18[MAX_PLAYERS];
new PlayerText:Textdraw19[MAX_PLAYERS];
new PlayerText:Textdraw20[MAX_PLAYERS];
new PlayerText:Textdraw21[MAX_PLAYERS];
new PlayerText:Textdraw22[MAX_PLAYERS];
new PlayerText:Textdraw23[MAX_PLAYERS];
new PlayerText:Textdraw24[MAX_PLAYERS];
new PlayerText:Textdraw25[MAX_PLAYERS];
new PlayerText:Textdraw26[MAX_PLAYERS];
new PlayerText:Textdraw27[MAX_PLAYERS];



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
		Drogue[idgang][champid][dFire] = -1;
		Drogue[idgang][champid][dFireTime] = -1;
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
	    isMakingMeth[playerid] = false;
	
	    return 1;
	}
	if(strcmp("/police", cmdtext, true, 7) == 0)
	{
		pFaction[playerid] = POLICE_FAC_ID;
		SCM(playerid, -1, "Vous êtes devenu policier !");
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
			_:distance = GetNearestPlantGang(playerid);
	    //printf("distance /ramasser = %f", distance);
	    if(floatcmp(_:distance, _:DIST) == 1 || floatcmp(_:distance, _:0.0) == -1) return SendClientMessage(playerid, -1, "Aucune plante à proximité ou n'appartenant pas à votre faction !");
		new
		    id = GetNearestPlantIdGang(playerid),
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
			_:distance = GetNearestPlantGang(playerid),
			str[128],
			idgang = GetFac(playerid);
			
	    //printf("distance /ramasser = %f", distance);
	    if(floatcmp(_:distance, _:DIST) == 1  || floatcmp(_:distance, _:0.0) == -1) return SendClientMessage(playerid, -1, "Aucune plante à proximité ou n'appartennant pas à votre faction !");
	    new
		    id = GetNearestPlantIdGang(playerid);
		if(Drogue[idgang][id][dMaturite] >= 100) return SCM(playerid, -1, "Cela ne sert à rien d'arroser une plante étant déjà arrivée à maturité !");
		if(Drogue[idgang][id][arroser]) return SCM(playerid, -1, "La plante semble avoir suffisemment d'eau pour l'instant");
		
		format(str, sizeof(str), "Champ de drogue n°%i.%i \n Maturite = %i % \n Elle semble fraîche", id, idgang, Drogue[idgang][id][dMaturite]);
		Update3DTextLabelText(Drogue[idgang][id][dIdLabel], 0x008080FF, str);
		
		Drogue[idgang][id][arroser] = true;
		SCM(playerid, -1, "La plante a bien été arrosée !");
		//printf("Plante arrosé dans Drogue[%i], id %i et arroser = %b", idgang, id, Drogue[idgang][id][arroser]);
		return 1;
	}
	
	if(strcmp("/bruler", cmdtext, true, 7) == 0)
	{
	    if(pFaction[playerid] == -1) return SCM(playerid, -1, "Vous n'êtes ni un THUG, ni un policier");
        new
			_:distance = GetNearestPlant(playerid),
			idplant = GetNearestPlantId(playerid),
			vw = GetPlayerVirtualWorld(playerid),
			interior = GetPlayerInterior(playerid);

	    if(floatcmp(_:distance, _:DIST) == 1  || floatcmp(_:distance, _:0.0) == -1) return SendClientMessage(playerid, -1, "Aucune plante à proximité !");
	    new
		    id = GetNearestPlantIdChamp(playerid);
		if(pFaction[playerid] == id) return SCM(playerid, -1, "Vous ne pouvez pas brûler les champs de votre faction !");
		
        Drogue[id][idplant][arroser] = false;
        Delete3DTextLabel(Drogue[id][idplant][dIdLabel]);

		Drogue[id][idplant][dNbArroser] = 0;
		Drogue[id][idplant][dMaturite] = 0;
		Drogue[id][idplant][dFire] = CreateDynamicObject(18688, Drogue[id][idplant][dX], Drogue[id][idplant][dY], Drogue[id][idplant][dZ], 0.0, 0.0, 0.0, vw, interior);
		Drogue[id][idplant][dFireTime] = FIRE_TIME_SEC;
		Drogue[id][idplant][dX] = 0.0;
        Drogue[id][idplant][dY] = 0.0;
        Drogue[id][idplant][dZ] = 0.0;
		SCM(playerid, -1, "Le champ a été entièrement brûlé !");
		//printf("Valeur dFire = %i , Valeur dFireTime = %i", Drogue[id][idplant][dFire], Drogue[id][idplant][dFireTime]);
	    
	    return 1;
	}
	
	if(strcmp("/init", cmdtext, true, 5) == 0)
	{
	    Textdraw0[playerid] = CreatePlayerTextDraw(playerid, 515.000000, 110.596298, "usebox");
		PlayerTextDrawLetterSize(playerid, Textdraw0[playerid], 0.000000, 32.868511);
		PlayerTextDrawTextSize(playerid, Textdraw0[playerid], 119.000000, 0.000000);
		PlayerTextDrawAlignment(playerid, Textdraw0[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw0[playerid], 0);
		PlayerTextDrawUseBox(playerid, Textdraw0[playerid], true);
		PlayerTextDrawBoxColor(playerid, Textdraw0[playerid], 102);
		PlayerTextDrawSetShadow(playerid, Textdraw0[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw0[playerid], 0);
		PlayerTextDrawFont(playerid, Textdraw0[playerid], 0);

		Textdraw1[playerid] = CreatePlayerTextDraw(playerid, 140.000000, 132.325927, "LD_SPAC:white");
		PlayerTextDrawLetterSize(playerid, Textdraw1[playerid], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, Textdraw1[playerid], 88.666694, 23.229627);
		PlayerTextDrawAlignment(playerid, Textdraw1[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw1[playerid], 255);
		PlayerTextDrawSetShadow(playerid, Textdraw1[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw1[playerid], 0);
		PlayerTextDrawFont(playerid, Textdraw1[playerid], 4);
		PlayerTextDrawSetSelectable(playerid, Textdraw1[playerid], true);

		Textdraw2[playerid] = CreatePlayerTextDraw(playerid, 140.666656, 135.229644, "Mettre HCL");
		PlayerTextDrawLetterSize(playerid, Textdraw2[playerid], 0.449999, 1.600000);
		PlayerTextDrawAlignment(playerid, Textdraw2[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw2[playerid], -1);
		PlayerTextDrawSetShadow(playerid, Textdraw2[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw2[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, Textdraw2[playerid], 51);
		PlayerTextDrawFont(playerid, Textdraw2[playerid], 1);
		PlayerTextDrawSetProportional(playerid, Textdraw2[playerid], 1);

		Textdraw3[playerid] = CreatePlayerTextDraw(playerid, 140.333343, 164.266662, "LD_SPAC:white");
		PlayerTextDrawLetterSize(playerid, Textdraw3[playerid], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, Textdraw3[playerid], 88.000000, 22.814819);
		PlayerTextDrawAlignment(playerid, Textdraw3[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw3[playerid], 255);
		PlayerTextDrawSetShadow(playerid, Textdraw3[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw3[playerid], 0);
		PlayerTextDrawFont(playerid, Textdraw3[playerid], 4);
		PlayerTextDrawSetSelectable(playerid, Textdraw3[playerid], true);

		Textdraw4[playerid] = CreatePlayerTextDraw(playerid, 141.333358, 167.170364, "Mettre MU");
		PlayerTextDrawLetterSize(playerid, Textdraw4[playerid], 0.449999, 1.600000);
		PlayerTextDrawAlignment(playerid, Textdraw4[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw4[playerid], -1);
		PlayerTextDrawSetShadow(playerid, Textdraw4[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw4[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, Textdraw4[playerid], 51);
		PlayerTextDrawFont(playerid, Textdraw4[playerid], 1);
		PlayerTextDrawSetProportional(playerid, Textdraw4[playerid], 1);

		Textdraw5[playerid] = CreatePlayerTextDraw(playerid, 164.666641, 241.837020, "0 degrer");
		PlayerTextDrawLetterSize(playerid, Textdraw5[playerid], 0.449999, 1.600000);
		PlayerTextDrawAlignment(playerid, Textdraw5[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw5[playerid], -1);
		PlayerTextDrawSetShadow(playerid, Textdraw5[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw5[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, Textdraw5[playerid], 51);
		PlayerTextDrawFont(playerid, Textdraw5[playerid], 1);
		PlayerTextDrawSetProportional(playerid, Textdraw5[playerid], 1);

		Textdraw6[playerid] = CreatePlayerTextDraw(playerid, 144.666580, 218.192581, "Thermometre");
		PlayerTextDrawLetterSize(playerid, Textdraw6[playerid], 0.449999, 1.600000);
		PlayerTextDrawAlignment(playerid, Textdraw6[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw6[playerid], -1);
		PlayerTextDrawSetShadow(playerid, Textdraw6[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw6[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, Textdraw6[playerid], 51);
		PlayerTextDrawFont(playerid, Textdraw6[playerid], 1);
		PlayerTextDrawSetProportional(playerid, Textdraw6[playerid], 1);

		Textdraw7[playerid] = CreatePlayerTextDraw(playerid, 138.000000, 262.162963, "LD_SPAC:white");
		PlayerTextDrawLetterSize(playerid, Textdraw7[playerid], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, Textdraw7[playerid], 54.666656, 18.666656);
		PlayerTextDrawAlignment(playerid, Textdraw7[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw7[playerid], 255);
		PlayerTextDrawSetShadow(playerid, Textdraw7[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw7[playerid], 0);
		PlayerTextDrawFont(playerid, Textdraw7[playerid], 4);
		PlayerTextDrawSetSelectable(playerid, Textdraw7[playerid], true);

		Textdraw8[playerid] = CreatePlayerTextDraw(playerid, 138.666671, 263.822174, "Monter Temp.");
		PlayerTextDrawLetterSize(playerid, Textdraw8[playerid], 0.225000, 1.517037);
		PlayerTextDrawAlignment(playerid, Textdraw8[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw8[playerid], -1);
		PlayerTextDrawSetShadow(playerid, Textdraw8[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw8[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, Textdraw8[playerid], 51);
		PlayerTextDrawFont(playerid, Textdraw8[playerid], 1);
		PlayerTextDrawSetProportional(playerid, Textdraw8[playerid], 1);

		Textdraw9[playerid] = CreatePlayerTextDraw(playerid, 200.666671, 261.748168, "LD_SPAC:white");
		PlayerTextDrawLetterSize(playerid, Textdraw9[playerid], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, Textdraw9[playerid], 52.666671, 19.081451);
		PlayerTextDrawAlignment(playerid, Textdraw9[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw9[playerid], 255);
		PlayerTextDrawSetShadow(playerid, Textdraw9[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw9[playerid], 0);
		PlayerTextDrawFont(playerid, Textdraw9[playerid], 4);
		PlayerTextDrawSetSelectable(playerid, Textdraw9[playerid], true);

		Textdraw10[playerid] = CreatePlayerTextDraw(playerid, 202.333419, 262.992614, "Baisser Temp.");
		PlayerTextDrawLetterSize(playerid, Textdraw10[playerid], 0.208333, 1.537777);
		PlayerTextDrawAlignment(playerid, Textdraw10[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw10[playerid], -1);
		PlayerTextDrawSetShadow(playerid, Textdraw10[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw10[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, Textdraw10[playerid], 51);
		PlayerTextDrawFont(playerid, Textdraw10[playerid], 1);
		PlayerTextDrawSetProportional(playerid, Textdraw10[playerid], 1);

		Textdraw11[playerid] = CreatePlayerTextDraw(playerid, 161.000000, 297.422149, "Niveau : 0");
		PlayerTextDrawLetterSize(playerid, Textdraw11[playerid], 0.250666, 1.566815);
		PlayerTextDrawAlignment(playerid, Textdraw11[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw11[playerid], -1);
		PlayerTextDrawSetShadow(playerid, Textdraw11[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw11[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, Textdraw11[playerid], 51);
		PlayerTextDrawFont(playerid, Textdraw11[playerid], 1);
		PlayerTextDrawSetProportional(playerid, Textdraw11[playerid], 1);

		Textdraw12[playerid] = CreatePlayerTextDraw(playerid, 394.333343, 127.762962, "LD_SPAC:white");
		PlayerTextDrawLetterSize(playerid, Textdraw12[playerid], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, Textdraw12[playerid], 77.000000, 23.229621);
		PlayerTextDrawAlignment(playerid, Textdraw12[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw12[playerid], 255);
		PlayerTextDrawSetShadow(playerid, Textdraw12[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw12[playerid], 0);
		PlayerTextDrawBackgroundColor(playerid, Textdraw12[playerid], 255);
		PlayerTextDrawFont(playerid, Textdraw12[playerid], 4);
		PlayerTextDrawSetSelectable(playerid, Textdraw12[playerid], true);

		Textdraw13[playerid] = CreatePlayerTextDraw(playerid, 398.666687, 130.666656, "1/3 EAU");
		PlayerTextDrawLetterSize(playerid, Textdraw13[playerid], 0.449999, 1.600000);
		PlayerTextDrawAlignment(playerid, Textdraw13[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw13[playerid], -1);
		PlayerTextDrawSetShadow(playerid, Textdraw13[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw13[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, Textdraw13[playerid], 51);
		PlayerTextDrawFont(playerid, Textdraw13[playerid], 1);
		PlayerTextDrawSetProportional(playerid, Textdraw13[playerid], 1);

		Textdraw14[playerid] = CreatePlayerTextDraw(playerid, 394.666687, 155.970367, "LD_SPAC:white");
		PlayerTextDrawLetterSize(playerid, Textdraw14[playerid], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, Textdraw14[playerid], 76.666656, 18.251861);
		PlayerTextDrawAlignment(playerid, Textdraw14[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw14[playerid], 255);
		PlayerTextDrawSetShadow(playerid, Textdraw14[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw14[playerid], 0);
		PlayerTextDrawFont(playerid, Textdraw14[playerid], 4);
		PlayerTextDrawSetSelectable(playerid, Textdraw14[playerid], true);

		Textdraw15[playerid] = CreatePlayerTextDraw(playerid, 398.999938, 156.799972, "1/2 EAU");
		PlayerTextDrawLetterSize(playerid, Textdraw15[playerid], 0.449999, 1.600000);
		PlayerTextDrawAlignment(playerid, Textdraw15[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw15[playerid], -1);
		PlayerTextDrawSetShadow(playerid, Textdraw15[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw15[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, Textdraw15[playerid], 51);
		PlayerTextDrawFont(playerid, Textdraw15[playerid], 1);
		PlayerTextDrawSetProportional(playerid, Textdraw15[playerid], 1);

		Textdraw16[playerid] = CreatePlayerTextDraw(playerid, 394.666687, 180.029632, "LD_SPAC:white");
		PlayerTextDrawLetterSize(playerid, Textdraw16[playerid], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, Textdraw16[playerid], 76.333312, 16.177764);
		PlayerTextDrawAlignment(playerid, Textdraw16[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw16[playerid], 255);
		PlayerTextDrawSetShadow(playerid, Textdraw16[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw16[playerid], 0);
		PlayerTextDrawFont(playerid, Textdraw16[playerid], 4);
		PlayerTextDrawSetSelectable(playerid, Textdraw16[playerid], true);

		Textdraw17[playerid] = CreatePlayerTextDraw(playerid, 399.333404, 179.199996, "1/1 EAU");
		PlayerTextDrawLetterSize(playerid, Textdraw17[playerid], 0.449999, 1.600000);
		PlayerTextDrawAlignment(playerid, Textdraw17[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw17[playerid], -1);
		PlayerTextDrawSetShadow(playerid, Textdraw17[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw17[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, Textdraw17[playerid], 51);
		PlayerTextDrawFont(playerid, Textdraw17[playerid], 1);
		PlayerTextDrawSetProportional(playerid, Textdraw17[playerid], 1);

		Textdraw18[playerid] = CreatePlayerTextDraw(playerid, 410.333312, 228.977783, "LD_SPAC:white");
		PlayerTextDrawLetterSize(playerid, Textdraw18[playerid], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, Textdraw18[playerid], 45.000000, 144.355560);
		PlayerTextDrawAlignment(playerid, Textdraw18[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw18[playerid], -1);
		PlayerTextDrawSetShadow(playerid, Textdraw18[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw18[playerid], 0);
		PlayerTextDrawFont(playerid, Textdraw18[playerid], 4);

		Textdraw19[playerid] = CreatePlayerTextDraw(playerid, 413.666656, 206.577758, "Fiole");
		PlayerTextDrawLetterSize(playerid, Textdraw19[playerid], 0.449999, 1.600000);
		PlayerTextDrawAlignment(playerid, Textdraw19[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw19[playerid], -1);
		PlayerTextDrawSetShadow(playerid, Textdraw19[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw19[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, Textdraw19[playerid], 51);
		PlayerTextDrawFont(playerid, Textdraw19[playerid], 1);
		PlayerTextDrawSetProportional(playerid, Textdraw19[playerid], 1);

		Textdraw20[playerid] = CreatePlayerTextDraw(playerid, 387.666656, 376.237060, "LD_SPAC:white");
		PlayerTextDrawLetterSize(playerid, Textdraw20[playerid], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, Textdraw20[playerid], 89.333343, 25.718505);
		PlayerTextDrawAlignment(playerid, Textdraw20[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw20[playerid], 255);
		PlayerTextDrawSetShadow(playerid, Textdraw20[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw20[playerid], 0);
		PlayerTextDrawFont(playerid, Textdraw20[playerid], 4);
		PlayerTextDrawSetSelectable(playerid, Textdraw20[playerid], true);

		Textdraw21[playerid] = CreatePlayerTextDraw(playerid, 388.999908, 380.385223, "Ajouter a la recette");
		PlayerTextDrawLetterSize(playerid, Textdraw21[playerid], 0.248666, 1.666370);
		PlayerTextDrawAlignment(playerid, Textdraw21[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw21[playerid], -1);
		PlayerTextDrawSetShadow(playerid, Textdraw21[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw21[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, Textdraw21[playerid], 51);
		PlayerTextDrawFont(playerid, Textdraw21[playerid], 1);
		PlayerTextDrawSetProportional(playerid, Textdraw21[playerid], 1);

		Textdraw22[playerid] = CreatePlayerTextDraw(playerid, 387.333343, 148.918518, "LD_SPAC:white");
		PlayerTextDrawLetterSize(playerid, Textdraw22[playerid], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, Textdraw22[playerid], -67.666656, -17.837036);
		PlayerTextDrawAlignment(playerid, Textdraw22[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw22[playerid], 255);
		PlayerTextDrawSetShadow(playerid, Textdraw22[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw22[playerid], 0);
		PlayerTextDrawFont(playerid, Textdraw22[playerid], 4);
		PlayerTextDrawSetSelectable(playerid, Textdraw22[playerid], true);

		Textdraw23[playerid] = CreatePlayerTextDraw(playerid, 320.333343, 131.911056, "5 cui. CS");
		PlayerTextDrawLetterSize(playerid, Textdraw23[playerid], 0.434999, 1.645629);
		PlayerTextDrawAlignment(playerid, Textdraw23[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw23[playerid], -1);
		PlayerTextDrawSetShadow(playerid, Textdraw23[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw23[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, Textdraw23[playerid], 51);
		PlayerTextDrawFont(playerid, Textdraw23[playerid], 1);
		PlayerTextDrawSetProportional(playerid, Textdraw23[playerid], 1);

		Textdraw24[playerid] = CreatePlayerTextDraw(playerid, 319.666687, 154.311111, "LD_SPAC:white");
		PlayerTextDrawLetterSize(playerid, Textdraw24[playerid], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, Textdraw24[playerid], 67.999969, 18.251846);
		PlayerTextDrawAlignment(playerid, Textdraw24[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw24[playerid], 255);
		PlayerTextDrawSetShadow(playerid, Textdraw24[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw24[playerid], 0);
		PlayerTextDrawFont(playerid, Textdraw24[playerid], 4);
		PlayerTextDrawSetSelectable(playerid, Textdraw24[playerid], true);

		Textdraw25[playerid] = CreatePlayerTextDraw(playerid, 320.666595, 155.970397, "10 cui. CS");
		PlayerTextDrawLetterSize(playerid, Textdraw25[playerid], 0.380333, 1.624888);
		PlayerTextDrawAlignment(playerid, Textdraw25[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw25[playerid], -1);
		PlayerTextDrawSetShadow(playerid, Textdraw25[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw25[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, Textdraw25[playerid], 51);
		PlayerTextDrawFont(playerid, Textdraw25[playerid], 1);
		PlayerTextDrawSetProportional(playerid, Textdraw25[playerid], 1);

		Textdraw26[playerid] = CreatePlayerTextDraw(playerid, 409.999969, 228.148101, "LD_SPAC:white"); //FIOLE MOITIER
		PlayerTextDrawLetterSize(playerid, Textdraw26[playerid], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, Textdraw26[playerid], 45.333374, 73.007469);
		PlayerTextDrawAlignment(playerid, Textdraw26[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw26[playerid], 255);
		PlayerTextDrawSetShadow(playerid, Textdraw26[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw26[playerid], 0);
		PlayerTextDrawFont(playerid, Textdraw26[playerid], 4);

		Textdraw27[playerid] = CreatePlayerTextDraw(playerid, 455.333557, 300.325927, "LD_SPAC:white"); //FIOLE MOITIER
		PlayerTextDrawLetterSize(playerid, Textdraw27[playerid], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, Textdraw27[playerid], -45.333366, 72.592613);
		PlayerTextDrawAlignment(playerid, Textdraw27[playerid], 1);
		PlayerTextDrawColor(playerid, Textdraw27[playerid], -1378294017);
		PlayerTextDrawSetShadow(playerid, Textdraw27[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Textdraw27[playerid], 0);
		PlayerTextDrawFont(playerid, Textdraw27[playerid], 4);
		
		SCM(playerid, -1, "Textdraws initialisés !");
	    return 1;
	}
	
	if(strcmp("/meth", cmdtext, true, 5) == 0)
	{
		if(pFaction[playerid] == -1) return SCM(playerid, -1, "Vous n'avez pas de faction !");
	    if(isMakingMeth[playerid])
	    {
	        CancelSelectTextDraw(playerid);
		   	PlayerTextDrawHide(playerid, Textdraw0[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw1[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw2[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw3[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw4[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw5[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw6[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw7[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw8[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw9[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw10[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw11[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw12[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw13[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw14[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw15[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw16[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw17[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw18[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw19[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw20[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw21[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw22[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw23[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw24[playerid]);
		    PlayerTextDrawHide(playerid, Textdraw25[playerid]);
	    
	    }
	    else
		{
		    SelectTextDraw(playerid, 0x00FF00FF);
		   	PlayerTextDrawShow(playerid, Textdraw0[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw1[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw2[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw3[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw4[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw5[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw6[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw7[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw8[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw9[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw10[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw11[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw12[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw13[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw14[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw15[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw16[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw17[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw18[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw19[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw20[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw21[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw22[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw23[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw24[playerid]);
		    PlayerTextDrawShow(playerid, Textdraw25[playerid]);
		
		}
	    return 1;
	}
	return 0;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if(playertextid == Textdraw1[playerid])
    {
  		PlayerTextDrawSetSelectable(playerid, Textdraw1[playerid], 0);
		PlayerTextDrawColor(playerid, Textdraw1[playerid], 0xD11313FF);
		PlayerTextDrawHide(playerid, Textdraw1[playerid]);
		PlayerTextDrawShow(playerid, Textdraw1[playerid]);
    }
    else if(playertextid == Textdraw3[playerid])
    {
  		PlayerTextDrawSetSelectable(playerid, Textdraw3[playerid], 0);
		PlayerTextDrawColor(playerid, Textdraw3[playerid], 0xD11313FF);
		PlayerTextDrawHide(playerid, Textdraw3[playerid]);
		PlayerTextDrawShow(playerid, Textdraw3[playerid]);
    }
    return 1;
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
			    if(Drogue[a][i][isactive] && Drogue[a][i][dFire] == -1)
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
						    format(str, sizeof(str), "Champ de drogue n°%i.%i \n Maturite = %i % \n Elle semble asséchée", i, a, Drogue[a][i][dMaturite]);
							Update3DTextLabelText(Drogue[a][i][dIdLabel], 0x008080FF, str);
						}

						switch(Drogue[a][i][dMaturite])
					    {
					        case 10,20,30,40,50,60,70,80,90:
					        {
					            SetDynamicObjectPos(Drogue[a][i][dId], pos[0], pos[1], pos[2]+0.1);
							}
					    }
					    if(Drogue[a][i][arroser]) Drogue[a][i][dNbArroser]++;
						format(str, sizeof(str), "Champ de drogue n°%i.%i \n Maturite = %i % \nElle semble asséchée", i, a, Drogue[a][i][dMaturite]);
						Update3DTextLabelText(Drogue[a][i][dIdLabel], 0x008080FF, str);
						Drogue[a][i][arroser] = false;
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
			    else if(Drogue[a][i][isactive] && Drogue[a][i][dFire] != -1)
			    {
                    //printf("Valeur dFire = %i , Valeur dFireTime = %i", Drogue[a][i][dFire], Drogue[a][i][dFireTime]);
			        if(Drogue[a][i][dFireTime] > 0)
			        {
			            Drogue[a][i][dFireTime]--;
			        }
			        else if (Drogue[a][i][dFireTime] == 0)
			        {
			            Drogue[a][i][isactive] = false;
						DestroyDynamicObject(Drogue[a][i][dId]);
						DestroyDynamicObject(Drogue[a][i][dFire]);
						Drogue[a][i][dTime] = 0;
						Drogue[a][i][dFireTime] = -1;
						Drogue[a][i][dFire] = -1;
						Drogue[a][i][dId] = -1;
			        }
			        Drogue[a][i][dTime] = 0;
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

stock GetNearestPlantGang(playerid)
{
	new
	    Float:stk = -1.0;

	for(new i = 0; i < MAX_PLANTS_PER_FACT; i++)
	{
 		if(Drogue[pFaction[playerid]][i][isactive] && Drogue[pFaction[playerid]][i][dFire] == -1)
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

stock GetNearestPlantIdGang(playerid)
{
    new
	    Float:stk = -1.0,
	    id;
	for(new i = 0; i < MAX_PLANTS_PER_FACT; i++)
	{
  		if(Drogue[pFaction[playerid]][i][isactive] && Drogue[pFaction[playerid]][i][dFire] == -1)
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

stock GetNearestPlant(playerid)
{
	new
	    Float:stk = -1.0;

	for(new a = 0; a < MAX_GANGS; a++)
	{
		for(new i = 0; i < MAX_PLANTS_PER_FACT; i++)
		{
	 		if(Drogue[a][i][isactive] && Drogue[a][i][dFire] == -1)
	 		{
	 			new Float:dist = GetPlayerDistanceFromPoint(playerid, Drogue[a][i][dX], Drogue[a][i][dY], Drogue[a][i][dZ]);
	 			if(stk == -1.0) stk = dist;
	 			else if(stk > dist) stk = dist;
	 			//printf("dist plant = %f", dist);
	 		}
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
	for(new a = 0; a < MAX_GANGS; a++)
	{
		for(new i = 0; i < MAX_PLANTS_PER_FACT; i++)
		{
	  		if(Drogue[a][i][isactive] && Drogue[a][i][dFire] == -1)
	  		{
	      		new Float:dist = GetPlayerDistanceFromPoint(playerid, Drogue[a][i][dX], Drogue[a][i][dY], Drogue[a][i][dZ]);
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
	}
	return id;
}

stock GetNearestPlantIdChamp(playerid)
{
    new
	    Float:stk = -1.0,
	    id;
	for(new a = 0; a < MAX_GANGS; a++)
	{
		for(new i = 0; i < MAX_PLANTS_PER_FACT; i++)
		{
	  		if(Drogue[a][i][isactive] && Drogue[a][i][dFire] == -1)
	  		{
	      		new Float:dist = GetPlayerDistanceFromPoint(playerid, Drogue[a][i][dX], Drogue[a][i][dY], Drogue[a][i][dZ]);
	      		if(stk == -1.0)
				{
				 	stk = dist;
				 	id = a;
				}
	    		else if(stk > dist)
				{
					stk = dist;
					id = a;
				}

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
