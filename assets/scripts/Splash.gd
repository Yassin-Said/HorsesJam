extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("splash")
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://assets/scenes/MainMenu.tscn")

func _input(event):
	if event.is_pressed():
		get_tree().change_scene_to_file("res://assets/scenes/MainMenu.tscn")
