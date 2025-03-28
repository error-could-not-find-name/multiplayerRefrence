
extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var camera_3d: Camera3D = $Camera3D
@onready var multiplayr_sceen: Node3D = $".."
var bulletsShot = 0
const BULLET = preload("res://bullet.tscn")
@onready var gun: MeshInstance3D = $Camera3D/gun


func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())
	
func _ready() -> void:
	if not is_multiplayer_authority():
		return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera_3d.current = true
func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x*0.005)
		camera_3d.rotate_x(-event.relative.y*0.005)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x,deg_to_rad(-90),deg_to_rad(90))
	if Input.is_action_just_pressed("shoot"):
		var bullet = BULLET.instantiate()
		bullet.name = str(multiplayer.get_unique_id()) + "bullet" + str(bulletsShot)
		bulletsShot += 1
		bullet.linear_velocity = (gun.global_basis* Vector3(0,0,-1)) * 50#gun.global_basis.get_euler()*10
		bullet.global_position = gun.global_position
		multiplayr_sceen.add_child(bullet)
		#shoot.rpc()


func _physics_process(delta: float) -> void:
	
	if not is_multiplayer_authority():
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
@rpc("any_peer")
func hit():
	print("respawn ", global_position)
	global_position = Vector3.ZERO
	print("respawned", global_position)
#@rpc
#func shoot():
#	pass
