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


#define VERSION "0.2"

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
#define MAX_TEMP 101 //Définit le niveau de température maximum pour la meth, (temperature max = MAX_TEMP*10, 6*10 = 60°max supporté avant explosion)

#define MAX_GANGS 2 //Définit cb de factions peuvent créer/ramasser de la drogue
#define MAX_LABO 2
#define ID_FACTION_GANG_1 1 //Définit quel est l'ID de la premiere faction illégale pouvant PLANTER la drogue
#define ID_FACTION_GANG_2 2 //Définit quel est l'ID de la deuxième faction illégale pouvant PLANTER la drogue
#define DIALOG_DRUGLAB 600
#define DIALOG_INT_REGULER 601

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

enum labInfos
{
	lID, //ID du labo
	bool:isactive, //Si le labo est utilisé ou non
	bool:isCooking, //Si la solution est sur le feu (cuisine)
	lFaction, //l'id de la faction auquel le labo est lié
	lTime, //Temps d'attente entre les étapes de recette
	lStep, //Etape à laquelle le joueur est rendu pour la recette
	lTemp, //Température
	lNiveauReguler, // Niveau de température regulé par le joueur (0 à MAX_TEMP)
	lCptTemp, //compteur comptant cb de temps est resté la solution sous la même température
	hcl,
	mu,
	cs,
	eau,
	acide,
	nbMeth,
	nbLsd,
}

//~~~~~~~~~~~~~ /VARS ~~~~~~~~~~~~~~~~~


new
	Drogue[MAX_GANGS][MAX_PLANTS_PER_FACT][drugInfos],
	Labo[MAX_LABO][labInfos];
	
new
	pFaction[MAX_PLAYERS],
	Graines[MAX_PLAYERS],
	Feuilles[MAX_PLAYERS],
	bool:isMakingMeth[MAX_PLAYERS],
	pHcl[MAX_PLAYERS],
	pMu[MAX_PLAYERS],
	pCs[MAX_PLAYERS],
	pEau[MAX_PLAYERS],
	pAcide[MAX_PLAYERS],
	bool:pLoaded[MAX_PLAYERS];
	
new
	PlayerText:Textdraw0[MAX_PLAYERS], //Interface
	PlayerText:Textdraw1[MAX_PLAYERS], //Bouton Mettre HCL
	PlayerText:Textdraw2[MAX_PLAYERS], // TEXTE HCL
	PlayerText:Textdraw3[MAX_PLAYERS], //Bouton Mettre MU
	PlayerText:Textdraw4[MAX_PLAYERS], // TEXTE MU
	PlayerText:Textdraw5[MAX_PLAYERS], // TEXTE 0 DEGRER
	PlayerText:Textdraw6[MAX_PLAYERS], // TEXTE THERMOMETRE
	PlayerText:Textdraw7[MAX_PLAYERS], // BOUTON MONTER TEMP
	PlayerText:Textdraw8[MAX_PLAYERS], // TEXTE MONTER TEMP
	PlayerText:Textdraw9[MAX_PLAYERS], // BOUTON BAISSER TEMP
	PlayerText:Textdraw10[MAX_PLAYERS], // TEXTE BAISSER TEMP
	PlayerText:Textdraw11[MAX_PLAYERS], // TEXTE NIVEAU TEMP
	PlayerText:Textdraw12[MAX_PLAYERS], // BOUTON 1/3 EAU
	PlayerText:Textdraw13[MAX_PLAYERS], // TEXTE 1/3 EAU
	PlayerText:Textdraw14[MAX_PLAYERS], // BOUTON 1/2 EAU
	PlayerText:Textdraw15[MAX_PLAYERS], // TEXTE 1/2 EAU
	PlayerText:Textdraw16[MAX_PLAYERS], // BOUTON 1/1 EAU
	PlayerText:Textdraw17[MAX_PLAYERS], // TEXTE 1/1 EAU
	PlayerText:Textdraw18[MAX_PLAYERS], // Interface FIOLE
	PlayerText:Textdraw19[MAX_PLAYERS], // TEXTE FIOLE
	PlayerText:Textdraw20[MAX_PLAYERS], // BOUTON AJOUTER A LA RECETTE
	PlayerText:Textdraw21[MAX_PLAYERS], // TEXTE AJOUTER A LA RECETTE
	PlayerText:Textdraw22[MAX_PLAYERS], // BOUTON 5 CUI CS
	PlayerText:Textdraw23[MAX_PLAYERS], // TEXTE 5 CUI CS
	PlayerText:Textdraw24[MAX_PLAYERS], // BOUTON 10 CUI CS
	PlayerText:Textdraw25[MAX_PLAYERS], // TEXTE 10 CUI CS
	PlayerText:Textdraw26[MAX_PLAYERS], // TXT MOITIER FIOLE HAUT REMPLIT
	PlayerText:Textdraw27[MAX_PLAYERS], // TXT MOITIER FIOLE BAS REMPLIT
	PlayerText:Textdraw28[MAX_PLAYERS], // BOUTON VIDER SOLUTION
	PlayerText:Textdraw29[MAX_PLAYERS], // TEXTE VIDER SOLUTION
	PlayerText:Textdraw30[MAX_PLAYERS],
	PlayerText:Textdraw31[MAX_PLAYERS],
	PlayerText:Textdraw32[MAX_PLAYERS];


