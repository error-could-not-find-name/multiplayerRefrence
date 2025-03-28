extends RigidBody3D

var ttl = 10

func _enter_tree() -> void:
	set_multiplayer_authority(str(name.split("bullet")[0]).to_int())
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if not is_multiplayer_authority():
		return
	print("hit")
	#destroySelf.rpc()
	if body is CharacterBody3D:
		print("realHit")
		body.hit.rpc_id(body.get_multiplayer_authority())
	queue_free()
	
func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	ttl -= delta
	if ttl <= 0:
		queue_free()
		#destroySelf.rpc()
		
#@rpc("call_local")
