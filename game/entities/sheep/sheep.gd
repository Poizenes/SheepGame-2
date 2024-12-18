class_name Sheep extends CharacterBody2D

@export var sprite: AnimatedSprite2D
@export var eat_area: Area2D
@export var hunger_timer: Timer
@export var wait_timer: Timer

@export var IS_PLAYER_CONTROLLED: bool = false
@export_group("Stats")
@export var SPEED: int = 100
@export var FOOD_RESTORE_AMOUNT: int = 5
@export var HUNGER_PER_SECOND: int = 1
@export var MAX_HUNGER: int = 20
@export var STROLLING_DISTANCE: int = 200
@export var WAIT_TIME: float = 0.5

var is_hungry: bool = false
var is_waiting: bool = false

var strolling_target: Vector2 = Vector2(-1, -1)

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
	assert(sprite)
	assert(eat_area)
	assert(hunger_timer)
	assert(wait_timer)
	wait_timer.timeout.connect(func(): is_waiting = false)
	hunger_timer.timeout.connect(func(): hunger -= HUNGER_PER_SECOND)
	hunger_timer.timeout.connect(func():
		if sprite.animation.begins_with("eat"):
			consume()
	)
	hunger_timer.start()

func _process(delta: float) -> void:
	if velocity.x < 0:
		eat_area.scale.x = -1
		sprite.play("walk_west")
	elif velocity.x > 0:
		eat_area.scale.x = 1
		sprite.play("walk_east")
	elif sprite.animation.begins_with("walk"):
		sprite.pause()

func _physics_process(delta: float) -> void:
	if IS_PLAYER_CONTROLLED:
		velocity.x = (int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")))
		velocity.y = (int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up")))
		if Input.is_action_just_pressed("eat") && eat_area.has_overlapping_bodies():
			eat()
	elif hunger <= MAX_HUNGER - FOOD_RESTORE_AMOUNT and eat_area.has_overlapping_bodies():
		eat()
	elif is_hungry:
		search_for_food()
	else:
		stroll()
	
	velocity = velocity.normalized() * SPEED
	move_and_slide()

func eat() -> void:
	velocity = Vector2.ZERO
	match sprite.animation:
		"walk_east":
			sprite.play("eat_east")
		"walk_west":
			sprite.play("eat_west")
		_:
			pass

func consume() -> void:
	if eat_area.get_overlapping_bodies().is_empty():
		return
	var food = eat_area.get_overlapping_bodies()[0]
	food.queue_free()
	hunger += FOOD_RESTORE_AMOUNT
	match sprite.animation:
		"eat_east":
			sprite.play("walk_east")
		"eat_west":
			sprite.play("walk_west")
	strolling_target = Vector2(-1, -1)

func die() -> void:
	print("starved")
	queue_free()

func search_for_food() -> void:
	var food_pos = find_nearest_patch_of_grass()
	if food_pos.x == -1:
		stroll()
	else:
		velocity = eat_area.global_position.direction_to(food_pos)

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

func wait(time: float = WAIT_TIME) -> void:
	is_waiting = true
	wait_timer.stop()
	wait_timer.start(WAIT_TIME)

func find_nearest_patch_of_grass() -> Vector2:
	var grass = get_tree().get_nodes_in_group("grass")
	if grass.is_empty():
		return Vector2(-1, -1)
	var nearest: Vector2 = grass[0].position
	var distance: float = nearest.distance_to(global_position)
	for g in grass:
		if g.global_position.distance_to(global_position) < distance:
			nearest = g.global_position
			distance = nearest.distance_to(global_position)
	return nearest
	
