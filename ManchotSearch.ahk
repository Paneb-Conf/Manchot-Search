
/*
 *		MS Confrérie - Manchot Search
 *	Principe de l'outil : permettre de détecter rapidement si le mod consulté est présent ou non sur la Confrérie.
 *	Fonctionnement : 
 *		Il faut mettre en surbrillance l'URL de la page du mod. Une fois ceci fait, la combinaison de touche CTRL+B permet de lancer l'exécution du programme.
 *		Ce dernier se base sur le texte mis en surbrillance : si il ne s'agit pas d'une URL valide, un message apparaitra. Idem si le mod est classé adulte sur Nexus :
 *		L'accès à ce type de mod nécessitant une identification ce script dans sa version actuelle ne permet pas de les visualiser puisque je n'ai pas entré les codes.
 *		Une fois la page récupéré, une première recherche est effectuée au niveau du nom du mod sur la Confrérie. Si des résultats sont obtenus, il est alors proposé d'ouvrir la
 *		page de recherche du forum pour le mod en question.
 *		Si rien n'est remonté, une seconde recherche est proposée sur le nom du ou des auteurs.
 *		Comme pour le nom du mod, si un retour est trouvé il est possible d'ouvrir la page de recherche. 
 *		Si rien n'est trouvé, il est possible d'ouvrir le site de la Confrérie des Traducteurs directement dans la section Jeux pour ensuite créer le sujet ;).
 *	
 *	Installation : 
 *		Mettez le .exe n'importe où, double cliquer dessus ! Puis c'est tout. Il se lancera tout seul au prochain démarrage.
 *
 *		Pour fermer l'outil (le processus) : CTRL+WINDOWS+X
 *
 *
 *
 *
 * Mods de test du programme :
 *		http://www.nexusmods.com/skyrim/mods/17802/? : Climates Of Tamriel - Weather - Lighting - Audio - par jjc71
 *			La recherche avec le nom du mod ne remonte rien (d'ailleurs manuellement depuis le site également), mais l'auteur lui apparait !
 *		http://www.nexusmods.com/skyrim/mods/26800/? : XP32 Maximum Skeleton - XPM - par xp33
 *			Mod majeur ne remontant donc rien.	
 *		http://www.nexusmods.com/skyrim/mods/76203/? : Beasts of Tamriel - par SpikeDragonLord et jboyd4 
 *			Le mod remonte par son nom directement.
 *		http://www.nexusmods.com/skyrim/mods/76475/? : Immersive Load Screen Messages - Dawnguard and Dragonborn - par TentorIV
 *			Ni l'auteur ni son mod ne remonte
 *
 *
 *
 *		Idées futures : choisir la section à ouvrir selon le mod concerné, automatiquement importer les images pour créer le sujet, identification pour les mods "majeurs", etc...
 */ 

#NoEnv
SendMode Input 
SetWorkingDir %A_ScriptDir% 
#SingleInstance Force
Menu, Tray, NoStandard
Menu, Tray, Tip, ManchotSearch : CTRL+B sur l'URL !


StringTrimRight, Name, A_ScriptName, 3
IfNotExist, %A_Startup%\%Name%lnk
	{
 
		FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\%Name%lnk
	}
 
maRecherchePartieUne := "http://www.confrerie-des-traducteurs.fr/forum/search.php?keywords="
auteursRecup := []
nomDuMod := ""
^B::
	Try{
		obtenirNomDuMod()
		If(nomDuMod){
				maRecherche = %maRecherchePartieUne%%nomDuMod%
				resultatRecherche := rechercheConf(maRecherche)
				If(resultatRecherche){
					MsgBox, 36,Votre choix ?, % "Des résultats pour le mod " nomDuMod " semblent remonter sur Confrérie ! `nOuvrir la page de recherche ?"
					IfMsgBox Yes
						Run, %maRecherche%
				
				}
				Else {
					MsgBox, 36,Votre choix ?, % "Aucun résultat dans la recherche avec le nom du mod " nomDuMod " ! `n`nLancement de la recherche avec le nom de l'auteur ?"
					IfMsgBox Yes
					{
						obtenirNomDesAuteurs()
						Loop, % auteursRecup0
							If(auteursRecup%A_index%){
							;MsgBox % auteursRecup%A_index%
							auteur := auteursRecup%A_index%
							maRecherche = %maRecherchePartieUne%%auteur%
							resultatRecherche := rechercheConf(maRecherche)
							If(resultatRecherche){
								MsgBox, 36,Votre choix ?, % "L'auteur " auteur " est présent sur la Confrérie ! `nOuvrir la page de recherche ?"
								IfMsgBox Yes
									Run, %maRecherche%
							
								}
							Else {
								MsgBox, 36,Votre choix ?, % "L'auteur " auteur " n'est pas présent sur la Confrérie ! Ouvrir le forum ?"
								IfMsgBox Yes
									Run, http://www.confrerie-des-traducteurs.fr/forum/viewforum.php?f=75
								}	
							}
			
					}
				}	
			}
		Else
			MsgBox,48,Informations non récupérées, La page n'indique aucun nom de mod ! `n Êtes-vous sur le Nexus ? Si oui, le mod est-il pour les majeurs ? `n`nAucune recherche lancée...
		}
	catch e{

		MsgBox,16,Erreur du manchot, Une erreur est survenue ! Mauvaise syntaxe de l'URL ?
	}	
	Clipboard := ""
