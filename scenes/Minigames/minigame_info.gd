extends Resource
class_name MinigameInfo

@export var name:String
@export var subtitle:String
@export_multiline var authors:String
@export var prefab:PackedScene

@export_subgroup("Movement")
@export var action_horizontal:String
@export var action_vertical:String
@export var action_movement:String

@export_subgroup("Button Press")
@export var action_btn1:String
@export var action_btn2:String
@export var action_btn_any:String

@export_subgroup("Button Mash")
@export var action_btn1_mash:String
@export var action_btn2_mash:String
@export var action_btn_any_mash:String
@export var action_btn_alternate_mash:String

@export_subgroup("Button Hold")
@export var action_btn1_hold:String
@export var action_btn2_hold:String
@export var action_btn_any_hold:String


