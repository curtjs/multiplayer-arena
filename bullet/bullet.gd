extends Area2D

var speed = 250

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_body_entered(body):
	if !is_multiplayer_authority():
		return
	
	if body is Player:
		body.take_damage.rpc_id(body.get_multiplayer_authority(), 25)
	
	remove_bullet.rpc()

@rpc("call_local")
func remove_bullet():
	queue_free()
