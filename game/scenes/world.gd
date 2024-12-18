extends Node2D

@onready var grass_scene = load("res://entities/grass/grass.tscn")
@onready var sheep_scene = load("res://entities/sheep/sheep.tscn")

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
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()
