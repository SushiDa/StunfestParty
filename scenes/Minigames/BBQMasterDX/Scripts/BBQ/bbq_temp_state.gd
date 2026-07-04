extends Resource
class_name BBQMaster_TemperatureState

enum TempStateEnum { COLD, HOT, ON_FIRE }

@export var threshold: float
@export var status: TempStateEnum
@export var fire_spawn_rate: float
@export var cook_speed: float
@export var sprite: Texture2D

