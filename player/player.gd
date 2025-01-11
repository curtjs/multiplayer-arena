extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -200.0

func _enter_tree():
	set_multiplayer_authority(int(str(name)))

func _ready():
	if !is_multiplayer_authority():
		$Sprite2D.modulate = Color.RED

func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
