extends RigidBody2D

var manager
var nav2d
var state = "idle"
var state_time = 0

var idle_duration

var travel_path
var travel_path_idx
var travel_force_mag = 32

var gender

func _ready():
	assert(manager && gender)
	nav2d = manager.get_node("Navigation2D")

	match gender:
		"male":
			$AnimatedSprite.modulate = Color(0x42abc7ff)
		"female":
			$AnimatedSprite.modulate = Color(0xf1707dff)

	change_state("idle")

func change_state(to):
	assert(manager && nav2d)
	state = to
	state_time = 0
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

func _integrate_forces(pstate):
	match state:
		"traveling":
			pass
#			if (nextpos - global_position).dot(force) <= 0.0:
#				travel_path_idx += 1

func _physics_process(delta):
	state_time += delta
	match state:
		"idle":
			if state_time >= idle_duration:
				change_state("traveling")

		"traveling":
			assert(travel_path)
			if travel_path_idx >= travel_path.size() - 1:
				change_state("idle")
			else:
				var nextpos = travel_path[travel_path_idx + 1]
				var force = (nextpos - global_position).normalized() * travel_force_mag
				$AnimatedSprite.flip_h = force.x < 0.0
				add_force(Vector2(0, 0), force)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
