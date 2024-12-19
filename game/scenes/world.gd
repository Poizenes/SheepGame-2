extends Node2D

@export var camera: Camera2D

@onready var grass_scene = load("res://entities/grass/grass.tscn")
@onready var sheep_scene = load("res://entities/actor/sheep/sheep.tscn")
@onready var wolf_scene = load("res://entities/actor/wolf/wolf.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("spawn_grass"):
		var pos = get_local_mouse_position()
		var grass = grass_scene.instantiate()
		add_child(grass)
		grass.position = pos
	elif event.is_action_pressed("spawn_sheep"):
		var pos = get_local_mouse_position()
		var sheep = sheep_scene.instantiate()
		add_child(sheep)
		sheep.position = pos
	elif event.is_action_pressed("spawn_wolf"):
		var pos = get_local_mouse_position()
		var wolf = wolf_scene.instantiate()
		add_child(wolf)
		wolf.position = pos
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	elif event.is_action_pressed("zoom_in"):
		if camera.zoom.x <= 4:
			camera.zoom *= 2
	elif event.is_action_pressed("zoom_out"):
		if camera.zoom.x >= 0.25:
			camera.zoom /= 2
