extends Node2D
class_name BBQMaster_Smokey

@export var base_speed: float
@export var attack_speed: float
@export var bbq_min_distance: float
@export var player_min_distance: float

@export var music_delay: float
@export var sfx_wake_up: AudioStream
@export var wake_up_music: AudioStream

enum SmokeyStatus { SLEEP, AWAKE, PRE_ATTACK, ATTACKING }

var target_bbq: BBQMaster_BBQ
var status: SmokeyStatus = SmokeyStatus.SLEEP

var locked_bbq: BBQMaster_BBQ

var wake_up_timer: Timer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wake_up_timer = Timer.new()
	add_child(wake_up_timer)
	wake_up_timer.timeout.connect(play_wake_up_music)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if status == SmokeyStatus.AWAKE :
		if target_bbq == null: 
			status = SmokeyStatus.SLEEP
		else :
			var direction = (target_bbq.global_position - global_position).normalized()
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
	MusicPlayer.stop();
	SFXPlayer.play(sfx_wake_up)
	wake_up_timer.wait_time = music_delay
	wake_up_timer.start()
	pass

func is_awake() -> bool:
	return status != SmokeyStatus.ATTACKING

func play_wake_up_music():
	wake_up_timer.stop()
	status = SmokeyStatus.AWAKE
	MusicPlayer.play(wake_up_music)
