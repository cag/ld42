extends RigidBody2D

var manager
var nav2d

var last_global_position
var default_collision_layer
var default_collision_mask

var state = "idle"
var state_time = 0

var idle_duration

var travel_path
var travel_path_idx
var travel_force_mag = 3200

var gender

var holder

func _ready():
	assert(manager && gender)

	$AnimatedSprite.playing = true
	default_collision_layer = collision_layer
	default_collision_mask = collision_mask

	nav2d = manager.get_node("Navigation2D")

	match gender:
		"male":
			$AnimatedSprite.modulate = Color(0x42abc7ff)
		"female":
			$AnimatedSprite.modulate = Color(0xf1707dff)

	change_state([["idle"]])

var checkin = false

func change_state(to_prob_map):
	assert(manager && nav2d)

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