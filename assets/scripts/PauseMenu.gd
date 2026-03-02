extends Control

@onready var resume: Button = $CanvasLayer/VBoxContainer/Resume
@onready var quit: Button = $CanvasLayer/VBoxContainer/Quit
@onready var canvas_layer: CanvasLayer = $CanvasLayer

signal on_resume_pressed
signal on_quit_pause_pressed

func _ready():
	pass

func _on_resume_pressed():
	emit_signal("on_resume_pressed")

func _on_quit_pressed():
	emit_signal("on_quit_pause_pressed")


func get_focus():
	resume.grab_focus()

func hide_show(value : bool):
	canvas_layer.visible = value
