class_name LobbyManager
extends Node

@export var music: AudioStream
@export var grid_manager: LobbyGridManager
@export var player_panels: Array[PlayerPanel]
@export var cursor_prefab: PackedScene
@export var party_scene: PackedScene
@export var animator: AnimationPlayer

@export var sfx_join: AudioStreamPlayer
@export var sfx_leave: AudioStreamPlayer
@export var sfx_select: AudioStreamPlayer
@export var sfx_start1: AudioStreamPlayer
@export var sfx_start2: AudioStreamPlayer

const MIN_PLAYERS = 2
const MAX_PLAYERS = 4
var player_data: Dictionary[int, PlayerInfo] = {}

var _num_ready:int = 0
var _all_ready:bool = false
var busy:bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicPlayer.play(music)
	grid_manager.init()

func _process(_delta: float) -> void:
	if busy: return
	handle_join_input()
	if someone_wants_to_start() && _all_ready:
		sfx_start1.play()
		sfx_start2.play()
		busy = true
		SignalBus.lock_inputs.emit()
		PlayerManager.register_players(player_data.values())
		for p in player_panels:
			if p.has_player:
				p.start_animation()
				await get_tree().create_timer(.15).timeout
		
		await get_tree().create_timer(.5).timeout
		SceneManager.swap_scenes(party_scene.resource_path,null,self)

func join(device: int) -> void:
	var player = next_player()
	if player < 0: return
	
	var info := PlayerInfo.new()
	info.device_number = device
	info.player_index = player
	info.character_info = null
	player_data[player] = info
	sfx_join.play()
	
	# Spawn cursor here
	var cursor:LobbyCursor = cursor_prefab.instantiate()
	player_panels[player].assign_cursor(cursor)
	cursor.device_number = device
	cursor.player_number = player
	cursor.player_info = info
	cursor.player_left.connect(on_player_left)
	cursor.character_selected.connect(on_player_ready)
	cursor.grid_manager = grid_manager
	grid_manager.add_child(cursor)
	update_ready_status()

func on_player_ready(is_ready:bool):
	if(is_ready): 
		_num_ready += 1
		sfx_select.play()
	else: 
		_num_ready -= 1
		sfx_leave.play()
	update_ready_status()

func update_ready_status() -> void:
	var new_all_ready = get_player_count() == _num_ready && get_player_count() >= MIN_PLAYERS
	if new_all_ready != _all_ready:
		var anim = "hide"
		if new_all_ready: anim = "show"
		animator.play(anim)
	_all_ready = new_all_ready

func on_player_left(cursor: LobbyCursor):
	var player = cursor.player_number
	if player_data.has(player):
		player_data.erase(player)
	cursor.player_left.disconnect(on_player_left)
	update_ready_status()
	

func get_player_count():
	return player_data.size()

func get_player_indexes():
	return player_data.keys()

func get_player_info(player: int) -> PlayerInfo:
	if player_data.has(player):
		return player_data[player]
	return null

func handle_join_input():
	for device in get_unjoined_devices():
		if MultiplayerInput.is_action_just_pressed(device, "start"):
			join(device)

# to see if anybody is pressing the "start" action
# this is an example of how to look for an action on all players
# note the difference between this and handle_join_input(). players vs devices.
func someone_wants_to_start() -> bool:
	for player in player_data:
		var device = player_data[player].device_number
		if MultiplayerInput.is_action_just_pressed(device, "start"):
			return true
	return false

func is_device_joined(device: int) -> bool:
	for player_id in player_data:
		var d = player_data[player_id].device_number
		if device == d: return true
	return false

# returns a valid player integer for a new player.
# returns -1 if there is no room for a new player.
func next_player() -> int:
	for i in MAX_PLAYERS:
		if !player_data.has(i): return i
	return -1

# returns an array of all valid devices that are *not* associated with a joined player
func get_unjoined_devices():
	var devices = Input.get_connected_joypads()
	# also consider keyboard player
	devices.append(-1)
	
	# filter out devices that are joined:
	return devices.filter(func(device): return !is_device_joined(device))
