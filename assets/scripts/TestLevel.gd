extends Node2D

var camera_pos: Array[Vector2] = [Vector2(960, 540), Vector2(1900, 1300), Vector2(2880, 540), Vector2(1954.0, -535.0)]
var camera_next_pos
var current_screen: Vector2i

func _ready() -> void:
	$Camera2D.global_position = camera_pos[0]
	camera_next_pos = camera_pos[0]
	current_screen = Vector2i(0, 0)

func _process(delta):
	var new_screen = get_screen_from_position($TestPlayer.global_position)
	
	if new_screen != current_screen:
		var previous_screen = current_screen
		current_screen = new_screen
		var idx = _on_player_screen_changed(previous_screen, new_screen)
		camera_next_pos = camera_pos[idx]

	if $Camera2D.global_position != camera_next_pos:
		$Camera2D.global_position = $Camera2D.global_position.lerp(camera_next_pos, 10 * delta)

func get_screen_from_position(pos: Vector2) -> Vector2i:
	var screen_size = get_viewport_rect().size

	return Vector2i(
		floor(pos.x / screen_size.x),
		floor(pos.y / screen_size.y)
	)

func _on_player_screen_changed(old_screen: Vector2i, new_screen: Vector2i) -> int:
	print("Changement d'écran :", old_screen, "→", new_screen)

	match new_screen:
		Vector2i(0,0):
			return 0
		Vector2i(0,1):
			return 1
		Vector2i(1, 0):
			return 2
		Vector2i(0, -1):
			return 3
	return 0
