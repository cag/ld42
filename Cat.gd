extends Node2D

var manager
var nav2d
var state = "idle"
var state_time = 0

var idle_duration = 2

var travel_path

func _ready():
	assert(manager)
	nav2d = manager.get_node("Navigation2D")

func change_state(to):
	assert(manager && nav2d)
	state = to
	state_time = 0
	match to:
		"traveling":
			travel_path = nav2d.get_simple_path(
				global_position,
				manager.rand_pt_in_navpoly()
			)
			print(travel_path)
			$AnimatedSprite.animation = "walk"

func _physics_process(delta):
	state_time += delta
	match state:
		"idle":
			if state_time >= idle_duration:
				change_state("traveling")
		"traveling":
			assert(travel_path)
			

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