Return

^#x::
	ExitApp




/*
 *	FONCTIONS UTILISEES :
 *		- Clip () : Fonction du site AutoHotkey pour permettre une meilleure gestion du Clipboard
 *		- obtenirNomDuMod () : Fonction se basant sur l'URL mise en surbrillance (le texte de manière général) pour récupérer le nom du mod.
 *		- obtenirNomdDesAuteur () : Idem que nom du mod mais pour les auteurs. Peut récupérer un tableau d'auteur dans le cas où le mod est le produit d'un travail collaboratif.
 *		- rechercheConf (string) : Vérifie que le string passé en argument retourne ou non des résultats sur le forum de la Conférie des Traducteurs.
 *
 *
 *
*/
Clip(Text="", Reselect="") ; http://www.autohotkey.com/forum/viewtopic.php?p=467710 , modified February 19, 2013
{
	Static BackUpClip, Stored, LastClip
	If (A_ThisLabel = A_ThisFunc) {
		If (Clipboard == LastClip)
			Clipboard := BackUpClip
		BackUpClip := LastClip := Stored := ""
	} Else {
		If !Stored {
			Stored := True
			BackUpClip := ClipboardAll ; ClipboardAll must be on its own line
		} Else
			SetTimer, %A_ThisFunc%, Off
		LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
		If (Text = "") {
			SendInput, ^c
			ClipWait, LongCopy ? 0.6 : 0.2, True
		} Else {
			Clipboard := LastClip := Text
			ClipWait, 10
			SendInput, ^v
		}
		SetTimer, %A_ThisFunc%, -700
		Sleep 20 ; Short sleep in case Clip() is followed by more keystrokes such as {Enter}
		If (Text = "")
			Return LastClip := Clipboard
		Else If (ReSelect = True) or (Reselect and (StrLen(Text) < 3000)) {
			StringReplace, Text, Text, `r, , All
			SendInput, % "{Shift Down}{Left " StrLen(Text) "}{Shift Up}"
		}
	}
	Return
	Clip:
	Return Clip()
}

obtenirNomDuMod() {
	global
	nomDuMod := ""
	maRequete := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	URLMod := Clip()
	maRequete.Open("GET", URLMod, true)
	maRequete.Send()
	maRequete.WaitForResponse()
	maPage := maRequete.ResponseText
	
	monAiguille := "<span class=""header-name"">"
	maPageDecoupee := StrSplit(maPage, monAiguille)
	monAiguille := "</span> "
	positionDepart := RegExMatch(maPageDecoupee[2], monAiguille)
	nomDuMod := SubStr(maPageDecoupee[2],1,positionDepart-1) 
	return 
 }
 
obtenirNomDesAuteurs() {
	global
	If(auteursRecup0)
		Loop, % auteursRecup0
			 auteursRecup%A_index% := ""
	maRequete := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	URLMod := Clip()
	maRequete.Open("GET", URLMod, true)
	maRequete.Send()
	maRequete.WaitForResponse()
	maPage := maRequete.ResponseText
	monAiguille := """header-author"">by <strong>"
	maPageDecoupee := StrSplit(maPage, monAiguille)

	;MsgBox % "La partie avec le ou les auteurs est : " maPageDecoupee[2]

	monAiguille := "</strong>"
	positionDepart := RegExMatch(maPageDecoupee[2], monAiguille)
	auteurs := SubStr(maPageDecoupee[2],1,positionDepart-1) 
	notSolo := "and"
	TableauAuteur := []
	IfInString, auteurs, %notSolo% 
	{
		StringReplace, auteurs, auteurs, %notSolo%, ?, All
		StringSplit, auteursRecup, auteurs, ?, ` %A_Space%
		return
	}
	Else{
		StringSplit, auteursRecup, auteurs, ?
	
	return 
	 }
 }
 
rechercheConf(URL){
	maRequete := ComObjCreate("WinHttp.WinHttpRequest.5.1")

	maRequete.Open("GET", URL, true)
	maRequete.Send()
	maRequete.WaitForResponse()
	maPage := maRequete.ResponseText
	monAiguille := "Aucun sujet"
	trouve := RegExMatch(maPage, monAiguille)
	if(trouve <> 0)
		return 0
	else
		return 1


}



