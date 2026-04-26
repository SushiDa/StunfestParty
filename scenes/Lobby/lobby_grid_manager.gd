class_name LobbyGridManager
extends Node2D

@export var row_length: int
@export var row_offset: Vector2
@export var column_offset: Vector2
@export var offset_scale: float
@export var slot_prefab: PackedScene
@export var centered: bool

@onready var _start_position: Vector2 = Vector2.ZERO
@onready var _slots: Array[LobbyCharacterSlot] = []

var slot_count: int:
	get: return _slots.size()

signal selection_changed

var characters: Array[CharacterInfo] = []

var _locked_indexes: Array[int] = []

func init() -> void:
	characters = CharacterRepository.get_all_characters();
	_build_grid()

func _build_grid() -> void:
	var chara_local: Array[CharacterInfo] = [];
	chara_local.append_array(characters);
	var dummy_character := CharacterInfo.new()
	
	var emptySlots:int = (row_length - chara_local.size() % row_length) % row_length

	#if(emptySlots == 2 && row_length == 3):
	#	chara_local.insert(2, dummy_character)
	#	chara_local.insert(characters.size() - 2, dummy_character);
	#else:
	#if (emptySlots % 2 == 1):
	#	characters.insert(row_length - 1, dummy_character);
	@warning_ignore("integer_division")
	for i in emptySlots:
		characters.append(dummy_character);
	
	_start_position = column_offset * offset_scale / 2.0 + row_offset * offset_scale / 2.0
	if centered:
		_start_position = - (column_offset * (row_length - 1)) * offset_scale / 2.0 - row_offset * (ceilf((1 * chara_local.size() ) / (1.0 * row_length)) - 1) * offset_scale / 2.0;

	var index = -1;
	for chara:CharacterInfo in characters:
		index += 1
		if chara.is_dummy(): continue
		var slot:LobbyCharacterSlot = slot_prefab.instantiate()
		slot.target_scale = offset_scale
		_slots.append(slot)
		slot.assign_character(chara)
		add_child(slot)
		slot.position = get_slot_position(index)
	
func get_slot_position(index: int) -> Vector2:
	@warning_ignore("integer_division")
	var row := index / row_length;
	var column := index % row_length
	return _start_position + row * row_offset * offset_scale + column * column_offset * offset_scale;

func get_character(index: int):
	if(index < 0 || index >= characters.size() || characters[index].is_dummy()): return null
	return characters[index]
	
func lock_slot(index: int, player_number: int)-> void:
	_locked_indexes.append(index)
	if(index < 0 || index >= characters.size() || characters[index].is_dummy()): return
	_slots[index].lock(player_number)
	selection_changed.emit()
	
func unlock_slot(index: int)-> void:
	var pos = _locked_indexes.find(index)
	_locked_indexes.remove_at(pos)
	if(index < 0 || index >= characters.size() || characters[index].is_dummy()): return
	_slots[index].unlock()

func get_next_index(start_index: int, delta: int) -> int:
	var new_index = start_index + delta
	if(new_index < 0): new_index += characters.size()
	new_index %= characters.size()
	if(_locked_indexes.has(new_index) || characters[new_index].is_dummy()):
		var n_delta = delta
		if(delta == 0): n_delta = 1
		return get_next_index(new_index, n_delta)
	return new_index
	
