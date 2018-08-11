extends RigidBody2D

var movement_force_mag = 50000

func _physics_process(delta):
	applied_force = Vector2()

	var force = Vector2()
	if Input.is_action_pressed('ui_right'):
		force.x += 1
	if Input.is_action_pressed('ui_left'):
		force.x -= 1
	if Input.is_action_pressed('ui_down'):
		force.y += 1
	if Input.is_action_pressed('ui_up'):
		force.y -= 1
	force = force.normalized() * movement_force_mag
	add_force(Vector2(), force)
