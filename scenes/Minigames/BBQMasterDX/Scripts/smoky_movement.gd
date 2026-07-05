extends Node2D
class_name BBQMaster_Smokey

@export var base_speed: float
@export var attack_speed: float
@export var bbq_min_distance: float
@export var player_min_distance: float

enum SmokeyStatus { SLEEP, AWAKE, PRE_ATTACK, ATTACKING }

var target_bbq: BBQMaster_BBQ
var status: SmokeyStatus = SmokeyStatus.SLEEP

var locked_bbq: BBQMaster_BBQ

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if status == SmokeyStatus.AWAKE :
		if target_bbq == null: 
			status = SmokeyStatus.SLEEP
		else :
			var direction = (target_bbq.global_position - global_position).normalized()
			if direction.x <0:
				if get_node("AnimatedSprite2D").flip_h !=true:get_node("AnimatedSprite2D").flip_h = true
			elif direction.x >0:
				if get_node("AnimatedSprite2D").flip_h !=false:get_node("AnimatedSprite2D").flip_h = false
			global_position = global_position + direction * base_speed * delta
			if global_position.distance_squared_to(target_bbq.global_position) < (bbq_min_distance * bbq_min_distance) :
				status = SmokeyStatus.ATTACKING
				locked_bbq = target_bbq
				locked_bbq.destroy_bbq()
				global_position = target_bbq.global_position
				target_bbq = null;
	elif status == SmokeyStatus.ATTACKING :
		var player = (locked_bbq._player.get_node("%BBQPlayerMgr") as BBQMasterPlayer)
		var direction = (player._root.global_position - global_position).normalized()
		global_position = global_position + direction * attack_speed * delta
		if global_position.distance_squared_to(player._root.global_position) < (bbq_min_distance * bbq_min_distance) :
			player.oh_no_its_smokey()
			locked_bbq = null;
			global_position = player._root.global_position
			status = SmokeyStatus.AWAKE

func wake_up():
	status = SmokeyStatus.AWAKE
	get_node("AnimatedSprite2D").animation = "moving"
	get_node("AnimatedSprite2D").play()
	get_node("Sprite2D").visible = false
	pass

func is_awake() -> bool:
	return status != SmokeyStatus.ATTACKING
