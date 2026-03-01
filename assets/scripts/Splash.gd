extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Background/VideoStreamPlayer.autoplay = true
	$SplashSound.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event.is_pressed():
		get_tree().change_scene_to_file("res://assets/scenes/MainMenu.tscn")


func _on_splash_sound_finished() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/MainMenu.tscn")
