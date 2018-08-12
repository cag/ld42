extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export(NodePath) var textboxpath
onready var textbox = get_node(textboxpath)

func enter():
	visible = true
	$AudioStreamPlayer2D2.play()

func exit():
	visible = false
	$AudioStreamPlayer2D2.play()

func say(message):
	var label = textbox.get_node("Label")
	label.text = message
	textbox.visible = true
	label.percent_visible = 0.0
	$AudioStreamPlayer2D.play()

var sound_timer = 0.0
var sound_period = 0.15
var message_reveal_speed = 0.5
var confirm_input_speedup_factor = 3.0
func _physics_process(delta):
	if textbox.visible:
		var label = textbox.get_node("Label")
		if label.percent_visible < 1.0:
			if Input.is_action_pressed("ui_accept"):
				sound_timer += delta * confirm_input_speedup_factor
				label.percent_visible += message_reveal_speed * delta * confirm_input_speedup_factor
			else:
				sound_timer += delta
				label.percent_visible += message_reveal_speed * delta
			if sound_timer >= sound_period:
				sound_timer -= sound_period
				$AudioStreamPlayer2D.play()

func _input(event):
	if textbox.visible and event.is_action_pressed("ui_accept") and textbox.get_node("Label").percent_visible >= 1.0:
		textbox.visible = false

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
