extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var attack_area: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

const SPEED = 100.0
const SPEED_IN_JUMP = 10.0
const JUMP_VELOCITY = -200.0

var land_on_wall = false
var jumped_from_wall = false
var jumping = false
var sliding = false
var current_dashing_key = ""
var sliding_speed = 0
var holding = false
var cooldown_wall : float = 0
var is_attacking = false
var key_history = {"move_left": 0, "move_right": 0, "jump": 0}
var dash_direction = Vector2.ZERO
var current_key = ""
var dash_speed = 500.0
var dash_duration = 0.05
var dash_timer = 0.0
var reset_key = 0
var dashing = false

func _ready() -> void:
	animated_sprite_2d.play("idle")

func jump_from_wall():
	if holding:
		cooldown_wall = 0.5
		velocity = Vector2(100 * get_wall_normal().x, -300)
		holding = false
		jumped_from_wall = true
		animated_sprite_2d.play("wall_jump")

func check_wall_collision(delta: float, direction: float):
	if direction:
		if is_on_wall() and not is_on_floor() and cooldown_wall <= 0:
			if (is_on_wall() and get_wall_normal().x > 0 and direction < 0) or (is_on_wall() and get_wall_normal().x < 0 and direction > 0):
				holding = true
				jumping = false
			else:
				return
			jumped_from_wall = false
			if not land_on_wall:
				velocity.y = 0
				land_on_wall = true
			velocity.y += 200 * delta
			animated_sprite_2d.play("wall_slide")
			if get_wall_normal().x < 0:
				animated_sprite_2d.flip_h = true
			else:
				animated_sprite_2d.flip_h = false
		else:
			land_on_wall = false

func check_fall():
	if not is_on_floor() and not holding and not jumped_from_wall and not jumping:
		animated_sprite_2d.play("fall_loop")

func check_direction(direction: float, delta: float):
	if direction:
		if not holding and not jumped_from_wall and not sliding:
			if direction < 0 :
				animated_sprite_2d.flip_h = true
			else:
				animated_sprite_2d.flip_h = false
		if holding == true or sliding == true or dashing == true:
			return
		if direction < 0 and is_on_floor():
			if not jumping:
				animated_sprite_2d.play("walk")
		elif is_on_floor():
			if not jumping:
				animated_sprite_2d.play("walk")
		if not jumped_from_wall:
			velocity.x = direction * SPEED
		#else:
			#velocity.x = direction * SPEED_IN_JUMP
	else:
		holding = false
		if not is_on_wall() and not jumped_from_wall:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if jumping == false and not is_attacking and not sliding:
				animated_sprite_2d.play("idle")
				animation_player.play("idle")

func check_slide(direction, delta):
	if is_on_floor() and not sliding:
		if Input.is_action_just_pressed("slide"):
			sliding_speed = 200
			sliding = true
			animated_sprite_2d.play("slide")
	if sliding_speed > 100:
		var way = 1
		if animated_sprite_2d.flip_h == true:
			way = -1
		sliding_speed -= 200 * delta
		velocity = Vector2(sliding_speed * way, 0)
	else:
		sliding_speed = 0
		sliding = false

func clear_dash():
	for key in key_history:
		key_history[key] = 0

func start_dash(dir: Vector2):
	holding = false
	jumped_from_wall = false
	dash_direction = dir.normalized()
	dash_timer = dash_duration
	dashing = true

func apply_dash(delta):
	if dashing:
		dash_timer -= delta
		
		if current_dashing_key == "jump":
			velocity = dash_direction * 250
		else:
			velocity = dash_direction * dash_speed
		if dash_timer <= 0:
			dashing = false

func check_dash(delta):
	reset_key -= delta
	if reset_key <= 0:
		clear_dash()
	if not is_on_floor() and not holding:
		for key in key_history:
			if Input.is_action_just_pressed(key):
				reset_key = 0.2
				key_history[key] += 1
			if key_history[key] >= 2:
				current_dashing_key = key
				if key == "move_left":
					start_dash(Vector2.LEFT)
				if key == "move_right":
					start_dash(Vector2.RIGHT)
				if key == "jump":
					start_dash(Vector2.UP)
				dashing = true
				clear_dash()
	else:
		clear_dash()
		
func _physics_process(delta: float) -> void:
	cooldown_wall -= delta
	var direction := Input.get_axis("move_left", "move_right")
	
	if not is_on_floor():
		if not holding:
			velocity += get_gravity() * delta * 0.6
	else:
		jumping= false
		holding = false
		jumped_from_wall = false
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jumping = true
			velocity.y = JUMP_VELOCITY
			animated_sprite_2d.play("jump")
		elif not is_on_floor() and is_on_wall():
			jump_from_wall()
	attack()
	check_wall_collision(delta, direction)
	check_direction(direction, delta)
	check_fall()
	check_slide(direction, delta)
	check_dash(delta)
	apply_dash(delta)
	move_and_slide()

func attack():
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction < 0:
			animated_sprite_2d.flip_h = true
			attack_area.position.x = -33
		elif direction > 0:
			animated_sprite_2d.flip_h = false
			attack_area.position.x = 33
		animated_sprite_2d.play("attack")
		attack_area.disabled = false

func _on_attack_area_body_entered(body: Node2D) -> void:
	print("you hit something")
	#if body.is_in_group("Enemies"):
		#body.take_damage()
	pass # Replace with function body.

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "fall" or animated_sprite_2d.animation == "jump" or animated_sprite_2d.animation == "wall_jump":
		animated_sprite_2d.play("fall_loop")
	if animated_sprite_2d.animation == "attack":
		is_attacking = false
		collision_shape_2d.disabled = true
	
