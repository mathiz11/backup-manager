#!/bin/bash

# fonction qui permet de récupérer les chemins des fichiers et dossier vide
browsefolder()
{
oujesuis="$1"
for fichier in "$oujesuis"/*
do
  if [ -d "$fichier" ]
  then
    browsefolder "$fichier"
  else
    echo "$fichier"
  fi
done
}
# Acceuil lors du lancement du script
echo " "
echo "      --------------------------------------"
echo "      ------------   BIENVENUE  ------------"
echo "      --------------------------------------"
echo " "

lieusauv="$HOME"/Projet/Sauvegarde
lieusauv1="$lieusauv"/V.1

#copier la première version si elle n'existe pas dans le dossier sauvegarde
if [ ! -d "$lieusauv1" ]
then
  echo "Veuillez saisir votre aborescence : "
  read arbo
  mkdir -p "$lieusauv1"/sauv
  #enregistrement du chemin
  echo "Chemin de l'arborescence
"$arbo"" > "$HOME"/Projet/info
  cp -r "$arbo"/* "$lieusauv1"/sauv
  echo " "
fi

lieusauv="$HOME"/Projet/Sauvegarde
lieusauv1="$lieusauv"/V.1
lieupro="$HOME"/Projet
#nombre de versions
nbrv=`ls "$lieusauv" | wc -l`
choix='z'
arbo=`sed -n '2p' "$lieupro"/info`
#nombre de caractères du chemin de l'arborescence
nbrcarbo=`echo "$arbo" | wc -c`
#nombre de caractères du chemin de la sauvegarde
nbrcsauv=`echo "$lieusauv"/V.$(($nbrv-1))/sauv | wc -c`

#partie non aboutie donc on a préféré la laisser en commentaire
#searchfile()
# {  cheminfichier="$1"
#  nbrv=`ls "$lieusauv" | wc -l`
#  empfic=`md5sum "$lieusauv"/V.$(($nbrv-1))/sauv"$cheminfichier" | cut -c 33-`
#  nbrlarbo=`cat "$lieusauv"/V.$nbrv/fic/cheminfic.arbo | wc -l`
#  while read line
#  do
#    empficsauv=`md5sum "$arbo""$line" | cut -c 33-`
#    if [ "$empfic" =  "$empficsauv" ]
#    then
#      nline="$line"
#    fi
#  done < "$lieusauv"/V."$nbrv"/fic/cheminfic.arbo
#	nline="r"
# }

# Menu
while [ "$choix" != 'q' ]
do
  echo "      --------------------------------------"
  echo "      --------------   MENU   --------------"
  echo "      --------------------------------------"
  echo " "
  echo " - 's' : Faire une sauvegarde de l'arborescence"
  echo " - 'a' : Afficher l'arborescence actuelle"
  echo " - 'c' : Comparer deux versions de sauvegarde"
  echo " - 'f' : Comparer deux version d'un fichier"
  echo " - 'p' : Parcourir une version ou arbo "
  echo " - 'd' : Supprimer l'intégralite de ou des sauvegarde(s) "
  echo " - 'q' : Quitter le menu"
  echo " "
  read choix

  case $choix in
    s)
    nbrv=`ls "$lieusauv" | wc -l`
    #vérifie si il y a une différence entre l'aborescence et la dernière sauvegarde
    if [ $(diff -r "$arbo" "$lieusauv"/V."$nbrv/sauv" | grep -c .) -gt 0 ]
    then
      #on créé le nouveau dossier sauvegarde de la nouvelle version
      mkdir "$lieusauv"/V.$(($nbrv+1))
      nbrv=$(($nbrv+1))
      #lieu de la nouvelle sauvegarde ou on fait un copie de l'arbo
      mkdir "$lieusauv"/V.$nbrv/sauv
      mkdir "$lieusauv"/V.$nbrv/fic
      cp -r "$arbo"/* "$lieusauv"/V.$nbrv/sauv
      #on écrit les chemins de la sauvegarde dans un fichier
      browsefolder "$lieusauv"/V.$(($nbrv-1))/sauv | cut -c "$nbrcsauv"- > "$lieusauv"/V."$nbrv"/fic/cheminfic.sauv
      echo " "
      #on écrit les chemins de l'arbo (nouvelle sauvegarde) dans un fichier
      browsefolder "$arbo" | cut -c "$nbrcarbo"- > "$lieusauv"/V."$nbrv"/fic/cheminfic.arbo
      #on fait la différence entre la sauvegarde et la nouvelle sauvegarde
      diff -u "$lieusauv"/V."$nbrv"/fic/cheminfic.sauv "$lieusauv"/V."$nbrv"/fic/cheminfic.arbo > "$lieusauv"/V."$nbrv"/fic/cheminfic.diff
      #on coupe les 3 premières volontairement pour exploiter ce fichier
      sed '1,3d' "$lieusauv"/V."$nbrv"/fic/cheminfic.diff > "$lieusauv"/V."$nbrv"/fic/compare.diff

      #supprime les chemins de dossier vide de notre compare.diff
      grep -E "*/\*" "$lieusauv"/V."$nbrv"/fic/compare.diff > "$lieusauv"/V."$nbrv"/fic/chemindosvide
      j=1
      nbrlcompare=`cat "$lieusauv"/V."$nbrv"/fic/compare.diff | wc -l`
      for i in `seq 1 $nbrlcompare`
      do
      	lignef=`sed -n "$i"p "$lieusauv"/V."$nbrv"/fic/compare.diff`
      	ligned=`sed -n "$j"p "$lieusauv"/V."$nbrv"/fic/chemindosvide`
      	if [ "$lignef" = "$ligned" ]
      	then
      		sed -i "$i"d "$lieusauv"/V."$nbrv"/fic/compare.diff
      		j=$(($j+1))
      	fi
      done

# Voici l'autre partie non exploitée qui devait gérer si les fichiers déplacés, renommés, supprimés, ajoutés
#      grep '^ /*' "$lieusauv"/V."$nbrv"/fic/compare.diff > "$lieupro"/tmp #appliquer diff -u
#      while read line
#      do
#        line=`echo "$line" | cut -c 2-`
#        diff -u "$lieusauv"/V.$(($nbrv-1))/fic/"$line" "$arbo"/"$line" > "$lieusauv"/V."$nbrv"/fic/`basename "$file"`.diff
#        echo "$line" > "$lieusauv"/V."$nbrv"/fic/comparen.diff
#      done < "$lieupro"/tmp
#      rm "$lieupro"/tmp
#
#      grep '^\+/*' "$lieusauv"/V."$nbrv"/fic/compare.diff > "$lieupro"/tmp
#      while read line
#      do
#        cheminfichier=`echo "$line" | cut -c 2-`
#        scheminfichier=`searchfile "$cheminfichier"`
#        $scheminfichier
#        if [ "$nline" = "r" ] #fichier créer
#      then
#         cp "$arbo""$cheminfichier" "$lieusauv"/V."$nbrv"/fic
#          echo "$line" > "$lieusauv"/V."$nbrv"/fic/comparen.diff
#        else
#          echo "$nline" > "$lieusauv"/V."$nbrv"/fic/comparen.diff
#        fi
#      done < "$lieupro"/tmp
#      rm "$lieupro"/tmp
#
#      grep '^-/*' "$lieusauv"/V."$nbrv"/fic/compare.diff > "$lieupro"/tmp
#      while read line
#      do
#        cheminfichier=`echo "$line" | cut -c 2-`
#        scheminfichier=`searchfile "$cheminfichier"`
#        $scheminfichier
#        if [ "$nline" = "r" ] #fichier créer
#        then
#          echo "$line" > "$lieusauv"/V."$nbrv"/fic/comparen.diff
#        else
#          echo "$nline" > "$lieusauv"/V."$nbrv"/fic/omparen.diff
#        fi
#      done < "$lieupro"/tmp
#      rm "$lieupro"/tmp
      #message de confirmation
      echo " "
      echo " La sauvegarde n°"$nbrv" de votre arborescence a été effectuée. "
      echo " "
    else
      #message qui prévient l'utilisateur
      echo " "
      echo " La version précédente (n°$nbrv) est identique à votre arborescence actuelle !"
      echo " "
    fi
    ;;

    c)
    #on récupère les numéros de versions que l'on veut exploiter
    echo " "
    echo "Quel est le numéro de la version choisie ?"
    read pv
    echo " "
    echo "A quel autre numéro de version souhaitez-vous la comparer ?"
    read dv

    #compare les chemins de la sauvegarde avec une autre selon son rang (numéro)
    if [ $pv -eq 1 ]
    then
      cat "$lieusauv"/V.2/fic/compare.diff > "$lieupro"/fichiercompare.diff
    else
      diff -u "$lieusauv"/V.$pv/fic/cheminfic.arbo "$lieusave"/V.$dv/fic/cheminfic.arbo > "$lieupro"/tmp.diff
      sed '1,3d' "$lieupro"/tmp.diff > "$lieupro"/fichiercompare.diff
      rm "$lieupro"/tmp.diff
    fi

    #on récupère les chemins - correspondent aux fichiers seulement dans la sauvegarde la plus vieille
    pvcontenue=`grep -E "^-/*" "$lieupro"/fichiercompare.diff`
    #on récupère les chemins + correspondent aux fichiers seulement dans la sauvegarde la plus récente
    dvcontenue=`grep -E "^\+/*" "$lieupro"/fichiercompare.diff`

    #créer un fichier html ou sera stocker les différences entre les deux versions avec les deux variables ci-dessus
    echo "
    <title> Projet Bash </title>

    <h1> Demandes de l'utilisateur : </h1>
    <table border=\"4\">
    	<tr>
    		<td> <h2> Version $pv </h2> </td>
    	<td> <h2> Version $dv </h2> </td>

    		<style>
    			*{
    			background-color: white;
    			}

    			h1 {
    			color: grey;
    			text-align: center;
    			margin-bottom: 2em;
    			}

    			h2 {
    			font-family: arial;
    			padding: 1.5em;
    			margin-top: 0.8em;
    			color: lightblue;
    		}

    			tr {
    			text-align: center;
    			border-color: black;
    			}

    			table {
    			margin: auto;
    			}

        		h3 {
    			margin-top: 0.8em;
    			padding: 0.2em;

    			}

          .pv {
            color : red;
          }

          .dv {
            color : green;
          }
    		</style>
    	</tr>
    	<tr>
        	<td> <h3 class="pv"> $pvcontenue </h3> </td>
    		<td> <h3 class="dv"> $dvcontenue </h3> </td>
    	</tr>
    </table>
    " >> "$lieupro"/pbash.html
    #redirection
    #ouverture du fichier html  dans firefox
    firefox "$lieupro"/pbash.html
    ;;

    f)
    #affiche l'arborescence afin de trouver le fichier à comparer
    tree -l $arbo
    echo " "
    #on récuère le nom du fichier
    echo "Quel fichier voulez vous comparez ?"
    read fichier
    echo " "
    #on récupère les deux versions
    echo "Quel version du fichier souhaitez-vous comparez ?"
    read pv
    echo " "
    echo "A quelle autre version voulez vous comparez "$fichier" ?"
    read sv
    nbrv=`ls "$lieusauv" | wc -l`
    i=1
    #On récupère réellement la première version d'un fichier si par exemple il a été créer dans la version 3 mais c'est la version 1 du fichier
    while [ $i -le $nbrv ]
    do
      recfic=`find "$lieusauv"/V.$i/sauv -name "$fichier" | wc -l`
      if [ $recfic -eq 1 ]
      then
        vpv=$i
        vpv=$(($vpv-1))
        #permet d'arreter le while et sortir de la boucle
        nbrv=0
      fi
    done
    #on rétablie les modifications afin de chercher dans le bon dossier de sauvegarde
    npv=$(($vpv+$pv))
    nsv=$(($vpv+$sv))
    #On récupère les deux versions des chemins des fichiers afin de les comparer
    pvfic=`find "$lieusauv"/V.$npv/sauv -name "$fichier"`
    svfic=`find "$lieusauv"/V.$nsv/sauv -name "$fichier"`
    diff -u "$pvfic" "$svfic" > "$lieupro"/tmp.diff
    #on coupe pour qu'il soit exploitable
    sed '1,3d' "$lieupro"/tmp.diff > "$lieupro"/fichier.diff

    #on fait les meme choses que pour la comparaison de versions
    pvcontenue=`grep -E "^-/*" "$lieupro"/fichier.diff`
    dvcontenue=`grep -E "^\+/*" "$lieupro"/fichier.diff`

      echo "
      <title> Projet Bash </title>

      <h1> Demandes de l'utilisateur : </h1>
      <table border=\"4\">
      	<tr>
      		<td> <h2> Version $pv </h2> </td>
      	<td> <h2> Version $dv </h2> </td>

      		<style>
      			*{
      			background-color: white;
      			}

      			h1 {
      			color: grey;
      			text-align: center;
      			margin-bottom: 2em;
      			}

      			h2 {
      			font-family: arial;
      			padding: 1.5em;
      			margin-top: 0.8em;
      			color: lightblue;
      		}

      			tr {
      			text-align: center;
      			border-color: black;
      			}

      			table {
      			margin: auto;
      			}

          		h3 {
      			margin-top: 0.8em;
      			padding: 0.2em;

      			}

            .pv {
              color : red;
            }

            .dv {
              color : green;
            }
      		</style>
      	</tr>
      	<tr>
          	<td> <h3 class="pv"> $pvcontenue </h3> </td>
      		<td> <h3 class="dv"> $dvcontenue </h3> </td>
      	</tr>
      </table>
      " >> "$lieupro"/pbashf.html
      firefox "$lieupro"/pbashf.html
    ;;

    a)
    #affiche l'arborescence actuelle grace au paquet tree
      echo " "
      echo " Voici votre arborescence actuelle :"
      echo " "
      tree -l $arbo
      echo " "
    ;;

    d)
      #demande de supression du dossier Projet ou stocke l'intégralité des données pour que le script fonctionne
      echo " "
      echo " Voulez-vous vraiment supprimer l'ensemble des sauvegarde(s) ? o/n"
      echo " "
      read choixd

      # si la réponse est positive on supprime tout
      if [ "$choixd" = 'o' ]
      then
        rm -r "$lieupro"
        echo " "
        echo " Suppresion effectuée. "
        echo " "
      fi
    ;;

    q)
      #arette le script avec un message
      echo " "
      echo "      --------------------------------------"
      echo "      ---------   FIN DU SCRIPT   ----------"
      echo "      --------------------------------------"
      echo " "
      exit;
    ;;

    *)
      #si on répond n'importe quoi nous sommes donc prévenu par ce message
      echo " "
      echo " La saisie est incorrecte !
 Veuillez entrer un choix valide !"
      echo " "
    ;;
  esac
done
