extends Duck

class_name Bomb

@onready var Chrono: Timer = $Chrono

# --- Contantes Explosion ---
const EXPLOSION_RADIUS: float = 150.0      # Rayon de l'explosion en pixels
const EXPLOSION_FORCE: float = 600.0       # Force d'éjection appliquée aux joueurs

func _ready() -> void:
	add_to_group("Bomb")
	_init_visuals()
	sprite.play("Off")
	sprite.animation_finished.connect(_on_anim_finished)
	body_entered.connect(_on_body_entered)

func _on_timer_timeout() -> void:
	sprite.top_level = false
	sprite.position = Vector2.ZERO
	sprite.offset = Vector2.ZERO
	sprite.play("Explosion")
	if last_thrower and last_thrower.has_method("release_object"):
			last_thrower.release_object()
	_explode()
	
func _explode() -> void:
	var all_bodies = get_tree().get_nodes_in_group("Joueurs")
	var cam        = get_tree().get_first_node_in_group("camera")
	
	if cam:
		cam.shake(0.7, 12.0)

	for body in all_bodies:
		var distance = global_position.distance_to(body.global_position)
		if distance <= EXPLOSION_RADIUS:
			_eject_body(body, distance)


func spawn() -> void:
	global_position = random_point_in_area(respawnzone)
	velocity = Vector2.ZERO
	is_thrown = false
	is_holded = false
	_reset_height()


func _physics_process(delta: float) -> void:

	if is_holded:
		return

	if not is_thrown:
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

	if velocity.length() < 5.0 and height <= 0.0:
		velocity = Vector2.ZERO
		is_thrown = false
		set_deferred("monitoring", true)

	_update_visuals()

# Ejection d'un joueur
func _eject_body(body: Node2D, distance: float) -> void:
	
	# On calcule la direction
	var eject_direction: Vector2
	if global_position.distance_to(body.global_position) > 0.1:
		eject_direction = (body.global_position - global_position).normalized()
	else:
		# Direction aléatoire si superposés
		eject_direction = Vector2(randf_range(-1.0, 1.0), -1.0).normalized()

	# Atténuation selon la distance 
	var falloff = 1.0 - clamp(distance / EXPLOSION_RADIUS, 0.0, 1.0)
	var final_force = EXPLOSION_FORCE * falloff

	# Applique la force au joueur
	if body.has_method("apply_explosion_force"):
		body.apply_explosion_force(eject_direction * final_force)
	elif "velocity" in body:
		body.velocity += eject_direction * final_force

func _on_anim_finished():
	if sprite.animation == "Explosion":
		last_thrower = null
		is_holded = false
		is_thrown = false
		velocity = Vector2.ZERO
		spawn()
		set_deferred("monitoring", true)
		sprite.play("Off")

func _on_body_entered(body):
	if is_holded:
		return
	if (body.is_in_group("Joueurs")):
		last_thrower = body
		is_holded = true
		sprite.play("On")
		body.pick_object(self)
		if $Chrono.is_stopped():
			$Chrono.start()
