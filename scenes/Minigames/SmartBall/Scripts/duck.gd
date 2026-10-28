extends Area2D
class_name Duck

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shadow: Sprite2D = get_node_or_null("Shadow")
@onready var confinement: ConfinementComponent = $ConfinementComponent
@export var respawnzone: CollisionShape2D

# Effet 3D du lancer
@export var max_arc_height: float = 80.0    # hauteur max du saut (à force max)
@export var arc_duration_min: float = 0.35  # durée du vol à faible force
@export var arc_duration_max: float = 0.8   # durée du vol à force max
@export var carry_offset: Vector2 = Vector2.ZERO  # décalage de base du sprite dans la scène

# Doit correspondre aux min/max_charge_force du joueur
@export var min_throw_force: float = 300.0
@export var max_throw_force: float = 950.0

# Déplacement aléatoire
@export var wander_speed: float = 40.0
@export var wander_radius: float = 120.0    # distance max de la prochaine destination
@export var wander_pause_min: float = 0.5
@export var wander_pause_max: float = 2.5

var velocity: Vector2 = Vector2.ZERO
var last_thrower: PlayerSmart = null
var is_thrown: bool = false
var is_holded: bool = false

# Hauteur simulée (axe z)
var height: float = 0.0
var height_velocity: float = 0.0
var gravity_z: float = 0.0
var base_sprite_scale: Vector2
var base_shadow_scale: Vector2
var squash_tween: Tween

# État de l'errance
var wander_target: Vector2
var wander_pause_timer: float = 0.0
var is_wandering: bool = false


func _ready() -> void:
	add_to_group("Duck")
	body_entered.connect(_on_body_entered)
	_init_visuals()


func _init_visuals() -> void:
	base_sprite_scale = sprite.scale
	if shadow:
		base_shadow_scale = shadow.scale


func _physics_process(delta: float) -> void:

	if is_holded:
		sprite.play("Idle")
		return

	# Ni porté ni lancé : le canard erre
	if not is_thrown:
		_wander(delta)
		_update_visuals()
		return

	_update_height(delta)

	velocity *= pow(0.98, delta * 60.0)

	var old_position := global_position
	var target := old_position + velocity * delta
	var confined := confinement.confine_position(target, old_position)

	# Rebond seulement si la position a vraiment été modifiée par le confinement
	if not is_equal_approx(confined.x, target.x):
		velocity.x = -velocity.x * 0.6
	if not is_equal_approx(confined.y, target.y):
		velocity.y = -velocity.y * 0.6

	global_position = confined

	# Le canard ne s'arrête que s'il est au sol
	if velocity.length() < 5.0 and height <= 0.0:
		velocity = Vector2.ZERO
		is_thrown = false
		set_deferred("monitoring", true)
		_start_wander_pause()

	_update_visuals()


# --- Errance -----------------------------------------------------------------

func _wander(delta: float) -> void:
	# Phase de pause
	if wander_pause_timer > 0.0:
		wander_pause_timer -= delta
		sprite.play("Idle")  
		if wander_pause_timer <= 0.0:
			_pick_wander_target()
		return

	# Pas de destination : en choisir une
	if not is_wandering:
		_pick_wander_target()
		return

	var to_target := wander_target - global_position
	var step := wander_speed * delta

	# Arrivé : on fait une pause
	if to_target.length() <= step:
		global_position = wander_target
		_start_wander_pause()
		return

	var old_position := global_position
	var target := old_position + to_target.normalized() * step
	var confined := confinement.confine_position(target, old_position)

	# Bloqué par le confinement : on abandonne cette destination
	if confined.distance_to(target) > 0.1:
		global_position = confined
		_start_wander_pause()
		return

	global_position = confined
	sprite.flip_h = to_target.x < 0.0  # inverser si le sprite regarde à gauche par défaut
	sprite.play("Walk")


func _pick_wander_target() -> void:
	var angle := randf() * TAU
	var dist := randf_range(wander_radius * 0.3, wander_radius)
	wander_target = global_position + Vector2.RIGHT.rotated(angle) * dist
	is_wandering = true


func _start_wander_pause() -> void:
	is_wandering = false
	wander_pause_timer = randf_range(wander_pause_min, wander_pause_max)


# --- Hauteur / visuels -------------------------------------------------------

func _update_height(delta: float) -> void:
	if height <= 0.0 and height_velocity <= 0.0:
		return
	height_velocity -= gravity_z * delta
	height += height_velocity * delta
	if height <= 0.0:
		height = 0.0
		# Petit rebond amorti + squash à l'impact
		if height_velocity < -60.0:
			height_velocity = -height_velocity * 0.35
			_play_squash()
		else:
			height_velocity = 0.0


func _update_visuals() -> void:
	# Le sprite monte avec la hauteur et grossit légèrement (plus proche de la caméra)
	var lift := minf(height, max_arc_height * 1.5)
	var scale_boost := 1.0 + lift / 300.0
	sprite.position = carry_offset + Vector2(0, -lift)
	if squash_tween == null or not squash_tween.is_running():
		sprite.scale = base_sprite_scale * scale_boost

	# L'ombre reste au sol, rétrécit et s'estompe quand le canard monte
	if shadow:
		var shadow_factor := 1.0 / (1.0 + lift / 80.0)
		shadow.scale = base_shadow_scale * shadow_factor
		shadow.modulate.a = 0.5 * shadow_factor + 0.15


func _play_squash() -> void:
	if squash_tween:
		squash_tween.kill()
	squash_tween = create_tween()
	sprite.scale = Vector2(base_sprite_scale.x * 1.3, base_sprite_scale.y * 0.7)
	squash_tween.tween_property(sprite, "scale", base_sprite_scale, 0.15)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _reset_height() -> void:
	height = 0.0
	height_velocity = 0.0
	if squash_tween:
		squash_tween.kill()


# --- Spawn / lancer / ramassage ----------------------------------------------

# retourne des coordonnées random dans la zone area
func random_point_in_area(collision_shape: CollisionShape2D) -> Vector2:
	var rect_shape: RectangleShape2D = collision_shape.shape as RectangleShape2D
	var extents = rect_shape.size / 2.0
	var x = randf_range(-extents.x, extents.x)
	var y = randf_range(-extents.y, extents.y)
	var local_point = Vector2(x, y)
	return collision_shape.global_transform * local_point


func spawn() -> void:
	global_position = random_point_in_area(respawnzone)
	velocity = Vector2.ZERO
	is_thrown = false
	is_holded = false
	_reset_height()
	_start_wander_pause()


func throw(direction: Vector2, force: float = 150.0) -> void:
	if direction.length() > 0.0:
		direction = direction.normalized()
	is_thrown = true
	is_holded = false
	is_wandering = false
	velocity = direction * force

	# Plus la force est grande, plus l'arc est haut et long
	var t := clampf(inverse_lerp(min_throw_force, max_throw_force, force), 0.0, 1.0)
	var arc_height := lerpf(max_arc_height * 0.4, max_arc_height, t)
	var duration := lerpf(arc_duration_min, arc_duration_max, t)
	# Parabole : hauteur max = v² / (2g), durée = 2v / g
	gravity_z = 8.0 * arc_height / (duration * duration)
	height_velocity = 4.0 * arc_height / duration
	height = 0.0


func _on_body_entered(body) -> void:
	if is_holded:
		return
	if body.is_in_group("Joueurs"):
		body.pick_object(self)
		last_thrower = body
		is_holded = true
		is_thrown = false
		is_wandering = false
		_reset_height()
		set_deferred("monitoring", false)
