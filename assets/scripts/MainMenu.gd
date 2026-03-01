extends Node
var lastButton
var lastSubButton
var buttons
var subButtons
var warningActive
@onready var v_box_container_2: VBoxContainer = $CanvasLayer/ColorRect/VBoxContainer2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/ColorRect/VBoxContainer/Play.grab_focus()
	buttons = $CanvasLayer/ColorRect/VBoxContainer.get_children()
	subButtons = $CanvasLayer/ColorRect/VBoxContainer2.get_children()
	warningActive = false
	$CanvasLayer/ColorRect/FadeRect.visible = false
	$AmbienceBGM.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	if v_box_container_2.visible == false:
		v_box_container_2.visible = true
		$AcceptSound.play()
	else:
		v_box_container_2.visible = false
		$CancelSound.play()

func _on_settings_pressed() -> void:
	$AcceptSound.play()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_button_focus_entered():
	lastButton = get_viewport().gui_get_focus_owner()
	var tween = create_tween()
	tween.tween_property(lastButton, "scale", Vector2(1.1, 1.1), 0.1)
	$NavigationSound.play()

func _on_button_focus_exited():
	var tween = create_tween()
	tween.tween_property(lastButton, "scale", Vector2(1, 1), 0.1)

func _on_sub_button_focus_entered():
	lastSubButton = get_viewport().gui_get_focus_owner()
	var tween = create_tween()
	tween.tween_property(lastSubButton, "scale", Vector2(1.1, 1.1), 0.1)
	$NavigationSound.play()

func _on_sub_button_focus_exited():
	var tween = create_tween()
	tween.tween_property(lastSubButton, "scale", Vector2(1, 1), 0.1)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if warningActive:
			return
		$WarningSound.play()
		warningActive = true
		$CanvasLayer/ColorRect/Warning.visible = true
		$CanvasLayer/ColorRect/Warning.modulate.a = 0
		var tween = create_tween()
		tween.tween_property($CanvasLayer/ColorRect/Warning, "modulate:a", 1.0, 0.2)
		await get_tree().create_timer(1.5).timeout
		var tween_out = create_tween()
		tween_out.tween_property($CanvasLayer/ColorRect/Warning, "modulate:a", 0.0, 0.2)
		await tween_out.finished
		$CanvasLayer/ColorRect/Warning.visible = false
		warningActive = false

func _on_level_1_pressed() -> void:
	$CanvasLayer/ColorRect/FadeRect.visible = true
	$LevelStartSound.play()
	await get_tree().create_timer(4.5).timeout

	$AmbienceBGM.stop()
	get_tree().change_scene_to_file("res://assets/scenes/Level1.tscn")


func _on_level_2_pressed() -> void:
	$NavigationSound.play()

func _on_level_3_pressed() -> void:
	$NavigationSound.play()
