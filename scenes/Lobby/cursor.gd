class_name LobbyCursor
extends Node2D

signal player_left(player:LobbyCursor)
signal character_selected(select:bool)
signal character_hovered(character:CharacterInfo)

const corner_z = [[3,2,1,0],[2,3,0,1],[1,0,3,2],[0,1,2,3]]

@export var corners: Array[Sprite2D]
var player_number: int
var device_number: int
var grid_manager: LobbyGridManager
var _character_selected: bool
var selected_index: int

var input_locked: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.lock_inputs.connect(func(): input_locked = true)
	grid_manager.selection_changed.connect(on_selection_changed)
	modulate = PlayerInfo.get_color(player_number)
	selected_index = randi() % grid_manager.characters.size()
	for i in 4:
		corners[i].z_index = corner_z[i][player_number]
		
	if(device_number >= 0):
		Input.set_joy_light(device_number, PlayerInfo.get_color(player_number))
	move_selection(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if input_locked: return
	if(!_character_selected && MultiplayerInput.is_action_just_pressed(device_number, "move_right")):
		move_selection(1)
	if(!_character_selected && MultiplayerInput.is_action_just_pressed(device_number, "move_left")):
		move_selection(-1)
	if(!_character_selected && MultiplayerInput.is_action_just_pressed(device_number, "move_up")):
		move_selection(-grid_manager.row_length)
	if(!_character_selected && MultiplayerInput.is_action_just_pressed(device_number, "move_down")):
		move_selection(grid_manager.row_length)
		
	if(!_character_selected && MultiplayerInput.is_action_just_pressed(device_number, "action_one")):
		_character_selected = true
		grid_manager.lock_slot(selected_index, player_number)
		character_selected.emit(true)
		
	if(MultiplayerInput.is_action_just_pressed(device_number, "action_two")):
		if(_character_selected):
			_character_selected = false
			grid_manager.unlock_slot(selected_index)
			character_selected.emit(false)
		else:
			Input.set_joy_light(device_number, Color.BLACK)
			player_left.emit(self)
			queue_free()
		
		
func move_selection(delta: int) -> void:
	selected_index = grid_manager.get_next_index(selected_index, delta)
	position = grid_manager.get_slot_position(selected_index)
	character_hovered.emit(grid_manager.get_character(selected_index))
	

func on_selection_changed() -> void:
	if(!_character_selected): move_selection(0)
	
