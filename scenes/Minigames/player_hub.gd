extends Node
## Classe de base d'un joueur de minijeu.
##
## Contient des fonctions toutes prêtes qui gèrent les input
## Les signaux émettent pour une pression ponctuelle, les variables donnent l'état continu
class_name PlayerHub

var score: float ## Score du jeu courant

signal player_won(player: PlayerInfo)

## signaux et variables pour le déplacement
var movement: Vector2
signal move_left
signal move_right
signal move_up
signal move_down

## signal et variable pour le bouton 1 (bouton sud)
signal btn1_pressed
var btn1_hold: bool

## signal et variable pour le bouton 2 (bouton est)
signal btn2_pressed
var btn2_hold: bool

var _global_controls_enabled: bool = false ## active / désactive les controles. Utilisé par le jeu global (ne pas utiliser)


var controls_enabled: bool = true ## active / désactive les controles. Utilisé par les minijeu

var _player_info: PlayerInfo ## PlayerInfo rattachée au joueur.



func set_player_info(info:PlayerInfo) -> void:
	_player_info = info

func get_character() -> CharacterInfo:
	if _player_info != null: return _player_info.character_info
	else :
		return CharacterRepository.get_all_characters()[0]

func get_player_index() -> int: ## Index du joueur ( 0 .. 3 )
	if _player_info != null: return _player_info.player_index
	return 0;
	
func get_player_number() -> int: ## Numéro du joueur ( 1 .. 4 )
	if _player_info != null: return _player_info.player_number
	return 1;

func get_player_color() -> Color: ## Couleur du joueur
	if _player_info != null: return _player_info.get_player_color()
	else : return Color.CYAN

func win() -> void: ## Termine instantanément le minijeu
	player_won.emit(_player_info)

func _process(_delta: float) -> void:
	if _global_controls_enabled && controls_enabled :
		var device = -1
		if _player_info != null: device = _player_info.device_number
		var input_movement: Vector2 = MultiplayerInput.get_vector(device,"move_left","move_right","move_down","move_up")
		var input_btn1: bool = MultiplayerInput.is_action_pressed(device, "action_one")
		var input_btn2: bool = MultiplayerInput.is_action_pressed(device, "action_two")
		
		if input_movement.x != movement.x:
			if (movement.x + 0.25) * (input_movement.x + 0.25) < 0 && movement.x > input_movement.x :
				move_right.emit()
			if (movement.x - 0.25) * (input_movement.x - 0.25) < 0 && movement.x < input_movement.x :
				move_left.emit()
				
		if input_movement.y != movement.y:
			if (movement.y + 0.25) * (input_movement.y + 0.25) < 0 && movement.y > input_movement.y :
				move_down.emit()
			if (movement.y - 0.25) * (input_movement.y - 0.25) < 0 && movement.y < input_movement.y :
				move_up.emit()
		
		if input_btn1 && !btn1_hold: btn1_pressed.emit()
		if input_btn2 && !btn2_hold: btn2_pressed.emit()
		
		movement = input_movement
		btn1_hold = input_btn1
		btn2_hold = input_btn2
	else :
		movement = Vector2.ZERO
		btn1_hold = false
		btn2_hold = false

## ne pas utiliser. Uniquement pour l'utilisation globale. Utiliser la variable controls_enabled
func change_global_control_status(enable: bool) -> void : 
	_global_controls_enabled = enable