class_name PlayerPanel
extends Node2D

@export var _sprite: Sprite2D

var _character: CharacterInfo
var _character_selected: bool
var _current_pose: int = 0

func _ready() -> void:
	MusicPlayer.beats(0.5).connect(on_mid_beat)
	MusicPlayer.beat.connect(on_beat)
	MusicPlayer.beats(4,true,3).connect(on_fourth_beat)
	disconnect_cursor(null)

func assign_cursor(cursor:LobbyCursor) -> void:
	cursor.character_hovered.connect(on_character_hovered)
	cursor.character_selected.connect(on_character_selected)
	cursor.player_left.connect(disconnect_cursor)

func disconnect_cursor(_cursor:LobbyCursor) -> void:
	_character = null
	_sprite.texture = null
	_character_selected = false
	
func on_character_hovered(character: CharacterInfo):
	_character = character
	switch_pose(0)
	
func on_character_selected(select:bool):
	_character_selected = select
	if select: switch_pose(_current_pose)
	else: switch_pose(0)
	
	
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
	
