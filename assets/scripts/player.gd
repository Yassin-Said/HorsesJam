extends CharacterBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var slide_collision: CollisionShape2D = $SlideCollision
@onready var attack_area: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_sprite: Sprite2D = $Sprite2D
@onready var player_ui: Control = $"../PlayerUi"
@onready var player: Node2D = $".."
@onready var area_2d: Area2D = $Area2D
@onready var game_over: Control = $"../GameOver"
@onready var pause_menu: Control = $"../PauseMenu"
@onready var key_sprite: Sprite2D = $Key
@onready var walking_sfx: AudioStreamPlayer = $"../Walking"
@onready var dash_sfx: AudioStreamPlayer = $"../Dash"

const SPEED = 100.0
const SPEED_IN_JUMP = 70.0
const JUMP_VELOCITY = -200.0

var fliped = false
var jumped_from_wall = false
var jumping = false
var sliding = false
var current_dashing_key = ""
var sliding_speed = 0
var cooldown_wall : float = 0
var is_attacking = false
var key_history = {"move_left": 0, "move_right": 0, "dash": 0}
var dash_direction = Vector2.ZERO
var current_key = ""
var dash_speed = 500.0
var reset_key = 0
var dashing = false
var double_jump = false
var wall_sliding = false
var wall_slide_speed = 40.0
var last_wall_dir = 0
var base_sprite_x = 0.0
var dash_duration = 0.15
var dash_timer = 0.0
var is_alive = true
var is_game_over = false
var has_get_hit = false
var paused = false

func _ready() -> void:
	game_over.connect("on_restart_pressed", on_restart_received)
	game_over.connect("on_quit_pressed", on_quit_received)
	pause_menu.connect("on_resume_pressed", on_resume_received)
	pause_menu.connect("on_quit_pause_pressed", on_quit_pause_received)
	
	base_sprite_x = animation_player.position.x
	animation_player.play("idle")
	Global.player = self

func wall_jump():
	var wall_dir = get_wall_normal().x
	jumped_from_wall = true
	wall_sliding = false
	velocity.x = wall_dir * 100
	velocity.y = -300
	animation_player.play("wall_jump")
	cooldown_wall = 0.1

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

func check_wall_slide(direction):
	wall_sliding = false

	if is_on_wall() and not is_on_floor() and velocity.y > 0:
		var wall_dir = get_wall_normal().x

		if direction == -wall_dir:
			wall_sliding = true
			last_wall_dir = wall_dir
			jumped_from_wall = false
			
			velocity.y = min(velocity.y, wall_slide_speed)
			
			animation_player.play("wall_slide")
			animation_player.flip_h = wall_dir < 0

			if wall_dir < 0:
				animation_player.position.x = base_sprite_x + 3
			else:
				animation_player.position.x = base_sprite_x - 5

	if not wall_sliding:
		animation_player.position.x = base_sprite_x

func check_fall():
	if not is_on_floor() and not jumped_from_wall and not jumping and not is_attacking:
		animation_player.play("fall_loop")

func check_direction(direction: float):
	if direction:
		if not jumped_from_wall and not sliding and not wall_sliding:
			flip_collision(direction)
			if not is_attacking:
				if direction < 0:
					animation_player.flip_h = true
				else:
					animation_player.flip_h = false
		if sliding == true or dashing == true or is_attacking == true:
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
		if not is_on_wall() and not jumped_from_wall:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if jumping == false and not is_attacking and not sliding:
				animation_player.play("idle")

func check_slide(delta):
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
	jumped_from_wall = false
	#if dir == Vector2.UP:
		#dash_timer = dash_duration_up
	#else:
	dash_timer = dash_duration
	dash_direction = dir.normalized()
	dashing = true
	clear_dash()
	player_ui.use_dash()
	dash_sfx.play()

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
	if not is_on_floor() and not is_attacking and player_ui.current_dashes > 0:
		if Input.is_action_just_pressed("slide"):
			if Input.is_action_pressed("move_left"):
				animation_player.play("dash")
				start_dash(Vector2.LEFT)
			elif Input.is_action_pressed("move_right"):
				animation_player.play("dash")
				start_dash(Vector2.RIGHT)
		for key in key_history:
			if Input.is_action_just_pressed(key):
				reset_key = 0.2
				key_history[key] += 1
			if key_history[key] >= 2:
				current_dashing_key = key
				if key == "move_left":
					animation_player.play("dash")
					start_dash(Vector2.LEFT)
				elif key == "move_right":
					animation_player.play("dash")
					start_dash(Vector2.RIGHT)
				elif key == "dash":
					animation_player.play("dash_up")
					start_dash(Vector2.UP)
	else:
		clear_dash()

