extends Node2D

signal confirm
signal countdown_finished

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
export(NodePath) var countdown_path
onready var countdown = get_node(countdown_path)
export var countdown_time = 100.0
var countdown_timer = 0.0
export var cat_limit = 200

var level_ended = false
var level_passed = false

func _input(event):
	if event.is_action_pressed("ui_accept"):
		emit_signal("confirm")

func _ready():

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
	cat_manager.fullcat = false
	cat_manager.spawn_cat_somewhere("male")
	cat_manager.fullcat = true
	yield(cat_manager, "spawn")
	hints.visible = false
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	hints.visible = true
	hints.text = "You should probably not let them do that"
	yield(get_tree().create_timer(3.0), "timeout")
	hints.visible = false
	
	yield(get_tree().create_timer(1.0), "timeout")

	cat_manager.fullcat = false
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
	cat_manager.fullcat = true
	yield(get_tree().create_timer(5.0), "timeout")

	cat_manager.fullcat = false
	checker.enter()
	yield(get_tree().create_timer(1.0), "timeout")
	checker.say("oh i found a couple of strays")
	yield(checker, "message_done")
	checker.say("you'll take care of them too, right?")
	yield(checker, "message_done")
	yield(get_tree().create_timer(.5), "timeout")
	cat_manager.spawn_cat_somewhere("male")
	yield(get_tree().create_timer(.5), "timeout")
	cat_manager.spawn_cat_somewhere("female")
	yield(get_tree().create_timer(.5), "timeout")
	checker.exit()
	cat_manager.fullcat = true
	
	countdown_timer = countdown_time
	countdown.text = str(ceil(countdown_timer))
	countdown.visible = true
	yield(self, "countdown_finished")
	countdown.visible = false

	cat_manager.fullcat = false
	var was_spewcat = cat_manager.spewcat
	cat_manager.spewcat = false
	checker.enter()
	if level_passed:
		yield(get_tree().create_timer(1.0), "timeout")
		checker.say("hey, i'm back")
		yield(checker, "message_done")
		yield(get_tree().create_timer(2.0), "timeout")
		if cat_manager.cat_count < 5:
			checker.say("wow, you are a l33t hax0r")
			yield(checker, "message_done")
		elif cat_manager.cat_count == 5:
			checker.say("huh, nothing happened... cool")
			yield(checker, "message_done")
		elif cat_manager.cat_count < 10:
			checker.say("some of our friends might be getting cats soon")
			yield(checker, "message_done")
		elif cat_manager.cat_count < 20:
			checker.say("what the heck dude")
			yield(checker, "message_done")
			checker.say("we don't need more cats")
			yield(checker, "message_done")
		elif cat_manager.cat_count < 40:
			checker.say("are you messing with me???")
			yield(checker, "message_done")
			checker.say("what are we going to do about these cats???")
			yield(checker, "message_done")
		elif cat_manager.cat_count < 80:
			checker.say("...")
			yield(checker, "message_done")
			checker.say("......")
			yield(checker, "message_done")
		elif cat_manager.cat_count < 199:
			checker.say("you're cutting it close")
			yield(checker, "message_done")
			checker.say("you're cutting it very close")
			yield(checker, "message_done")
		else:
			checker.say("¯\\_(ツ)_/¯")
			yield(checker, "message_done")
			
		yield(get_tree().create_timer(1.0), "timeout")
	else:
		checker.say("aw nuts i totally forgot th-WHAT THE DEVIL HAPPENED HERE")
		yield(checker, "message_done")
		checker.say("OUR HOUSE IS RUINED")
		yield(checker, "message_done")
		yield(get_tree().create_timer(1.0), "timeout")
	

	hints.visible = true
	hints.text = "Press space or enter to try again"
	yield(self, "confirm")
	hints.visible = false
	get_tree().change_scene("res://house.tscn")

func _physics_process(delta):
	if !level_ended:
		if cat_manager.cat_count > cat_limit:
			level_ended = true
			emit_signal("countdown_finished")
		elif countdown.visible and countdown_timer >= 0:
			countdown_timer -= delta
			countdown.text = str(ceil(countdown_timer))
			if countdown_timer < 0:
				level_ended = true
				level_passed = true
				emit_signal("countdown_finished")
	
		

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
