extends CharacterBody2D

#@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var slide_collision: CollisionShape2D = $SlideCollision
@onready var attack_area: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_sprite: Sprite2D = $Sprite2D
@onready var player: Node2D = $".."

const SPEED = 100.0
const SPEED_IN_JUMP = 70.0
const JUMP_VELOCITY = -200.0

var fliped = false
var land_on_wall = false
var jumped_from_wall = false
var jumping = false
var sliding = false
var current_dashing_key = ""
var sliding_speed = 0
var holding = false
var cooldown_wall : float = 0
var is_attacking = false
var key_history = {"move_left": 0, "move_right": 0, "dash": 0}
var dash_direction = Vector2.ZERO
var current_key = ""
var dash_speed = 500.0
var dash_duration = 0.15
var dash_timer = 0.0
var reset_key = 0
var dashing = false
var is_alive = true

func _ready() -> void:
	animation_player.play("idle")

func jump_from_wall():
	if holding:
		cooldown_wall = 0.5
		velocity = Vector2(100 * get_wall_normal().x, -300)
		if holding == true:
			reset_player_pos()
		holding = false
		jumped_from_wall = true
		animation_player.play("wall_jump")

func flip_collision(direction):
	if direction > 0:
		if fliped == true:
			attack_area.apply_scale(Vector2(1,1)) 
			collision_shape_2d.apply_scale(Vector2(1,1)) 
			fliped = false
	elif direction < 0:
		if fliped == false:
			attack_area.apply_scale(Vector2(-1,1))
			collision_shape_2d.apply_scale(Vector2(-1,1))
			fliped = true

func reset_player_pos():
	if get_wall_normal().x < 0:
		animation_player.position.x -= 2
	else:
		animation_player.position.x += 5

func check_wall_collision(delta: float, direction: float):
	if direction:
		if is_on_wall() and not is_on_floor() and cooldown_wall <= 0:
			if (is_on_wall() and get_wall_normal().x > 0 and direction < 0) or (is_on_wall() and get_wall_normal().x < 0 and direction > 0):
				if not holding:
					if get_wall_normal().x < 0:
						animation_player.position.x += 2
					else:
						animation_player.position.x -= 5
					holding = true
					jumping = false
			else:
				return
			jumped_from_wall = false
			if not land_on_wall:
				velocity.y = 0
				land_on_wall = true
				
			velocity.y += 200 * delta
			animation_player.play("wall_slide")
			#flip_collision(get_wall_normal().x)
			if get_wall_normal().x < 0:
				#animation_player.position.x = ray_point.x
				animation_player.flip_h = true
			else:
				#animation_player.position.x = ray_point.x
				animation_player.flip_h = false
		else:
			land_on_wall = false

func check_fall():
	if not is_on_floor() and not holding and not jumped_from_wall and not jumping and not is_attacking:
		animation_player.play("fall_loop")

func check_direction(direction: float, delta: float):
	if direction:
		if not holding and not jumped_from_wall and not sliding:
			flip_collision(direction)
			if direction < 0 :
				animation_player.flip_h = true
			else:
				animation_player.flip_h = false
		if holding == true or sliding == true or dashing == true or is_attacking == true:
			return
		if direction < 0 and is_on_floor():
			if not jumping:
				animation_player.play("walk")
		elif is_on_floor():
			if not jumping:
				animation_player.play("walk")
		if not jumped_from_wall:
			if is_on_floor():
				velocity.x = direction * SPEED
			else:
				velocity.x = direction * SPEED_IN_JUMP
	else:
		if holding == true:
			reset_player_pos()
		holding = false
		if not is_on_wall() and not jumped_from_wall:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if jumping == false and not is_attacking and not sliding:
				animation_player.play("idle")

func check_slide(direction, delta):
	if is_on_floor() and not sliding and not is_attacking:
		if Input.is_action_just_pressed("slide"):
			sliding_speed = 200
			sliding = true
			animation_player.play("slide")
			collision_shape_2d.disabled = true
			slide_collision.disabled = false
	if sliding_speed > 100:
		var way = 1
		if animation_player.flip_h == true:
			way = -1
		sliding_speed -= 200 * delta
		velocity = Vector2(sliding_speed * way, 0)
	else:
		sliding_speed = 0
		sliding = false
		collision_shape_2d.disabled = false
		slide_collision.disabled = true

func clear_dash():
	for key in key_history:
		key_history[key] = 0

func start_dash(dir: Vector2):
	if holding == true:
		velocity.x = 0
		reset_player_pos()
	holding = false
	jumped_from_wall = false
	#if dir == Vector2.UP:
		#dash_timer = dash_duration_up
	#else:
	dash_timer = dash_duration
	dash_direction = dir.normalized()
	dashing = true

func apply_dash(delta):
	if dashing:
		dash_timer -= delta
		
		if current_dashing_key == "dash":
			velocity = dash_direction * 500
			if dash_timer < 0.01:
				velocity = dash_direction * 100
		else:
			velocity = dash_direction * dash_speed
		if dash_timer <= 0:
			dashing = false

func check_dash(delta):
	reset_key -= delta
	if reset_key <= 0:
		clear_dash()
	if not is_on_floor() and not holding and not is_attacking:
		for key in key_history:
			if Input.is_action_just_pressed("slide"):
				if Input.is_action_pressed("move_left"):
					animation_player.play("dash")
					start_dash(Vector2.LEFT)
				elif Input.is_action_pressed("move_right"):
					animation_player.play("dash")
					start_dash(Vector2.RIGHT)
			if Input.is_action_just_pressed(key):
				reset_key = 0.2
				key_history[key] += 1
			if key_history[key] >= 2:
				current_dashing_key = key
				if key == "move_left":
					animation_player.play("dash")
					start_dash(Vector2.LEFT)
				if key == "move_right":
					animation_player.play("dash")
					start_dash(Vector2.RIGHT)
				if key == "dash":
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
		if holding == true:
			reset_player_pos()
		holding = false
		jumped_from_wall = false
	if Input.is_action_just_pressed("jump") and not is_attacking:
		if is_on_floor():
			jumping = true
			velocity.y = JUMP_VELOCITY
			animation_player.play("jump")
		elif not is_on_floor() and is_on_wall():
			jump_from_wall()
	if is_alive == true:
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
		if animation_player.flip_h == true:
			attack_area.position.x = -33
		elif animation_player.flip_h == false:
			attack_area.position.x = 33
		animation_player.play("attack")
		attack_area.disabled = false

func _on_attack_area_body_entered(body: Node2D) -> void:
	print("you hit something")
	#if body.is_in_group("Enemies"):
		#body.take_damage()
	pass # Replace with function body.

func _on_animated_sprite_2d_animation_finished() -> void:
	#if animation_player.animation == "dash":
	if animation_player.animation == "fall" or animation_player.animation == "jump" or \
		 animation_player.animation == "wall_jump" or animation_player.animation == "dash":
		animation_player.play("fall_loop")
	if animation_player.animation == "attack":
		is_attacking = false
		attack_area.disabled = true
	if animation_player.animation == "slide":
		attack_area.disabled = false
		slide_collision.disabled = true
	if animation_player.animation == "death":
		global_position = Global.checkpoint_pos
		is_alive = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	is_alive = false
	animation_player.play("death")
