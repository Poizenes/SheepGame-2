class_name Wolf extends Actor

var attacked_sheep: Sheep

func _ready() -> void:
	action = attack
	super._ready()
	sprite.animation_finished.connect(func():
		if sprite.animation.begins_with("attack"):
			kill(attacked_sheep)
	)
	speed = WALK_SPEED

func _physics_process(delta: float) -> void:
	if IS_PLAYER_CONTROLLED:
		super.handle_input()
	elif action_area.has_overlapping_bodies():
		attack(action_area.get_overlapping_bodies()[0])
	elif is_hungry:
		hunt_for_sheep()
	else:
		stroll()
	velocity = velocity.normalized() * speed
	move_and_slide()

func attack(sheep) -> void:
	velocity = Vector2.ZERO
	sheep.WALK_SPEED = 0
	match sprite.animation:
		"walk_east":
			sprite.play("attack_east")
		"walk_west":
			sprite.play("attack_west")
		_:
			pass
	attacked_sheep = sheep

func kill(sheep: Sheep) -> void:
	sheep.die()
	hunger += FOOD_RESTORE_AMOUNT
	match sprite.animation:
		"attack_east":
			sprite.play("walk_east")
		"attack_west":
			sprite.play("walk_west")
	strolling_target = Vector2(-1, -1)

func hunt_for_sheep() -> void:
	speed = RUN_SPEED
	var sheep = find_nearest("sheep")
	if sheep:
		velocity = action_area.global_position.direction_to(sheep.global_position)
	else:
		stroll()
	

func stroll() -> void:
	speed = WALK_SPEED
	super.stroll()
