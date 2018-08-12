extends Node2D

signal confirm

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export(NodePath) var hints_path
onready var hints = get_node(hints_path)
export(NodePath) var checker_path
onready var checker = get_node(checker_path)
export(NodePath) var person_path
onready var person = get_node(person_path)
export(NodePath) var cat_manager_path
onready var cat_manager = get_node(cat_manager_path)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		emit_signal("confirm")

func _ready():
	hints.visible = true
	hints.text = "Use space or enter to make stuff go"
	yield(get_tree().create_timer(1.0), "timeout")
	yield(self, "confirm")
	hints.visible = false

	yield(get_tree().create_timer(1.0), "timeout")
	
	hints.visible = true
	hints.text = "Use WASD or arrow keys to move"
	yield(get_tree().create_timer(1.0), "timeout")
	yield(person, "moving")
	hints.visible = false

	yield(get_tree().create_timer(1.0), "timeout")

	hints.visible = true
	cat_manager.spawn_cat_somewhere("female")
	hints.text = "Use space or enter to pick up a cat"
	yield(get_tree().create_timer(1.0), "timeout")
	cat_manager.fullcat = true
	yield(person, "pickup")

	hints.text = "Use space or enter again to put down a cat"
	yield(person, "putdown")
	hints.visible = false

	hints.visible = true
	hints.text = "Cats can reproduce when an adult male bumps into an adult female"
	yield(get_tree().create_timer(1.0), "timeout")
	cat_manager.spawn_cat_somewhere("male")
	yield(cat_manager, "spawn")
	hints.visible = false
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	hints.visible = true
	hints.text = "You should probably not let them do that"
	yield(get_tree().create_timer(1.0), "timeout")
	yield(self, "confirm")
	hints.visible = false
	
	yield(get_tree().create_timer(1.0), "timeout")

	checker.enter()
	yield(get_tree().create_timer(1.0), "timeout")
	checker.say("hey, roomie, what's up")
	yield(checker, "message_done")
	checker.say("i gotta go do laundry, but i'll be back real soon")
	yield(checker, "message_done")
	checker.say("don't let the cats destroy the house okay")
	yield(checker, "message_done")
	checker.say("that would really suck and drive rent up")
	yield(checker, "message_done")
	yield(get_tree().create_timer(.5), "timeout")
	checker.exit()
	yield(get_tree().create_timer(1.0), "timeout")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass