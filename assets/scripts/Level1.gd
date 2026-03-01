extends Node2D

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
	var new_screen = get_screen_from_position($Player.get_child(0).global_position)
	
	if new_screen != current_screen:
		var previous_screen = current_screen
		current_screen = new_screen
		var idx = _on_player_screen_changed(previous_screen, new_screen)
		camera_next_pos = camera_pos[idx]

	if $Camera2D.global_position != camera_next_pos:
		$Camera2D.global_position = $Camera2D.global_position.lerp(camera_next_pos, 10 * delta)

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
