extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var collision_shape_2d: CollisionShape2D = $AttackArea/CollisionShape2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var is_attacking = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_floor() and not is_attacking:
		animated_sprite_2d.play("idle")
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	attack()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func attack():
	if Input.is_action_just_pressed("attack"):
		is_attacking = true
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction != 0:
			animated_sprite_2d.flip_h = direction < 0
		animated_sprite_2d.play("attack")
		collision_shape_2d.disabled = false

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "attack":
		is_attacking = false
		collision_shape_2d.disabled = true

func _on_attack_area_body_entered(body: Node2D) -> void:
	print("you hit something")
	#if body.is_in_group("Enemies"):
		#body.take_damage()
	pass # Replace with function body.
