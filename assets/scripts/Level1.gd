extends Node2D

@onready var door3_label: Label = $Door3/Label
@onready var door3_key: Sprite2D = $Door3/Sprite2D
@onready var door2_label: Label = $Door2/Label
@onready var door2_key: Sprite2D = $Door2/Sprite2D
@onready var door1_key: Sprite2D = $Door1/Sprite2D
@onready var door_2: CollisionShape2D = $Door2/CollisionShape2D
@onready var door_1: CollisionShape2D = $Door1/CollisionShape2D
@onready var chest_sprite: Sprite2D = $Chest/ChestSprite
@onready var chest_key: Sprite2D = $Chest/Sprite2D
@onready var chest_label: Label = $Chest/Label
@onready var door_sprite: Sprite2D = $Door2/DoorSprite
@onready var door_3_sprite: Sprite2D = $Door3/Door3Sprite

var chest_opened = false
var at_chest = false
var at_door3 = false
var at_door2 = false
var at_door1 = false
var door3_opened = false
var door2_opened = false
var camera_pos: Array[Vector2] = [Vector2(320, 180), Vector2(960, 180), Vector2(534, -166), Vector2(1574, 180), Vector2(1433, -180)]
var camera_next_pos
var camera_prev_pos
var current_screen: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Camera2D.global_position = camera_pos[0]
	$Camera2D.enabled = true
	camera_next_pos = camera_pos[0]
	camera_prev_pos = camera_pos[0]
	current_screen = Vector2i(0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	check_chest()
	check_door3()
	check_door2()
	check_door1()
	var new_screen = get_screen_from_position($Player.get_child(0).global_position)
	
	if new_screen != current_screen:
		var previous_screen = current_screen
		current_screen = new_screen
		var idx = _on_player_screen_changed(previous_screen, new_screen)
		camera_next_pos = camera_pos[idx]

	if $Camera2D.global_position != camera_next_pos:
		$Camera2D.global_position = $Camera2D.global_position.lerp(camera_next_pos, 10 * delta)

func fade_label(label: Label) -> void:
	var copy: Label = label.duplicate()
	copy.visible = true
	copy.global_position = label.global_position
	copy.modulate.a = 1.0
	get_tree().current_scene.add_child(copy)

	var tween := create_tween()

	tween.tween_property(copy, "position:y", copy.position.y - 20, 0.6)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(copy, "modulate:a", 0.0, 0.6)
	tween.tween_callback(copy.queue_free)

func check_chest():
	if at_chest == true:
		if Input.is_action_just_pressed("interact"):
			if chest_opened == false:
				chest_opened = true
				Global.player.show_key()
				chest_sprite.region_rect.position.x += 16
			else:
				fade_label(chest_label)

func check_door3():
	if at_door3 == true:
		if Input.is_action_just_pressed("interact"):
			if chest_opened and not door3_opened:
				door_3_sprite.region_rect.position.x -= 16
				door3_opened = true
				door3_key.visible = false
				Global.player.win_layer.play_end()
			elif not door3_opened:
				fade_label(door3_label)

func check_door2():
	if at_door2 == true:
		if Input.is_action_just_pressed("interact"):
			if not door2_opened:
				fade_label(door2_label)
			else:
				Global.player.global_position = door_1.global_position

func check_door1():
	if at_door1 == true:
		if Input.is_action_just_pressed("interact"):
			Global.player.global_position = door_2.global_position
			if not door2_opened:
				door_sprite.region_rect.position.x -= 16
				door2_opened = true

func get_screen_from_position(pos: Vector2) -> Vector2i:
	var screen_size = get_viewport_rect().size

	screen_size.x = screen_size.x / 3
	screen_size.y = screen_size.y / 3

	return Vector2i(
		floor(pos.x / screen_size.x),
		floor(pos.y / screen_size.y)
	)

func _on_player_screen_changed(old_screen: Vector2i, new_screen: Vector2i) -> int:
	match new_screen:
		Vector2i(0,0):
			return 0
		Vector2i(1, 0):
			return 1
		Vector2i(0, -1):
			return 2
		Vector2i(1, -1):
			return 2
		Vector2i(2, 0):
			return 3
		Vector2i(2, -1):
			return 4
	return 0

func _on_area_2d_body_entered(body: Node2D, source: Area2D) -> void:
	Global.checkpoint_pos = source.get_children()[0].global_position

func _on_door_2_body_entered(body: Node2D) -> void:
	door2_key.visible = true
	at_door2 = true

func _on_door_2_body_exited(body: Node2D) -> void:
	door2_key.visible = false
	at_door2 = false

func _on_door_1_body_entered(body: Node2D) -> void:
	door1_key.visible = true
	at_door1 = true

func _on_door_1_body_exited(body: Node2D) -> void:
	door1_key.visible = false
	at_door1 = false

func _on_door_3_body_entered(body: Node2D) -> void:
	if not door3_opened:
		door3_key.visible = true
		at_door3 = true

func _on_door_3_body_exited(body: Node2D) -> void:
	door3_key.visible = false
	at_door3 = false

func _on_chest_body_entered(body: Node2D) -> void:
	chest_key.visible = true
	at_chest = true

func _on_chest_body_exited(body: Node2D) -> void:
	chest_key.visible = false
	at_chest = false