//~~~~~~~~~~~~~ /FORWARDS ~~~~~~~~~~~~~~~~~


forward Timer1s();
forward Timer3s();



//~~~~~~~~~~~ /CALLBACKS ~~~~~~~~~~~~~~




public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Système de drogue by Squalalah !");
	printf("VERSION -> %s", VERSION);
	print("--------------------------------------\n");
	
	for(new i = 0; i < MAX_PLANTS_PER_FACT;i++)
	{
		for(new a = 0; a < MAX_GANGS; a++)
		{
	    	Drogue[a][i][isactive] = false;
		}
	}
	
	for(new i = 0; i < MAX_LABO;i++)
	{
	    Labo[i][isactive] = false;
	    Labo[i][lFaction] = i;
	    Labo[i][lTime] = -1;
	    Labo[i][lStep] = -1;
	    Labo[i][lTemp] = 0;
	    Labo[i][lNiveauReguler] = 0;
		Labo[i][lCptTemp] = -1;
		Labo[i][hcl] = 0;
		Labo[i][mu] = 0;
		Labo[i][cs] = 0;
		Labo[i][eau] = 0;
		Labo[i][acide] = 0;
		Labo[i][isCooking] = false;
		Labo[i][nbMeth] = 0;
		Labo[i][nbLsd] = 0;
	    printf(" Labo id %i - isactive %b - lFaction %i - lTime %i - lStep %i - lTemp %i - lNiveauReguler %i -", i, Labo[i][isactive], Labo[i][lFaction], Labo[i][lTime], Labo[i][lStep], Labo[i][lTemp], Labo[i][lNiveauReguler]);
	}
	
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		pFaction[i] = -1;
		pLoaded[i] = false;
		pHcl[i] = pMu[i] = pCs[i] = pEau[i] = pAcide[i] = 0;
	}

	
	SetTimer("Timer1s", 1000, true);
	SetTimer("Timer3s", 3000, true);
	
	SendClientMessageToAll(-1, "Ce message prouvant l'homosexualité de Leïto annonce que le filterscript a bien été chargé !");
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
		Drogue[idgang][id][dNbArroser]++;
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

	if(strcmp("/meth", cmdtext, true, 5) == 0)
	{
	    if(!pLoaded[playerid]) LoadDrugLabTxd(playerid);
		if(pFaction[playerid] == -1) return SCM(playerid, -1, "Vous n'avez pas de faction !");
		ShowMethDialog(playerid);
	    return 1;
	}
	if(strcmp("/ingredient", cmdtext, true, 11) == 0)
	{
		pHcl[playerid]++;
		pMu[playerid]++;
		pCs[playerid]++;
		pEau[playerid]++;
		pAcide[playerid]++;
		SCM(playerid, -1, "Les ingrédients ont été ajoutés à votre inventaire !");
	    return 1;
	}
	return 0;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	printf("textdraw appelé : %i", _:playertextid);
    if(playertextid == Textdraw1[playerid]) //Bouton Mettre HCL
    {
        if(Labo[pFaction[playerid]][hcl] == 0) return SCM(playerid, -1, "Il n'y a pas de Chlorure d'Hydrogène dans le labo !");
        if(Labo[pFaction[playerid]][lStep] == -1)
        {
            SCM(playerid, -1, "Vous avez placé le HCL, maintenant inserez le MU");
            Labo[pFaction[playerid]][lStep] = 1;
            Labo[pFaction[playerid]][hcl]--;
            PlayerTextDrawSetSelectable(playerid, Textdraw1[playerid], 0);
			PlayerTextDrawColor(playerid, Textdraw1[playerid], 0xD11313FF);
			PlayerTextDrawHide(playerid, Textdraw1[playerid]);
			PlayerTextDrawShow(playerid, Textdraw1[playerid]);
        }
  		
    }
    else if(playertextid == Textdraw3[playerid]) //Bouton Mettre MU
    {
        if(Labo[pFaction[playerid]][mu] == 0) return SCM(playerid, -1, "Il n'y a pas d'acide chlorydrique dans le labo !");
        if(Labo[pFaction[playerid]][lStep] == 1)
        {
            SCM(playerid, -1, "Vous avez placé le HCL, maintenant régler le régulateur de la plaque chauffante à 45 degrées");
            Labo[pFaction[playerid]][lStep] = 2;
            Labo[pFaction[playerid]][mu]--;
            PlayerTextDrawSetSelectable(playerid, Textdraw3[playerid], 0);
			PlayerTextDrawColor(playerid, Textdraw3[playerid], 0xD11313FF);
			PlayerTextDrawHide(playerid, Textdraw3[playerid]);
			PlayerTextDrawShow(playerid, Textdraw3[playerid]);
		}
	}
    else if(playertextid == Textdraw7[playerid]) //REGULER
    {
        ShowPlayerDialog(playerid,DIALOG_INT_REGULER, DIALOG_STYLE_INPUT, "Reguler la température", "Entrez la température à atteindre (0 à 101 degrées) :", "Réguler", "Annuler");
    }
    else if(playertextid == Textdraw9[playerid]) //Mettre sur le feu
    {
        Labo[pFaction[playerid]][isCooking] = true;
        PlayerTextDrawSetSelectable(playerid, Textdraw9[playerid], 0);
        PlayerTextDrawSetSelectable(playerid, Textdraw28[playerid], 1);
        PlayerTextDrawColor(playerid, Textdraw9[playerid], 0xD11313FF);
        PlayerTextDrawColor(playerid, Textdraw28[playerid], 255);
        
        PlayerTextDrawHide(playerid, Textdraw9[playerid]);
		PlayerTextDrawShow(playerid, Textdraw9[playerid]);
		
        UpdatePlayerTextDraw(playerid, Textdraw9[playerid]);
        UpdatePlayerTextDraw(playerid, Textdraw28[playerid]);
        
        if(Labo[pFaction[playerid]][lStep] == 3)
        {
			SCM(playerid, -1, "Très bien ! Maintenant, patientez quelques instant pour que la solution cuise");
			Labo[pFaction[playerid]][lStep] = 4;
        }
        else if(Labo[pFaction[playerid]][lStep] == 10)
        {
       		SCM(playerid, -1, "Très bien ! Maintenant, patientez quelques instant pour que la solution cuise");
			Labo[pFaction[playerid]][lStep] = 11;
        }
        return 1;
    }
    else if(playertextid == Textdraw12[playerid]) // BOUTON 1/3 EAU
    {
        if(Labo[pFaction[playerid]][eau] == 0) return SCM(playerid, -1, "Il n'y a pas de bouteille d'eau dans le labo !");
        Labo[pFaction[playerid]][eau]--;
    	PlayerTextDrawSetSelectable(playerid, Textdraw12[playerid], 0);
		PlayerTextDrawColor(playerid, Textdraw12[playerid], 0xD11313FF);
		PlayerTextDrawHide(playerid, Textdraw12[playerid]);
		PlayerTextDrawShow(playerid, Textdraw12[playerid]);
		return 1;
    
    }
    else if(playertextid == Textdraw14[playerid]) // BOUTON 1/2 EAU
    {
        if(Labo[pFaction[playerid]][eau] == 0) return SCM(playerid, -1, "Il n'y a pas de bouteille d'eau dans le labo !");
        Labo[pFaction[playerid]][eau]--;
    	PlayerTextDrawSetSelectable(playerid, Textdraw14[playerid], 0);
		PlayerTextDrawColor(playerid, Textdraw14[playerid], 0xD11313FF);
		PlayerTextDrawHide(playerid, Textdraw14[playerid]);
		PlayerTextDrawShow(playerid, Textdraw14[playerid]);
		if(Labo[pFaction[playerid]][lStep] == 6)
		{
		    Labo[pFaction[playerid]][lStep] = 7;
		    SCM(playerid, -1, "Bien ! Ajoutez y 10 cuillières d'acide tout en mélangeant");
		}
		return 1;
    }
    else if(playertextid == Textdraw16[playerid]) // BOUTON 1/1 EAU
    {
        if(Labo[pFaction[playerid]][eau] == 0) return SCM(playerid, -1, "Il n'y a pas de bouteille d'eau dans le labo !");
        Labo[pFaction[playerid]][eau]--;
    	PlayerTextDrawSetSelectable(playerid, Textdraw16[playerid], 0);
		PlayerTextDrawColor(playerid, Textdraw16[playerid], 0xD11313FF);
		PlayerTextDrawHide(playerid, Textdraw16[playerid]);
		PlayerTextDrawShow(playerid, Textdraw16[playerid]);
		return 1;
    }
    else if(playertextid == Textdraw20[playerid])
    {
        if(Labo[pFaction[playerid]][lStep] == 8)
        {
            SCM(playerid, -1, "Bien ! Maintenant que c'est melangé, réglez le régulateur sur 85 degré");
			Labo[pFaction[playerid]][lStep] = 9;
        }
    }
    else if(playertextid == Textdraw22[playerid]) // BOUTON 10 CUI CS
    {
        if(Labo[pFaction[playerid]][acide] == 0) return SCM(playerid, -1, "Il n'y a pas de bouteille d'acide dans le labo !");
        Labo[pFaction[playerid]][acide]--;
    	PlayerTextDrawSetSelectable(playerid, Textdraw22[playerid], 0);
		PlayerTextDrawColor(playerid, Textdraw22[playerid], 0xD11313FF);
		PlayerTextDrawHide(playerid, Textdraw22[playerid]);
		PlayerTextDrawShow(playerid, Textdraw22[playerid]);
		if(Labo[pFaction[playerid]][lStep] == 7)
		{
		    SCM(playerid, -1, "Parfait ! Il ne vous reste plus qu'à verser l'éprouvette dans la solution !");
		    Labo[pFaction[playerid]][lStep] = 8;
		}
		return 1;
    }
    else if(playertextid == Textdraw26[playerid])
    {
        if(Labo[pFaction[playerid]][lStep] != -1) return SCM(playerid, -1, "Vous ne pouvez recommencer si vous n'avez pas commencé !");
        Labo[pFaction[playerid]][lStep] = -1;
        Labo[pFaction[playerid]][lTime] = -1;
        SCM(playerid, -1, "Vous avez jeté votre solution, vous pouvez désormais tout recommencer");
        return 1;
    }
    else if (playertextid == Textdraw28[playerid]) //Retirer du feu
    {
    	Labo[pFaction[playerid]][isCooking] = false;
        PlayerTextDrawSetSelectable(playerid, Textdraw28[playerid], 0);
        PlayerTextDrawSetSelectable(playerid, Textdraw9[playerid], 1);
        PlayerTextDrawColor(playerid, Textdraw28[playerid], 0xD11313FF);
        PlayerTextDrawColor(playerid, Textdraw9[playerid], 255);
        
        UpdatePlayerTextDraw(playerid, Textdraw9[playerid]);
        UpdatePlayerTextDraw(playerid, Textdraw28[playerid]);
        
		if(Labo[pFaction[playerid]][lStep] == 5)
		{
		    SCM(playerid, -1, "Bien, maintenant qu'elle est prête, ajoutez 1/2 litre d'eau dans l'éprouvette");
		    Labo[pFaction[playerid]][lStep] = 6;
		    
		}
		else if(Labo[pFaction[playerid]][lStep] == 12)
		{
		    SCM(playerid, -1, "Parfait ! La solution a été conçu avec succès !");
 	    	SCM(playerid, -1, "Le labo a récupéré 3 grammes de methamphétamine");
 	    	Labo[pFaction[playerid]][nbMeth] += 3;
		}
        return 1;
    }
    return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
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
	switch(dialogid)
	{
		case DIALOG_DRUGLAB:
	    {
			if(response)
			{
				switch(listitem)
	    		{
     			   	case 0:
					{
						if(!isMakingMeth[playerid])
     			       	{
							SelectTextDraw(playerid, 0x00FF00FF);
							ShowDrugLabTextdraw(playerid);
							new
								str[50];
							format(str, sizeof(str), "%i Degrers", Labo[pFaction[playerid]][lTemp]);
							PlayerTextDrawSetString(playerid, Textdraw5[playerid], str);
							UpdatePlayerTextDraw(playerid, Textdraw5[playerid]);

							format(str, sizeof(str), "Niveau : %i", Labo[pFaction[playerid]][lNiveauReguler]);
							PlayerTextDrawSetString(playerid, Textdraw11[playerid], str);
							
							if(Labo[pFaction[playerid]][isCooking])
							{
							    PlayerTextDrawSetSelectable(playerid, Textdraw9[playerid], 0);
						        PlayerTextDrawSetSelectable(playerid, Textdraw28[playerid], 1);
						        PlayerTextDrawColor(playerid, Textdraw9[playerid], 0xD11313FF);
						        PlayerTextDrawColor(playerid, Textdraw28[playerid], 255);
							}
							else
							{
							    PlayerTextDrawSetSelectable(playerid, Textdraw28[playerid], 0);
						        PlayerTextDrawSetSelectable(playerid, Textdraw9[playerid], 1);
						        PlayerTextDrawColor(playerid, Textdraw28[playerid], 0xD11313FF);
						        PlayerTextDrawColor(playerid, Textdraw9[playerid], 255);
							}
							UpdatePlayerTextDraw(playerid, Textdraw9[playerid]);
							UpdatePlayerTextDraw(playerid, Textdraw28[playerid]);
							UpdatePlayerTextDraw(playerid, Textdraw11[playerid]);

							if(Labo[pFaction[playerid]][lStep] == -1) SCM(playerid, -1, "Placez le HCL");
							isMakingMeth[playerid] = true;
							Labo[pFaction[playerid]][isactive] = true;
						}
						else
						{
							CancelSelectTextDraw(playerid);
							HideDrugLabTextdraw(playerid);
							isMakingMeth[playerid] = false;
							Labo[pFaction[playerid]][isactive] = false;
						}
						return 1;
					}
					case 1: //HCL
					{
					    if(pHcl[playerid] <= 0) return SCM(playerid, -1, "Vous n'avez pas de chlorure d'hydrogène !");
					    pHcl[playerid]--;
					    Labo[pFaction[playerid]][hcl]++;
					    ShowMethDialog(playerid);
					    return 1;
					}
					case 2: //MU
					{
					    if(pMu[playerid] <= 0) return SCM(playerid, -1, "Vous n'avez pas d'acide chlorydrique !");
					    pMu[playerid]--;
					    Labo[pFaction[playerid]][mu]++;
					    ShowMethDialog(playerid);
					    return 1;
					}
					case 3: //CS
					{
					    if(pCs[playerid] <= 0) return SCM(playerid, -1, "Vous n'avez pas de soude caustique");
					    pCs[playerid]--;
					    Labo[pFaction[playerid]][cs]++;
						ShowMethDialog(playerid);
						return 1;
					}
					case 4: //EAU
					{
					    if(pEau[playerid] <= 0) return SCM(playerid, -1, "Vous n'avez pas d'eau !");
					    pEau[playerid]--;
					    Labo[pFaction[playerid]][eau]++;
					    ShowMethDialog(playerid);
					    return 1;
					}
					case 5: //ACIDE
					{
					    if(pAcide[playerid] <= 0) return SCM(playerid, -1, "Vous n'avez pas d'acide !");
					    pAcide[playerid]--;
					    Labo[pFaction[playerid]][acide]++;
					    ShowMethDialog(playerid);
					    return 1;
					}

    			}
			}
			return 1;
	    }
	    case DIALOG_INT_REGULER:
	    {
	        if(response)
	        {
				if(strlen(inputtext) > 3) return SCM(playerid, -1, "Merci d'entrer une température entre 0 et 101 degrées");
				if(!IsNumeric(inputtext)) return SCM(playerid, -1, "Merci d'entrer un nombre entier entre 0 et 101 degrées");
				new
				    result = strval(inputtext),
					str[128];
				result = Labo[pFaction[playerid]][lNiveauReguler] = result;

				format(str, sizeof(str), "Le régulateur a bien été configuré sur %i degrées !", Labo[pFaction[playerid]][lNiveauReguler]);
	            SCM(playerid, -1, str);
	            
	            format(str, sizeof(str), "Regulateur : %i degrers", Labo[pFaction[playerid]][lNiveauReguler]);
	            PlayerTextDrawSetString(playerid, Textdraw11[playerid], str);
	            
	            return 1;
	        }
	    
	    }
	}
	return 0;
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
					            format(str, sizeof(str), "Champ de drogue n°%i.%i \n Maturite = %i % \n Elle semble asséchée", i, a, Drogue[a][i][dMaturite]);
								Update3DTextLabelText(Drogue[a][i][dIdLabel], 0x008080FF, str);
								Drogue[a][i][arroser] = false;
							}
					    }
						/*format(str, sizeof(str), "Champ de drogue n°%i.%i \n Maturite = %i % \nElle semble asséchée", i, a, Drogue[a][i][dMaturite]);
						Update3DTextLabelText(Drogue[a][i][dIdLabel], 0x008080FF, str);*/
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
			        if(Drogue[a][i][dFireTime] > 0) Drogue[a][i][dFireTime]--;
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

