extends CharacterBody2D


const GRAVITY = 980.0
var direction: Vector2

@export var speed := 100
@export var health := 100

@onready var player = get_tree().get_first_node_in_group("player")
@onready var mesh_instance_2d: MeshInstance2D = $MeshInstance2D
@onready var top_ray: RayCast2D = $top_ray
@onready var mid_ray: RayCast2D = $mid_ray
@onready var tail_ray: RayCast2D = $tail_ray
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

enum States {
	idle,
	chase,
	tail_attack,
	fire_beam,
	Block,
	fire_projectile,
	death,
}

var current_state = States.idle
var state_timer := 0.0
var decision_interval := 1.0  # seconds between decision updates

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	state_timer += delta
	if state_timer >= decision_interval:
		check_state_transitions()
		state_timer = 0.0
	states_handler(delta)
	print(current_state)


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func check_state_transitions():
	if direction:
		current_state = States.chase
	elif !direction :  current_state = States.idle

func states_handler(delta):
	match current_state:
		States.idle:
			mesh_instance_2d.modulate = Color("white")
			print("idle state")
		States.chase:
			chase(delta)
		States.tail_attack:
			tail_attack()
		States.fire_beam:
			fire_beam()
		States.Block:
			Block()
		States.fire_projectile:
			fire_projectile()
		States.death:
			death()

func chase(delta):
	mesh_instance_2d.modulate = Color("red")
	direction = global_position.direction_to(navigation_agent_2d.get_next_path_position())
	velocity = velocity.lerp(direction * speed, delta)

func tail_attack():
	mesh_instance_2d.modulate = Color("blue")

func fire_beam():
	mesh_instance_2d.modulate = Color("pink")

func Block():
	mesh_instance_2d.modulate = Color("yellow")

func fire_projectile():
	mesh_instance_2d.modulate = Color("green")

func death():
	mesh_instance_2d.modulate = Color("black")

func _on_navigation_timer_timeout() -> void:
	navigation_agent_2d.target_position = player.global_position


'func _on_chase_detect_body_entered(body: Node2D) -> void:
	if body==player:
		current_state = States.chase'
