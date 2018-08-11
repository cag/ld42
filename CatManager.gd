extends Node

# class member variables go here, for example:
var protocat = preload("res://Cat.tscn")
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	var cat = protocat.instance()
	add_child(cat)
	print(cat)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
