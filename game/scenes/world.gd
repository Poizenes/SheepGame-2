extends Node2D

@export var camera: Camera2D

@onready var grass = load("res://entities/grass/grass.tscn")
@onready var sheep = load("res://entities/actor/sheep/sheep.tscn")
@onready var wolf = load("res://entities/actor/wolf/wolf.tscn")

func _input(event: InputEvent) -> void:
	var pos = get_local_mouse_position()
	if event.is_action_pressed("spawn_grass"):
		spawn(grass, pos)
	elif event.is_action_pressed("spawn_sheep"):
		spawn(sheep, pos)
	elif event.is_action_pressed("spawn_wolf"):
		spawn(wolf, pos)
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	elif event.is_action_pressed("zoom_in"):
		if camera.zoom.x <= 4:
			camera.zoom *= 2
	elif event.is_action_pressed("zoom_out"):
		if camera.zoom.x >= 0.25:
			camera.zoom /= 2


func spawn(scene: PackedScene, position: Vector2) -> void:
	var instance: Node2D = scene.instantiate()
	add_child(instance)
	instance.position = position
