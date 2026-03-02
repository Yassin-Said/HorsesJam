extends Node2D

@export var speed : float = 200.0
@export var platform_width_tiles : int = 10
@export var tile_size : int = 16
@onready var saw_sprite: Sprite2D = $SawSprite

var direction := 1
var half_width : float
var left_limit : float
var right_limit : float

var anim_time := 0.0
@export var anim_speed := 0.25

func _ready():
	half_width = (3 * tile_size) / 2.0   # 3 tiles = 48px → 24
	var platform_width_pixels = platform_width_tiles * tile_size

	left_limit = global_position.x
	right_limit = left_limit + platform_width_pixels - half_width * 2
	
	# On décale pour que les limites soient calculées sur le centre
	left_limit += half_width
	right_limit -= 0

func _physics_process(delta):
	anim_time += delta

	if anim_time > anim_speed:
		anim_time = 0
		saw_sprite.flip_h = !saw_sprite.flip_h
	global_position.x += direction * speed * delta

	if global_position.x > right_limit:
		global_position.x = right_limit
		direction = -1
	elif global_position.x < left_limit:
		global_position.x = left_limit
		direction = 1
	
