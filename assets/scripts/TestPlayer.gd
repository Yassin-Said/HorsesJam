extends CharacterBody2D

var speed = 400
var gravity = 10
var jump_force = 500
var boi: Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boi = $"../Camera2D"

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 1000:
			velocity.y = 1000
	if Input.is_action_just_pressed("jump"):
		velocity.y = -jump_force
	var horizontal_direction = Input.get_axis("move_left", "move_right")

	velocity.x = speed * horizontal_direction

	move_and_slide()
