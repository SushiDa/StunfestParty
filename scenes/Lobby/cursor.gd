class_name LobbyCursor
extends Node2D

signal player_left(player:LobbyCursor)
signal character_selected(select:bool)
signal character_hovered(character:CharacterInfo)

const corner_z = [[4,3,2,1],[3,4,1,2],[2,1,4,3],[1,2,3,4]]

@export var corners: Array[Sprite2D]
@export var label_pos: Array[Vector2]
@export var player_label: Label
@export var scale_multiplier: float

@export var sfx_move: AudioStreamPlayer

var player_number: int
var device_number: int
var grid_manager: LobbyGridManager
var _character_selected: bool
var selected_index: int

var input_locked: bool
var previous_movement: Vector2
var player_info: PlayerInfo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Vector2.ONE * grid_manager.offset_scale * scale_multiplier
	SignalBus.lock_inputs.connect(func(): input_locked = true)
	grid_manager.selection_changed.connect(on_selection_changed)
	modulate = PlayerInfo.get_color(player_number)
	selected_index = randi_range(0, grid_manager.slot_count - 1)
	for i in 4:
		corners[i].z_index = corner_z[i][player_number]
	
	player_label.text = str(player_number + 1)
	player_label.position = label_pos[player_number]
	
	if(device_number >= 0):
		Input.set_joy_light(device_number, PlayerInfo.get_color(player_number))
	move_selection(0)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if input_locked: 
		previous_movement = Vector2.ZERO
		return
	var input_movement: Vector2 = MultiplayerInput.get_vector(device_number,"move_left","move_right","move_down","move_up")
	if !_character_selected && input_movement.x != previous_movement.x:
		if (previous_movement.x + 0.25) * (input_movement.x + 0.25) < 0 && previous_movement.x > input_movement.x :
			move_selection(-1)
		if (previous_movement.x - 0.25) * (input_movement.x - 0.25) < 0 && previous_movement.x < input_movement.x :
			move_selection(1)
				
	if !_character_selected && input_movement.y != previous_movement.y:
		if (previous_movement.y + 0.25) * (input_movement.y + 0.25) < 0 && previous_movement.y > input_movement.y :
			move_selection(grid_manager.row_length)
		if (previous_movement.y - 0.25) * (input_movement.y - 0.25) < 0 && previous_movement.y < input_movement.y :
			move_selection(-grid_manager.row_length)
	
	previous_movement = input_movement
	
	if(!_character_selected && MultiplayerInput.is_action_just_pressed(device_number, "action_one")):
		player_info.character_info = grid_manager.get_character(selected_index)
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
	if delta != 0: sfx_move.play()
	selected_index = grid_manager.get_next_index(selected_index, delta)
	position = grid_manager.get_slot_position(selected_index)
	character_hovered.emit(grid_manager.get_character(selected_index))
	
func on_selection_changed() -> void:
	if(!_character_selected): move_selection(0)
	
