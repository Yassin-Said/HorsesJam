extends CharacterBody2D
var speed = 10
var gravity = 10
var detectPlayer = false
var player: Node2D = null
var attackCooldown = 3
var playerInRange
var canAttack = true
var is_attacking = false
var target_in_area := false

@onready var attack_area_right: Area2D = $AttackAreaRight

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DetectionArea.body_entered.connect(_on_body_entered)
	$DetectionArea.body_exited.connect(_on_body_exited)
	#$AttackAreaRight.body_entered.connect(_on_attack_entered)
	#$AttackAreaRight.body_exited.connect(_on_attack_entered)
	#$AttackAreaLeft.body_entered.connect(_on_attack_entered)
	#$AttackAreaLeft.body_exited.connect(_on_attack_entered)

func _physics_process(delta: float) -> void:
	var distance = global_position.distance_to($"../Player".get_child(0).global_position)
	
	attack_player()
	
	if is_attacking or distance < 35:
		return
	if velocity.x > 1 or velocity.x < -1:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")

	if !is_on_floor():
		velocity.y += gravity
	if velocity.y > 1000:
		velocity.y = 1000

	if detectPlayer and player:
		var direction = sign(player.global_position.x - global_position.x)
		velocity.x = direction * speed
	else:
		velocity.x = 0
	$AnimatedSprite2D.flip_h = velocity.x < 0

	move_and_slide()

func _process(delta: float) -> void:
	pass

func _on_body_entered(body):
	if body.name == "CharacterBody2D":
		detectPlayer = true
		player = body

func _on_body_exited(body):
	if body.name == "CharacterBody2D":
		detectPlayer = false
		player = null

#func _on_attack_entered(body):
	#if body.name == "TestPlayer":
		#playerInRange = true
#
#func _on_attack_exited(body):
	#if body.name == "TestPlayer":
		#playerInRange = false


func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "attack":
		$AnimatedSprite2D.animation = "idle"
		is_attacking = false

func attack_player():
	if target_in_area:
		if !canAttack:
			return
		canAttack = false
		is_attacking = true
		$AnimatedSprite2D.play("attack")
	
		await get_tree().create_timer(attackCooldown).timeout 
		canAttack = true

func _on_attack_area_right_body_entered(body: Node2D) -> void:
	target_in_area = true

func _on_attack_area_left_body_entered(body: Node2D) -> void:
	target_in_area = true

func _on_attack_area_right_body_exited(body: Node2D) -> void:
	target_in_area = false

func _on_attack_area_left_body_exited(body: Node2D) -> void:
	target_in_area = false
