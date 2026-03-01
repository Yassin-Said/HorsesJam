extends Control

@export var start_time: float = 60.0
@export var low_time_threshold: float = 10.0
@export var hit_time_penalty: float = 5.0

var current_time: float
var is_low_time := false
var penalty_tween: Tween

@export var max_dashes: int = 3
@export var dash_recharge_time: float = 2.0

var current_dashes: int
#var dash_cooldowns: Array[float] = []
var recharge_timer: float = 0.0
var recharge_queue: int = 0

@onready var timer_label: RichTextLabel = $CanvasLayer/Control/TimerLabel
@onready var penalty_label: RichTextLabel = $CanvasLayer/TimePenaltyLabel
@onready var dash_container = $DashContainer
@onready var control: Control = $CanvasLayer/Control

var original_position
var shake_intensity = 1


func _ready():
	original_position = control.position
	current_time = start_time
	current_dashes = max_dashes

	update_timer_display()
	update_dash_display()

func _process(delta):
	update_timer(delta)
	update_dash_recharge(delta)
	if Input.is_action_just_pressed("attack"):
		apply_time_penalty()
	if Input.is_action_just_pressed("jump"):
		use_dash()

func update_timer(delta):
	if current_time <= 0:
		current_time = 0
		return
	
	current_time -= delta
	update_timer_display()
	
	if current_time <= low_time_threshold:
		is_low_time = true
		start_low_time_effect()

func update_timer_display():
	if is_low_time:
		timer_label.text = "[color=red]Time: %.2f[/color]" % current_time
	else:
		timer_label.text = "Time: %.2f" % current_time

func start_low_time_effect():
	control.position = original_position + Vector2(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)

func apply_time_penalty(amount: float = hit_time_penalty):
	current_time -= amount
	if current_time < 0:
		current_time = 0
		update_timer_display()
	show_penalty(amount)

func show_penalty(amount: float):
	if penalty_tween and penalty_tween.is_running():
		penalty_tween.kill()

	penalty_label.visible = true
	penalty_label.modulate = Color.RED
	penalty_label.modulate.a = 1.0
	penalty_label.scale = Vector2.ONE * 1.4
	penalty_label.text = "[tornado radius=10 freq=2]-%.1f s[/tornado]" % amount

	penalty_tween = create_tween()
	penalty_tween.tween_property(penalty_label, "scale", Vector2.ONE, 0.3)
	penalty_tween.tween_interval(0.5)
	penalty_tween.tween_property(penalty_label, "modulate:a", 0.0, 0.3)
	penalty_tween.tween_callback(func(): penalty_label.visible = false)

func use_dash():
	if current_dashes <= 0:
		return

	current_dashes -= 1
	recharge_queue += 1

	if recharge_timer <= 0:
		recharge_timer = dash_recharge_time

	update_dash_display()

func update_dash_recharge(delta):
	if recharge_queue <= 0:
		return

	recharge_timer -= delta

	if recharge_timer <= 0:
		current_dashes += 1
		recharge_queue -= 1

		if recharge_queue > 0:
			recharge_timer = dash_recharge_time
		else:
			recharge_timer = 0

	update_dash_display()

func update_dash_display():
	for i in range(max_dashes):
		var icon = dash_container.get_child(i)
		
		if i < current_dashes:
			icon.modulate = Color(1,1,1,1)
		else:
			icon.modulate = Color(0.3,0.3,0.3,1)
