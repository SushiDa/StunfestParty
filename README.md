# Stunfest Party
Stunfest Party est un projet de jeu collaboratif. 
Un enchainement de mini-jeux, où tout le monde peut venir apporter sa touche personnelle, avec un mini-jeu, un personnage, de la musique, ou juste des assets.

Les différentes manières de contribuer :
 - **Créer un mini-jeu** (coder la base d'un mini-jeu)
 - **Créer un personnage** (minimum 3 frames en pixel art, 64x80)
 - **Contribuer à des mini-jeux** (Musique, sfx, graphismes, idées/design, etc)
 - **Contribuer au jeu global** (Musique, sfx, graphismes, etc)
 - **Améliorer le moteur** (rajouter des effets, faire des trucs cool autour des jeux)

### DISCLAIMER : C'EST MON PREMIER PROJET EN GODOT, SVP JUGEZ PAS LE NOMMAGE ET L'ORGA (mais les critiques sont bienvenues pour que je m'améliore)

## Créer un mini-jeu

 1. **Créer une branche pour votre mini-jeu**, et rajoutez un dossier pour le mini-jeu dans scenes/Minigames
 NE COMMITEZ PAS SUR LA BRANCHE MAIN. Globalement votre branche sera votre espace de travail pour faire votre jeu. Pour "valider" votre jeu dans le jeu complet, il faudra faire une pull request et on fera un merge si tout est ok

 3. **Créer la scène du mini-jeu**
Créez une scène avec le nœud de base que vous voulez, et attachez au noeud racine le script "MinigameBase"
L'explication des différentes fonctionnalités de MinigameBase sont commentées. Elles sont essentielles pour assurer la bonne intégration du mini-jeu.
Un mini-jeu a besoin au minimum d'une scène de joueur (champ "player_prefab", voir le point suivant)

 3. **Créer le joueur**
 Créer une scène avec le noeud de base que vous voulez, et attachez au noeud racine le script "PlayerHub"
Le PlayerHub va automatiquement gérer les input en fonction du joueur qui controle. Il faut absolument qu'il y ait cela pour que le jeu spawne et gère correctement les joueurs.
L'explication des fonctionnalités du PlayerHub sont commentées.

 4. **Créer les infos du jeu**
 Créer une ressource de type "MinigameInfo" à la racine du dossier de votre mini-jeu.
		Remplissez les différentes informations pour qu'il soit bien affiché pendant la roulette des mini-jeux

Un exemple de mini-jeu existe, dans le dossier scenes/Minigames/BtnMasher .

**Fonctionnalités pratiques à utiliser**

 - **SFXPlayer** : va jouer un SFX, pas besoin de créer un AudioStreamPlayer
 - **MusicPlayer** : Pour contrôler la musique en cours, on peut aussi se connecter aux signaux "beat" pour avoir des choses en rythme
  - **CharacterRepository** : Un dépôt avec tous les personnages disponibles (ex. si vous voulez faire des npc)
  -  **BeatPulse2D / BeatPulseControl** : Un script a mettre pour faire des choses bouger en rythme (changez le champ pulse scale) -- (Si quelqu'un fait un jeu en 3D, ce serait complètement adaptable pour un Node3D)

D'autres éléments pratiques arriveront après, j'essaierai d'informer si je rajoute des choses.

**Comment tester efficacement un mini-jeu ?**
Pour tester un mini-jeu, ouvrez la scène scenes/SceneManager/test_scene.gd
Dans les propriétés du nœud TestScene, renseignez le champ CurrentGameInfo, et utilisez les boutons pour charger le jeu, qui correspondra à la méthode utilisée pour charger le jeu dans une partie normale.

## Créer un personnage
Un personnage est juste une collection de sprites et un nom. Il faut minimum 3 sprites :
- Un sprite "Idle" = Pose au repos
- Un sprite "Action1" => Pose différente mais pas forcément excessive
- Un sprite "Action2" => Pose cool et différente

Tout sprite en plus sera compté comme "Action2", et récupérer explicitement une "Action2" en choisira une au hasard.
Les sprites sont affectés selon leur ordre alphabétique

Les dimensions des sprites sont en **64x80** , c'est à dire **64 de large et 80 de haut**
Pourquoi ces dimensions étranges ? Pensez à un personnage de 32x64 (32 de large, 64 de haut, c'est la hitbox principale) avec une marge de 16 a droite, a gauche et en haut. 
Le personnage doit être centré, et regarder vers la droite ou vers la caméra.  Les pieds (ou tout autre élément qui touche le sol) touchent le bas du sprite.
Vous pouvez utiliser tout l'espace mais garder la partie principale du corps du personnage dans la partie centrale est recommandé

Pour créer le personnage en lui même, il suffit de créer un dossier avec son nom dans le dossier **assets/characters** (Exemple, "assets/characters/JeanGérard/") et y mettre les différents sprite.

**TODO** une possibilité de "décaler" la preview du personnage dans la sélection sera rajoutée dans le futur

## Contribuer à un mini-jeu
Pour contribuer directement à un mini-jeu, n'hésitez pas à contacter le créateur du mini-jeu pour fournir différents fichiers ou autres éléments. 
Pour soumettre des idées on pourra passer par les différents channels discord
**TODO** : Un dépôt global d'assets sera mis en place si l'on veut juste fournir des assets partagés (comme par exemple des boucles de musique, des éléments de décor, etc.)

## Contribuer à un mini-jeu
Pour contribuer directement à un mini-jeu, n'hésitez pas à contacter le créateur du mini-jeu pour fournir différents fichiers ou autres éléments. 
Pour soumettre des idées on pourra passer par les différents channels discord

## Contribuer au jeu global
Un peu comme la contribution, à part que là ce serait en contactant les personnes qui travailleront sur le moteur de jeu global (pour le moment, ce sera moi, Sushi)

## Améliorer le moteur
Contactez-moi (Sushi) pour que l'on travaille ensemble sur le moteur. 
