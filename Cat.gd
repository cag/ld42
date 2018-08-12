extends RigidBody2D

var manager
var nav2d

var last_global_position
var final_collider_radius = 7.0

var default_mass
var default_collision_layer
var default_collision_mask

var state = "idle"
var state_time = 0

var spawn_timer
var spawn_duration = 10.0

var idle_duration

var travel_path
var travel_path_idx
var travel_force_mag
var final_travel_force_mag = 3200

var gender

var holder

func _ready():
	assert(manager)

	$AnimatedSprite.playing = true
	$CollisionShape2D.shape = CircleShape2D.new()
	$CollisionShape2D.shape.radius = 0.5 * final_collider_radius

	default_mass = mass
	default_collision_layer = collision_layer
	default_collision_mask = collision_mask

	nav2d = manager.get_node("Navigation2D")

	spawn_timer = spawn_duration

	change_state([["idle"]])

var checkin = false

func change_state(to_prob_map):
	assert(manager && nav2d && gender)

	var picker = randf()
	var probacc = 0.0
	var to
	for info in to_prob_map:
		to = info[0]
		if info.size() > 1:
			probacc += info[1]
			if picker < probacc:
				break
	state = to
	state_time = 0.0

	collision_layer = default_collision_layer
	collision_mask = default_collision_mask
	match to:
		"idle":
			$AnimatedSprite.animation = "default"
			idle_duration = 1.0 + 3.0 * randf()

		"traveling":
			travel_path = nav2d.get_simple_path(
				global_position,
				manager.rand_pt_in_navpoly()
			)
			$AnimatedSprite.animation = "walk"
			travel_path_idx = 0

		"pickedup":
			$AnimatedSprite.animation = "default"
			collision_layer = 0
			collision_mask = 0

func _physics_process(delta):
	state_time += delta
	last_global_position = global_position
	applied_force = Vector2()

	if spawn_timer > 0.0:
		spawn_timer = max(spawn_timer - delta, 0.0)
		var t1 = spawn_timer / spawn_duration

		var t2 = 1.0 - t1
		t2 *= t2
		t2 *= t2
		t2 *= t2
		t2 *= t2
		t2 *= t2
		t2 = 0.5 + 0.5 * t2

		$CollisionShape2D.shape.radius = final_collider_radius * t2
		$AnimatedSprite.scale = Vector2(t2, t2)
		mass = default_mass * t2
		travel_force_mag = final_travel_force_mag * (0.5 + 0.5 * t2)

		match gender:
			"male":
				$AnimatedSprite.modulate = Color(0x42abc7ff).linear_interpolate(Color(0xffffffff), t1)
			"female":
				$AnimatedSprite.modulate = Color(0xf1707dff).linear_interpolate(Color(0xffffffff), t1)

		

	if state != "pickedup":
		$AnimatedSprite.position.y = min(
			$AnimatedSprite.position.y + 16 * delta, 0)
	else:
		$AnimatedSprite.position.y = max(
			$AnimatedSprite.position.y - 16 * delta, -8)

	match state:
		"idle":
			if state_time >= idle_duration:
				change_state([
					["traveling", 0.5],
					["idle"]
				])

		"traveling":
			assert(travel_path)
			if travel_path_idx >= travel_path.size() - 1:
				change_state([
					["traveling", 0.1],
					["idle"]
				])
			else:
				var nextpos = travel_path[travel_path_idx + 1]
				var force = (nextpos - global_position).normalized() * travel_force_mag
				$AnimatedSprite.flip_h = force.x < 0.0
				add_force(Vector2(), force)

		"pickedup":
			assert(holder)
			add_force(Vector2(), 1000.0 * (holder.get_node("Area2D").global_position - global_position))

func _integrate_forces(pstate):
	match state:
		"traveling":
			var nextpos = travel_path[travel_path_idx + 1]
			if (nextpos - global_position).dot(nextpos - last_global_position) <= 0.0:
				travel_path_idx += 1

func _on_AnimatedSprite_frame_changed():
	match state:
		"traveling":
			if $AnimatedSprite.frame == 1:
				$AudioStreamPlayer2D.play()

func get_picked_up(_holder):
	holder = _holder
	change_state([["pickedup"]])

func get_put_down():
	holder = null
	change_state([["idle", 0.5], ["traveling"]])

func _on_Cat_body_entered(body):
	if (
		state != "pickedup" and
		self.get_instance_id() < body.get_instance_id() and
		get_script() == body.get_script()
	):
		change_state([["idle"]])
		body.change_state([["idle"]])
		if (
			gender != body.gender and
			spawn_timer <= 0 and body.spawn_timer <= 0
		):
			var contact_pos = 0.5 * (body.global_position + global_position)
			var contact_normal = (body.global_position - global_position).normalized()
			apply_impulse(Vector2(), -1000.0 * contact_normal)
			body.apply_impulse(Vector2(), 1000.0 * contact_normal)
			manager.spawn_cat_at(contact_pos)
			$AudioStreamPlayer2D2.play()
