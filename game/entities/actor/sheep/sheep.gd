class_name Sheep extends Actor

func _ready() -> void:
	action = eat
	sprite.animation_finished.connect(func():
		if sprite.animation.begins_with("eat"):
			consume()
	)
	super._ready()

func _physics_process(delta: float) -> void:
	if IS_PLAYER_CONTROLLED:
		super.handle_input()
	elif hunger <= MAX_HUNGER - FOOD_RESTORE_AMOUNT and action_area.has_overlapping_bodies():
		eat()
	elif is_hungry:
		search_for_food()
	else:
		stroll()
	
	velocity = velocity.normalized() * WALK_SPEED
	move_and_slide()

func eat(_object = null) -> void:
	velocity = Vector2.ZERO
	match sprite.animation:
		"walk_east":
			sprite.play("eat_east")
		"walk_west":
			sprite.play("eat_west")
		_:
			pass

func consume() -> void:
	if action_area.get_overlapping_bodies().is_empty():
		return
	var food = action_area.get_overlapping_bodies()[0]
	food.queue_free()
	hunger += FOOD_RESTORE_AMOUNT
	match sprite.animation:
		"eat_east":
			sprite.play("walk_east")
		"eat_west":
			sprite.play("walk_west")
	strolling_target = Vector2(-1, -1)

func search_for_food() -> void:
	var food = find_nearest("grass")
	if food:
		velocity = global_position.direction_to(food.global_position)
	else:
		stroll()
	
