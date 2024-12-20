class_name Actor extends CharacterBody2D

@export var IS_PLAYER_CONTROLLED: bool = false
@export var action_area: Area2D
@export var sprite: AnimatedSprite2D
@export_group("Stats")
@export_subgroup("Speed")
@export var WALK_SPEED: int = 100
@export var RUN_SPEED: int = 150
@export_subgroup("Hunger")
@export var FOOD_RESTORE_AMOUNT: int = 5
@export var HUNGER_PER_SECOND: int = 1
@export var MAX_HUNGER: int = 20
@export_subgroup("Misc")
@export var WAIT_TIME: float = 0.5
@export var STROLLING_DISTANCE: int = 200

var strolling_target: Vector2 = Vector2(-1, -1)
var is_waiting: bool = false
var action: Callable = func(): pass
var is_hungry: bool = false
var speed: int = WALK_SPEED

@onready var wait_timer: Timer = Timer.new()
@onready var hunger_timer: Timer = Timer.new()
@onready var hunger: int = MAX_HUNGER:
	set(new_hunger):
		if new_hunger >= MAX_HUNGER:
			hunger = MAX_HUNGER
		elif new_hunger <= 0:
			die()
		else:
			hunger = new_hunger
			is_hungry = hunger <= MAX_HUNGER / 2

func _ready() -> void:
	assert(action_area)
	assert(sprite)
	add_child(wait_timer)
	add_child(hunger_timer)
	wait_timer.timeout.connect(func(): is_waiting = false)
	hunger_timer.timeout.connect(func(): hunger -= HUNGER_PER_SECOND)
	hunger_timer.start()

func _physics_process(delta: float) -> void:
	if IS_PLAYER_CONTROLLED:
		handle_input()
	apply_movement()

func _process(delta: float) -> void:
	if velocity.x < 0:
		action_area.scale.x = -1
		sprite.play("walk_west")
	elif velocity.x > 0:
		action_area.scale.x = 1
		sprite.play("walk_east")
	elif sprite.animation.begins_with("walk"):
		sprite.pause()

func handle_input() -> void:
	velocity.x = (int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")))
	velocity.y = (int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up")))
	if Input.is_action_just_pressed("action") && action_area.has_overlapping_bodies():
		action.call(action_area.get_overlapping_bodies()[0])

func apply_movement() -> void:
		velocity = velocity.normalized() * speed
		move_and_slide()

func die() -> void:
	print(self.name, " died.")
	queue_free()

func wait(time: float = WAIT_TIME) -> void:
	is_waiting = true
	wait_timer.stop()
	wait_timer.start(WAIT_TIME)

func stroll() -> void:
	if is_waiting:
		velocity = Vector2.ZERO
		return
	if strolling_target.x >= 0 and global_position.distance_to(strolling_target) > 8:
		velocity = global_position.direction_to(strolling_target)
	else:
		strolling_target.x = randf_range(global_position.x - STROLLING_DISTANCE,
			global_position.x + STROLLING_DISTANCE)
		strolling_target.y = randf_range(global_position.y - STROLLING_DISTANCE, 
			global_position.y + STROLLING_DISTANCE)
		wait()

func find_nearest(group: String) -> Node:
	var nodes = get_tree().get_nodes_in_group(group)
	if nodes.is_empty():
		return null
	var nearest: Node = nodes[0]
	var distance: float = global_position.distance_to(nearest.global_position)
	for node in nodes:
		if global_position.distance_to(node.global_position) < distance:
			nearest = node
			distance = global_position.distance_to(nearest.global_position)
	return nearest
