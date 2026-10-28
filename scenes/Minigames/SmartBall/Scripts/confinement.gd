extends Node
class_name ConfinementComponent

@export var confinement_zone: Area2D
@export var exclusion_zones: Array[Area2D] = []
	

func _is_in_area(pos: Vector2, area: Area2D) -> bool:
	if not is_instance_valid(area):
		return false
	var space: PhysicsDirectSpaceState2D = area.get_world_2d().direct_space_state
	var q := PhysicsPointQueryParameters2D.new()
	q.position = pos
	q.collide_with_areas = true
	q.collide_with_bodies = false
	q.collision_mask = 0xFFFFFFFF
	for hit in space.intersect_point(q, 32):
		if hit.collider == area:
			return true
	return false

func is_position_valid(pos: Vector2) -> bool:
	if confinement_zone and not _is_in_area(pos, confinement_zone):
		return false
	for zone in exclusion_zones:
		if _is_in_area(pos, zone):
			return false
	return true

func confine_position(current_pos: Vector2, old_pos: Vector2) -> Vector2:
	if is_position_valid(current_pos):
		return current_pos
	var try_x := Vector2(current_pos.x, old_pos.y)
	if is_position_valid(try_x):
		return try_x
	var try_y := Vector2(old_pos.x, current_pos.y)
	if is_position_valid(try_y):
		return try_y
	return old_pos