public Timer3s()
{
	for(new i = 0; i < MAX_LABO; i++)
	{
		printf("lTemp = %i, LNiveau = %i", Labo[i][lTemp], Labo[i][lNiveauReguler]);
		printf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
	    if(Labo[i][lStep] != 1) //Si une préparation est en cours
	    {
         	if(Labo[i][lNiveauReguler] > Labo[i][lTemp])
	        {
				Labo[i][lTemp]++;
	        }
	        else if(Labo[i][lNiveauReguler] < Labo[i][lTemp])
	        {
	            Labo[i][lTemp]--;
	        }
			if(Labo[i][isactive])
			{
			    for(new a = 0, j = GetPlayerPoolSize(); a <= j; a++)
			    {
			        if(isMakingMeth[a] && pFaction[a] == i)
			        {
			        	new
	            			str[50];
						format(str, sizeof(str), "%i Degrers", Labo[i][lTemp]);
			            PlayerTextDrawSetString(a, Textdraw5[a], str);
	        			UpdatePlayerTextDraw(a, Textdraw5[a]);
			        }
				}
			}
			if(Labo[i][lStep] == 2)
			{
				if(Labo[i][lTemp] == 45 && Labo[i][lNiveauReguler] == 45)
				{
				    for(new a = 0, j = GetPlayerPoolSize(); a <= j; a++)
			    	{
				        if(isMakingMeth[a] && pFaction[a] == i)
				        {
							SCM(i, -1, "Maintenant que la température est reglée, placez la solution sur le feu");
							Labo[i][lStep] = 3;
						}
					}
				}
			}
			else if(Labo[i][lStep] == 4)
			{
			    if(Labo[i][lTemp] == 45 && Labo[i][lNiveauReguler] == 45)
			    {
			        Labo[i][lCptTemp]++;
			        if(Labo[i][lCptTemp] == 5)
					{
					    for(new a = 0, j = GetPlayerPoolSize(); a <= j; a++)
			    		{
				        	if(isMakingMeth[a] && pFaction[a] == i)
				        	{
							    Labo[i][lStep] = 5;
							    SCM(a, -1, "Bien ! La solution semble prête, retirez la du feu");
							    Labo[i][lCptTemp] = 0;
							}
						}
					}
			    }
			}
			else if(Labo[i][lStep] == 9)
			{
			    if(Labo[i][lTemp] == 85 && Labo[i][lNiveauReguler] == 85)
				{
				    for(new a = 0, j = GetPlayerPoolSize(); a <= j; a++)
		    		{
			        	if(isMakingMeth[a] && pFaction[a] == i)
			        	{
			        	    SCM(i, -1, "Maintenant que la température est reglée, placez la solution sur le feu");
			        	    Labo[i][lStep] = 10;
						}
					}
				}
			}
			else if(Labo[i][lStep] == 11)
			{
			    if(Labo[i][lTemp] == 85 && Labo[i][lNiveauReguler] == 85)
			    {
			        Labo[i][lCptTemp]++;
			        if(Labo[i][lCptTemp] == 5)
					{
					    for(new a = 0, j = GetPlayerPoolSize(); a <= j; a++)
			    		{
				        	if(isMakingMeth[a] && pFaction[a] == i)
				        	{
							    Labo[i][lStep] = 12;
							    SCM(a, -1, "Bien ! La solution semble prête, retirez la du feu");
							    Labo[i][lCptTemp] = 0;
							}
						}
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

stock UpdatePlayerTextDraw(playerid, PlayerText:txd)
{
    PlayerTextDrawHide(playerid, txd);
    PlayerTextDrawShow(playerid, txd);
	return 1;
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

stock LoadDrugLabTxd(playerid)
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

	Textdraw1[playerid] = CreatePlayerTextDraw(playerid, 162.333297, 131.911148, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, Textdraw1[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Textdraw1[playerid], 88.666694, 23.229627);
	PlayerTextDrawAlignment(playerid, Textdraw1[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw1[playerid], 255);
	PlayerTextDrawSetShadow(playerid, Textdraw1[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw1[playerid], 0);
	PlayerTextDrawFont(playerid, Textdraw1[playerid], 4);
	PlayerTextDrawSetSelectable(playerid, Textdraw1[playerid], true);

	Textdraw2[playerid] = CreatePlayerTextDraw(playerid, 163.999954, 136.059280, "Mettre HCL");
	PlayerTextDrawLetterSize(playerid, Textdraw2[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Textdraw2[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw2[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Textdraw2[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw2[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw2[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw2[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw2[playerid], 1);

	Textdraw3[playerid] = CreatePlayerTextDraw(playerid, 163.000030, 161.777725, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, Textdraw3[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Textdraw3[playerid], 88.000000, 22.814819);
	PlayerTextDrawAlignment(playerid, Textdraw3[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw3[playerid], 255);
	PlayerTextDrawSetShadow(playerid, Textdraw3[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw3[playerid], 0);
	PlayerTextDrawFont(playerid, Textdraw3[playerid], 4);
	PlayerTextDrawSetSelectable(playerid, Textdraw3[playerid], true);

	Textdraw4[playerid] = CreatePlayerTextDraw(playerid, 166.666671, 166.340698, "Mettre MU");
	PlayerTextDrawLetterSize(playerid, Textdraw4[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Textdraw4[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw4[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Textdraw4[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw4[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw4[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw4[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw4[playerid], 1);

	Textdraw5[playerid] = CreatePlayerTextDraw(playerid, 168.666656, 258.014801, "0 degrer");
	PlayerTextDrawLetterSize(playerid, Textdraw5[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Textdraw5[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw5[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Textdraw5[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw5[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw5[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw5[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw5[playerid], 1);

	Textdraw6[playerid] = CreatePlayerTextDraw(playerid, 152.999893, 231.051834, "Thermometre");
	PlayerTextDrawLetterSize(playerid, Textdraw6[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Textdraw6[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw6[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Textdraw6[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw6[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw6[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw6[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw6[playerid], 1);

	Textdraw7[playerid] = CreatePlayerTextDraw(playerid, 173.999969, 293.274108, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, Textdraw7[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Textdraw7[playerid], 51.666671, 17.007385);
	PlayerTextDrawAlignment(playerid, Textdraw7[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw7[playerid], 255);
	PlayerTextDrawSetShadow(playerid, Textdraw7[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw7[playerid], 0);
	PlayerTextDrawFont(playerid, Textdraw7[playerid], 4);
	PlayerTextDrawSetSelectable(playerid, Textdraw7[playerid], true);

	Textdraw8[playerid] = CreatePlayerTextDraw(playerid, 176.666641, 293.688781, "Reguler");
	PlayerTextDrawLetterSize(playerid, Textdraw8[playerid], 0.383333, 1.554370);
	PlayerTextDrawAlignment(playerid, Textdraw8[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw8[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Textdraw8[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw8[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw8[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw8[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw8[playerid], 1);

	Textdraw9[playerid] = CreatePlayerTextDraw(playerid, 128.333328, 202.429626, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, Textdraw9[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Textdraw9[playerid], 70.000000, 17.837051);
	PlayerTextDrawAlignment(playerid, Textdraw9[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw9[playerid], 255);
	PlayerTextDrawSetShadow(playerid, Textdraw9[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw9[playerid], 0);
	PlayerTextDrawFont(playerid, Textdraw9[playerid], 4);
	PlayerTextDrawSetSelectable(playerid, Textdraw9[playerid], true);

	Textdraw10[playerid] = CreatePlayerTextDraw(playerid, 129.333374, 203.674087, "Mettre au feu");
	PlayerTextDrawLetterSize(playerid, Textdraw10[playerid], 0.280333, 1.666370);
	PlayerTextDrawAlignment(playerid, Textdraw10[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw10[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Textdraw10[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw10[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw10[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw10[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw10[playerid], 1);

	Textdraw11[playerid] = CreatePlayerTextDraw(playerid, 153.666687, 316.088989, "Regulateur : 0 degrer");
	PlayerTextDrawLetterSize(playerid, Textdraw11[playerid], 0.250665, 1.566815);
	PlayerTextDrawAlignment(playerid, Textdraw11[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw11[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Textdraw11[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw11[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw11[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw11[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw11[playerid], 1);

	Textdraw12[playerid] = CreatePlayerTextDraw(playerid, 395.333343, 129.422210, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, Textdraw12[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Textdraw12[playerid], 75.666664, 20.325922);
	PlayerTextDrawAlignment(playerid, Textdraw12[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw12[playerid], 255);
	PlayerTextDrawSetShadow(playerid, Textdraw12[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw12[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, Textdraw12[playerid], 255);
	PlayerTextDrawFont(playerid, Textdraw12[playerid], 4);
	PlayerTextDrawSetSelectable(playerid, Textdraw12[playerid], true);

	Textdraw13[playerid] = CreatePlayerTextDraw(playerid, 402.000030, 131.081466, "1/3 EAU");
	PlayerTextDrawLetterSize(playerid, Textdraw13[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Textdraw13[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw13[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Textdraw13[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw13[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw13[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw13[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw13[playerid], 1);

	Textdraw14[playerid] = CreatePlayerTextDraw(playerid, 394.666656, 155.140731, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, Textdraw14[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Textdraw14[playerid], 76.666656, 18.251861);
	PlayerTextDrawAlignment(playerid, Textdraw14[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw14[playerid], 255);
	PlayerTextDrawSetShadow(playerid, Textdraw14[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw14[playerid], 0);
	PlayerTextDrawFont(playerid, Textdraw14[playerid], 4);
	PlayerTextDrawSetSelectable(playerid, Textdraw14[playerid], true);

	Textdraw15[playerid] = CreatePlayerTextDraw(playerid, 401.333251, 156.385162, "1/2 EAU");
	PlayerTextDrawLetterSize(playerid, Textdraw15[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Textdraw15[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw15[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Textdraw15[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw15[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw15[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw15[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw15[playerid], 1);

	Textdraw16[playerid] = CreatePlayerTextDraw(playerid, 394.333343, 178.370376, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, Textdraw16[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Textdraw16[playerid], 76.333312, 16.177764);
	PlayerTextDrawAlignment(playerid, Textdraw16[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw16[playerid], 255);
	PlayerTextDrawSetShadow(playerid, Textdraw16[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw16[playerid], 0);
	PlayerTextDrawFont(playerid, Textdraw16[playerid], 4);
	PlayerTextDrawSetSelectable(playerid, Textdraw16[playerid], true);

	Textdraw17[playerid] = CreatePlayerTextDraw(playerid, 402.000122, 178.370376, "1/1 EAU");
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

	Textdraw22[playerid] = CreatePlayerTextDraw(playerid, 320.000030, 177.540740, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, Textdraw22[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Textdraw22[playerid], 67.999969, 18.251846);
	PlayerTextDrawAlignment(playerid, Textdraw22[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw22[playerid], 255);
	PlayerTextDrawSetShadow(playerid, Textdraw22[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw22[playerid], 0);
	PlayerTextDrawFont(playerid, Textdraw22[playerid], 4);
	PlayerTextDrawSetSelectable(playerid, Textdraw22[playerid], true);

	Textdraw23[playerid] = CreatePlayerTextDraw(playerid, 321.333251, 179.200042, "10 cui. CS");
	PlayerTextDrawLetterSize(playerid, Textdraw23[playerid], 0.380333, 1.624886);
	PlayerTextDrawAlignment(playerid, Textdraw23[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw23[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Textdraw23[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw23[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw23[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw23[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw23[playerid], 1);

	Textdraw24[playerid] = CreatePlayerTextDraw(playerid, 409.999969, 228.148101, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, Textdraw24[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Textdraw24[playerid], 45.333374, 73.007469);
	PlayerTextDrawAlignment(playerid, Textdraw24[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw24[playerid], 255);
	PlayerTextDrawSetShadow(playerid, Textdraw24[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw24[playerid], 0);
	PlayerTextDrawFont(playerid, Textdraw24[playerid], 4);

	Textdraw25[playerid] = CreatePlayerTextDraw(playerid, 455.333557, 300.325927, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, Textdraw25[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Textdraw25[playerid], -45.333366, 72.592613);
	PlayerTextDrawAlignment(playerid, Textdraw25[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw25[playerid], -1378294017);
	PlayerTextDrawSetShadow(playerid, Textdraw25[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw25[playerid], 0);
	PlayerTextDrawFont(playerid, Textdraw25[playerid], 4);

	Textdraw26[playerid] = CreatePlayerTextDraw(playerid, 159.333267, 360.474121, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, Textdraw26[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Textdraw26[playerid], 77.000000, 19.081481);
	PlayerTextDrawAlignment(playerid, Textdraw26[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw26[playerid], 255);
	PlayerTextDrawSetShadow(playerid, Textdraw26[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw26[playerid], 0);
	PlayerTextDrawFont(playerid, Textdraw26[playerid], 4);
	PlayerTextDrawSetSelectable(playerid, Textdraw26[playerid], true);

	Textdraw27[playerid] = CreatePlayerTextDraw(playerid, 178.333404, 361.303771, "Jeter");
	PlayerTextDrawLetterSize(playerid, Textdraw27[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Textdraw27[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw27[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Textdraw27[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw27[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw27[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw27[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw27[playerid], 1);

	Textdraw28[playerid] = CreatePlayerTextDraw(playerid, 210.666671, 202.844436, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, Textdraw28[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Textdraw28[playerid], 66.666671, 16.592605);
	PlayerTextDrawAlignment(playerid, Textdraw28[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw28[playerid], 255);
	PlayerTextDrawSetShadow(playerid, Textdraw28[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw28[playerid], 0);
	PlayerTextDrawFont(playerid, Textdraw28[playerid], 4);
	PlayerTextDrawSetSelectable(playerid, Textdraw28[playerid], true);

	Textdraw29[playerid] = CreatePlayerTextDraw(playerid, 211.999969, 203.259231, "Enlever du feu");
	PlayerTextDrawLetterSize(playerid, Textdraw29[playerid], 0.257666, 1.645629);
	PlayerTextDrawAlignment(playerid, Textdraw29[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw29[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Textdraw29[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw29[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw29[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw29[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw29[playerid], 1);

	Textdraw30[playerid] = CreatePlayerTextDraw(playerid, 259.000000, 114.074073, "Labo de Drogue");
	PlayerTextDrawLetterSize(playerid, Textdraw30[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Textdraw30[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw30[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Textdraw30[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw30[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw30[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw30[playerid], 3);
	PlayerTextDrawSetProportional(playerid, Textdraw30[playerid], 1);

	Textdraw31[playerid] = CreatePlayerTextDraw(playerid, 320.666656, 173.807403, "LD_SPAC:white");
	PlayerTextDrawLetterSize(playerid, Textdraw31[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Textdraw31[playerid], 66.999969, -16.177780);
	PlayerTextDrawAlignment(playerid, Textdraw31[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw31[playerid], 255);
	PlayerTextDrawSetShadow(playerid, Textdraw31[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw31[playerid], 0);
	PlayerTextDrawFont(playerid, Textdraw31[playerid], 4);
	PlayerTextDrawSetSelectable(playerid, Textdraw31[playerid], true);

	Textdraw32[playerid] = CreatePlayerTextDraw(playerid, 322.000000, 158.459228, "5 cui. CS");
	PlayerTextDrawLetterSize(playerid, Textdraw32[playerid], 0.424666, 1.616592);
	PlayerTextDrawAlignment(playerid, Textdraw32[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw32[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Textdraw32[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw32[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw32[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw32[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw32[playerid], 1);
	
	pLoaded[playerid] = true;
	return 1;
}

stock ShowMethDialog(playerid)
{
	new
	    string[300],
	    idlab = pFaction[playerid];
    if(!isMakingMeth[playerid])
	{
		format(string, sizeof(string), "Cuisiner\nAjouter HCL (restant: %i)\nAjouter MU (restant: %i)\nAjouter CS (restant: %i)\nAjouter Eau (restant : %i)\nAjouter Acide (restant : %i)\nTotal meth : %i grammes", Labo[idlab][hcl], Labo[idlab][mu], Labo[idlab][cs], Labo[idlab][eau], Labo[idlab][acide], Labo[idlab][nbMeth]);
	}
	else
	{
		format(string, sizeof(string), "Arrêter\nAjouter HCL (restant: %i)\nAjouter MU (restant: %i)\nAjouter CS (restant: %i)\nAjouter Eau (restant : %i)\nAjouter Acide (restant : %i)\nTotal meth : %i grammes", Labo[idlab][hcl], Labo[idlab][mu], Labo[idlab][cs], Labo[idlab][eau], Labo[idlab][acide], Labo[idlab][nbMeth]);
	}
	ShowPlayerDialog(playerid, DIALOG_DRUGLAB, DIALOG_STYLE_LIST, "Labo", string, "Valider", "Annuler");
	return 1;
}

stock HideDrugLabTextdraw(playerid)
{
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
    PlayerTextDrawHide(playerid, Textdraw26[playerid]);
    PlayerTextDrawHide(playerid, Textdraw27[playerid]);
    PlayerTextDrawHide(playerid, Textdraw28[playerid]);
    PlayerTextDrawHide(playerid, Textdraw29[playerid]);
    PlayerTextDrawHide(playerid, Textdraw30[playerid]);
    PlayerTextDrawHide(playerid, Textdraw31[playerid]);
    PlayerTextDrawHide(playerid, Textdraw32[playerid]);
	return 1;
}

stock ShowDrugLabTextdraw(playerid)
{
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
    PlayerTextDrawShow(playerid, Textdraw26[playerid]);
    PlayerTextDrawShow(playerid, Textdraw27[playerid]);
    PlayerTextDrawShow(playerid, Textdraw28[playerid]);
    PlayerTextDrawShow(playerid, Textdraw29[playerid]);
    PlayerTextDrawShow(playerid, Textdraw30[playerid]);
    PlayerTextDrawShow(playerid, Textdraw31[playerid]);
    PlayerTextDrawShow(playerid, Textdraw32[playerid]);
	return 1;
}

IsNumeric(const string[])
{
        for (new i = 0, j = strlen(string); i < j; i++)
        {
                if (string[i] > '9' || string[i] < '0') return 0;
        }
        return 1;
}
