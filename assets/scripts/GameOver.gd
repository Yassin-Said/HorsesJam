extends Control

@onready var animation_player: AnimationPlayer = $CanvasLayer/GameOverLabel/AnimationPlayer

func _ready():
	pass

func _on_restart_pressed():
	get_tree().change_scene("res://assets/scenes/Level1.tscn")

func _on_quit_pressed():
	get_tree().change_scene("res://assets/scenes/MainMenu.tscn")
	#get_tree().quit()

func play_animation():
	animation_player.play("GameOver")