func _physics_process(delta: float) -> void:
	if player_ui.current_time <= 0 and not is_game_over:
		print("current time = ", player_ui.current_time)
		is_game_over = true
		animation_player.play("death")
	
	if is_game_over:
		return
	
	if Input.is_action_just_pressed("pause"):
		if not paused:
			pause_menu.hide_show(true)
			pause_menu.get_focus()
			paused = true
			player_ui.stop_timer = true
			player_ui.hide_show(false)
			animation_player.pause()
		elif paused:
			pause_menu.hide_show(false)
			paused = false
			player_ui.stop_timer = false
			player_ui.hide_show(true)
			animation_player.play()
	if paused == true:
		return
	if has_get_hit:
		collision_shape_2d.disabled = true
		move_and_slide()
		return
	cooldown_wall -= delta
	var direction := Input.get_axis("move_left", "move_right")
	
	if not is_on_floor():
		velocity += get_gravity() * delta * 0.6
	else:
		jumping= false
		double_jump = false
		jumped_from_wall = false
	if Input.is_action_just_pressed("jump") and not is_attacking:
		if is_on_floor() and not double_jump:
			jumping = true
			velocity.y = JUMP_VELOCITY
			animation_player.play("jump")
		elif wall_sliding:
			wall_jump()
		if not is_on_floor() and not is_on_wall() and not double_jump:
			double_jump = true
			velocity.y = JUMP_VELOCITY
			animation_player.play("jump")
	if animation_player.animation == "walk" and not walking_sfx.playing:
		walking_sfx.play()
	elif animation_player.animation != "walk":
		walking_sfx.stop()
	if is_alive == true:
		attack()
		check_wall_slide(direction)
		check_direction(direction)
		check_fall()
		check_slide(delta)
		check_dash(delta)
		apply_dash(delta)
		move_and_slide()

func attack():
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		if animation_player.flip_h == true:
			attack_area.position.x = -33
		elif animation_player.flip_h == false:
			attack_area.position.x = 33
		animation_player.play("attack")
		attack_area.disabled = false

func hit_stun(skeleton_direction):
	if skeleton_direction == 1:
		velocity.x += 50
	elif skeleton_direction == -1:
		velocity.x -= 50
	animation_player.play("hit")
	player_ui.apply_time_penalty()

func _on_attack_area_body_entered(body: Node2D) -> void:
	body.life -= 1
	if body.life <= 0:
		body.queue_free()

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
	if animation_player.animation == "hit":
		has_get_hit = false
	if animation_player.animation == "death":
		if is_game_over == false:
			global_position = Global.checkpoint_pos
			is_alive = true
			player_ui.stop_timer = false
		else:
			show_game_over()

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("on body entered")
	is_alive = false
	animation_player.play("death")
	player_ui.stop_timer = true
	player_ui.apply_time_penalty()

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("on area entered")
	is_alive = false
	animation_player.play("death")
	player_ui.stop_timer = true
	player_ui.apply_time_penalty()

func show_game_over():
	player_ui.hide_show(false)
	game_over.visible = true
	game_over.show_menu()
	
func show_key():
	key_sprite.visible = true
	key_sprite.modulate.a = 1.0

	var tween := create_tween()

	tween.tween_property(key_sprite, "position:y", key_sprite.position.y - 20, 2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(key_sprite, "modulate:a", 0.0, 0.6)
	tween.tween_callback(key_sprite.queue_free)
	
func on_restart_received():
	get_tree().change_scene_to_file("res://assets/scenes/Level1.tscn")

func on_quit_received():
	get_tree().change_scene_to_file("res://assets/scenes/MainMenu.tscn")

func on_resume_received():
	print("resume")
	pause_menu.hide_show(false)
	paused = false
	player_ui.stop_timer = false
	player_ui.hide_show(true)
	animation_player.play()

func on_quit_pause_received():
	print("quitter")
	get_tree().change_scene_to_file("res://assets/scenes/MainMenu.tscn")
