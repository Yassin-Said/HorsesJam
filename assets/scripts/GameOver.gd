extends Control

@onready var animation_player: AnimationPlayer = $CanvasLayer/GameOverLabel/AnimationPlayer
@onready var restart: Button = $CanvasLayer/VBoxContainer/Restart
@onready var quit: Button = $CanvasLayer/VBoxContainer/Quit

signal on_restart_pressed
signal on_quit_pressed

func _ready():
	pass

func _on_restart_pressed():
	emit_signal("on_restart_pressed")
	#get_tree().change_scene("res://assets/scenes/Level1.tscn")

func _on_quit_pressed():
	emit_signal("on_quit_pressed")
	#get_tree().change_scene("res://assets/scenes/MainMenu.tscn")
	#get_tree().quit()

func show_menu():
	restart.grab_focus()
	animation_player.play("GameOver")
