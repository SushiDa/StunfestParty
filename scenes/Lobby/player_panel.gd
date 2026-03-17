class_name PlayerPanel
extends Node2D

@export var _player_index: int
@export var _car_sprite: Sprite2D
@export var _player_number:Label
@export var _player_name:Label
@export var _sprite: Sprite2D
@export var _animation: AnimationPlayer

var _character: CharacterInfo
var _character_selected: bool
var _current_pose: int = 0
var has_player: bool

func _ready() -> void:
	MusicPlayer.beats(0.5).connect(on_mid_beat)
	MusicPlayer.beat.connect(on_beat)
	MusicPlayer.beats(4,true,3).connect(on_fourth_beat)
	_car_sprite.material = _car_sprite.material.duplicate()
	var mat:ShaderMaterial = _car_sprite.material as ShaderMaterial
	mat.set_shader_parameter("shift_amount", PlayerInfo.get_hue_shift(_player_index))
	_player_number.text = "P" + str(_player_index + 1)
	_player_number.self_modulate = PlayerInfo.get_color(_player_index)
	_player_name.text = ""
	disconnect_cursor(null)

func assign_cursor(cursor:LobbyCursor) -> void:
	cursor.character_hovered.connect(on_character_hovered)
	cursor.character_selected.connect(on_character_selected)
	cursor.player_left.connect(disconnect_cursor)
	has_player = true
	_animation.play("join")

func disconnect_cursor(_cursor:LobbyCursor) -> void:
	_character = null
	# _sprite.texture = null
	_character_selected = false
	_animation.play("leave")
	has_player = false
	
func on_character_hovered(character: CharacterInfo):
	_character = character
	if _character != null: _player_name.text = _character.character_name
	switch_pose(0)
	
func on_character_selected(select:bool):
	_character_selected = select
	if select: 
		switch_pose(_current_pose)
		var mat:ShaderMaterial = _car_sprite.material as ShaderMaterial
		mat.set_shader_parameter("shaking", true)
	else: 
		switch_pose(0)
		var mat:ShaderMaterial = _car_sprite.material as ShaderMaterial
		mat.set_shader_parameter("shaking", false)

func on_mid_beat(beat:int):
	if(beat % 2 == 0): return
	_current_pose = 0
	if(!_character_selected): return
	switch_pose(0)

func on_beat(beat:int):
	if(beat % 4 == 3): return
	_current_pose = 1
	if(!_character_selected): return
	switch_pose(1)
	
func on_fourth_beat(_beat:int):
	_current_pose = 2
	if(!_character_selected): return
	switch_pose(2)
	
func switch_pose(pose: int) -> void:
	if(!_character): return
	var tex:Texture2D = null
	match pose:
		0: tex = _character.idle_sprite
		1: tex = _character.action1_sprite
		2: tex = _character.action2_sprite
	_sprite.texture = tex

func start_animation() -> void:
	_animation.play("start")
