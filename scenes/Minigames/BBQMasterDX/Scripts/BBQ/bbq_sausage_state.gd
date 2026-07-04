extends Resource
class_name BBQMaster_SausageState

enum SausageStateEnum { RAW, COOKED, PERFECT, OVERCOOKED }

@export var threshold: float;
@export var status: SausageStateEnum;
@export var score: int;
@export var sprite: Texture2D

