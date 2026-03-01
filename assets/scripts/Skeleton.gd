extends CharacterBody2D
var speed = 10
var gravity = 10
var detectPlayer = false
var player: Node2D = null
var attackCooldown = 2
var playerInRange
var canAttack = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DetectionArea.body_entered.connect(_on_body_entered)
	$DetectionArea.body_exited.connect(_on_body_exited)
	#$AttackAreaRight.body_entered.connect(_on_attack_entered)
	#$AttackAreaRight.body_exited.connect(_on_attack_entered)
	#$AttackAreaLeft.body_entered.connect(_on_attack_entered)
	#$AttackAreaLeft.body_exited.connect(_on_attack_entered)

func _physics_process(delta: float) -> void:

	if velocity.x > 1 or velocity.x < -1:
		$AnimatedSprite2D.animation = "walk"
	else:
		$AnimatedSprite2D.animation = "idle"

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

func canAttackPlayer():
	var distance = global_position.distance_to($"../Player".get_child(0).global_position)

	print(distance)
	if distance < 200:
		print("I have you know")
		if !canAttack:
			return
		canAttack = false
		print("yah")
		$AnimatedSprite2D.animation = "attack"
		
		await get_tree().create_timer(attackCooldown).timeout 
		canAttack = true





#func _on_attack_entered(body):
	#if body.name == "TestPlayer":
		#playerInRange = true
#
#func _on_attack_exited(body):
	#if body.name == "TestPlayer":
		#playerInRange = false
