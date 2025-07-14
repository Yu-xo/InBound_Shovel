extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 980.0
const MIN_JUMP_VELOCITY = -200.0  # for variable jump

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var state: String = "idle"

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_state(delta)
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func handle_state(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	if direction<0.0:
		animated_sprite_2d.flip_h = true
	elif direction>0.0:
		animated_sprite_2d.flip_h = false
	
	# Transition rules
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			state = "jump"
		elif direction != 0:
			state = "run"
		else:
			state = "idle"
	else:
		if velocity.y < 0:
			state = "jump"
		else:
			state = "fall"

	# Execute state behaviors
	match state:
		"idle":
			animated_sprite_2d.play("idle")
			velocity.x = move_toward(velocity.x, 0, SPEED)
		"run":
			animated_sprite_2d.play("run")
			velocity.x = direction * SPEED
		"jump":
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = JUMP_VELOCITY
			animated_sprite_2d.play("jump")
			velocity.x = direction * SPEED
		"fall":
			animated_sprite_2d.play("fall")
			velocity.x = direction * SPEED

	# Variable jump control: shorten the jump if button released early
	if not Input.is_action_pressed("jump") and velocity.y < MIN_JUMP_VELOCITY:
		velocity.y = MIN_JUMP_VELOCITY
