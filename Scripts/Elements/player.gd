extends CharacterBody2D
class_name Player

var SPEED = 400.0
var fall_scan = false
var accel = 0.5
var falling = true
var jumping = false
var prev_dir = 1
var double_jump = false
var JUMP_VELOCITY = -600.0

func grav(velocity: Vector2):
	if velocity.y < 0:
		return get_gravity().y
	else:
		if is_on_wall():
			return 100
		return 1200

func _physics_process(delta: float) -> void:
	if not is_on_floor() and fall_scan:
		$falling.start(0.5)
		fall_scan = false
	
	if is_on_floor() and falling:
		double_jump = false
		#$land.emitting = true
		#$fall.pitch_scale = randf_range(0.95,1.05)
		#$fall.play()
		fall_scan = true
		#$"../CanvasLayer/ColorRect".shake(0.05)
		falling = false
		var tween = create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property($Sprite2D,"scale",Vector2(2,0.5),0.1)
		tween.set_parallel(true)
		tween.tween_property($Sprite2D,"position:y",10,0.1)
		tween.set_parallel(false)
		tween.tween_property($Sprite2D,"scale",Vector2(1,1),0.1)
		tween.set_parallel(true)
		tween.tween_property($Sprite2D,"position:y",0,0.1)
		
	var tween = create_tween().set_parallel()
	#if abs(velocity.x) > 0 and is_on_floor():
		#var tweener = create_tween()
		#tweener.tween_property($running,"volume_db",0,0.5)
	#else:
		#var tweener = create_tween()
		#tweener.tween_property($running,"volume_db",-80,0.5)
	if velocity.x > 0:
		#$CPUParticles2D.emitting = true
		tween.tween_property($Sprite2D,"rotation_degrees",-10,0.1)
		tween.tween_property($Camera2D,"offset:x",70,0.5)
	elif velocity.x < 0:
		#$CPUParticles2D.emitting = true
		tween.tween_property($Sprite2D,"rotation_degrees",10,0.1)
		tween.tween_property($Camera2D,"offset:x",-70,0.5)
	else:
		#$CPUParticles2D.emitting = false
		tween.tween_property($Sprite2D,"rotation_degrees",0,0.1)
		tween.tween_property($Camera2D,"offset:x",0,1.5)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += grav(velocity) * delta
		
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = JUMP_VELOCITY/4
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_wall():
			jump(true)
		if is_on_floor():
			jump()
		else:
			if not double_jump:
				double_jump = true
				jump()
			$jump_buffer.start(0.2)
	
	if prev_dir == 1:
		$Sprite2D.flip_h = false
	else:
		$Sprite2D.flip_h = true
	if is_on_floor() and $jump_buffer.time_left > 0:
		jump()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		if accel < 1:
			accel += 0.1
		velocity.x = direction * SPEED * accel
		prev_dir = direction
	else:
		accel = 0.5
		velocity.x = move_toward(velocity.x, 0, 21)
	move_and_slide()

func jump(away = false):
	if not jumping:
		jumping = true
		#$jump.pitch_scale = randf_range(0.95,1.05)
		#$jump.play()
		#if velocity.x < 0:
			#var tweener = create_tween()
			#tweener.tween_property($Sprite2D,"rotation_degrees",$Sprite2D.rotation_degrees - 90,0.1)
		#else:
			#var tweener = ceate_tween()
			#tweener.tween_property($Sprite2D,"rotation_degrees",$Sprite2D.rotation_degrees + 90,0.1)
		var tween = create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property($Sprite2D,"scale",Vector2(0.5,2),0.2)
		tween.tween_property($Sprite2D,"scale",Vector2(1,1),0.1)
		if away:
			velocity.x = 300 * prev_dir * -1
		velocity.y = JUMP_VELOCITY
		await get_tree().create_timer(0.25).timeout
		jumping = false


func _on_falling_timeout() -> void:
	if not is_on_floor():
		falling = true
	else:
		fall_scan = false
	
