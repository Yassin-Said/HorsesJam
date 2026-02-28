extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 100.0
const SPEED_IN_JUMP = 10.0
const JUMP_VELOCITY = -200.0
var land_on_wall = false
var jumped_from_wall = false
var jumping = false
var holding = false
var cooldown_wall : float = 0

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

func check_direction(direction: float, delta: float):
	if direction:
		if holding == true:
			return
		if direction < 0 and is_on_floor():
			animated_sprite_2d.flip_h = true
			animated_sprite_2d.play("walk")
		elif is_on_floor():
			animated_sprite_2d.flip_h = false
			animated_sprite_2d.play("walk")
		if not jumped_from_wall:
			velocity.x = direction * SPEED
		#else:
			#velocity.x = direction * SPEED_IN_JUMP
	else:
		holding = false
		if not is_on_wall() and not jumped_from_wall:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if jumping == false:
				animated_sprite_2d.play("idle")

func _physics_process(delta: float) -> void:
	cooldown_wall -= delta
	var direction := Input.get_axis("left", "right")
	
	if not is_on_floor():
		if not holding or not direction:
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
	check_wall_collision(delta, direction)
	check_direction(direction, delta)
	move_and_slide()

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "jump" or animated_sprite_2d.animation == "wall_jump":
		animated_sprite_2d.play("fall_loop")
	
