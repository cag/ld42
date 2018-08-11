extends RigidBody2D

var movement_force_mag = 50000
var held_obj

func _ready():
	$AnimatedSprite.playing = true

func _physics_process(delta):
	applied_force = Vector2()

	var dir = Vector2()
	if Input.is_action_pressed('ui_right'):
		dir.x += 1
	if Input.is_action_pressed('ui_left'):
		dir.x -= 1
	if Input.is_action_pressed('ui_down'):
		dir.y += 1
	if Input.is_action_pressed('ui_up'):
		dir.y -= 1
	
	if dir != Vector2():
		dir = dir.normalized()
		add_force(Vector2(), dir * movement_force_mag)
		
		$Area2D.position = dir * (
			$CollisionShape2D.shape.radius +
			$Area2D/CollisionShape2D.shape.radius
		)
		
		if $AnimatedSprite.animation == "default":
			$AnimatedSprite.animation = "walk"
			$AudioStreamPlayer.play()
	else:
		if $AnimatedSprite.animation == "walk":
			$AnimatedSprite.animation = "default"


func _on_AnimatedSprite_frame_changed():
	if $AnimatedSprite.animation == "walk":
		if $AnimatedSprite.frame % 2 == 0:
			$AudioStreamPlayer.play()

var bodies = {}

func _input(e):
	if e.is_action_pressed("ui_accept"):
		if !held_obj and !bodies.empty():
			var first_cat_id = bodies.keys()[0]
			var first_cat = bodies[first_cat_id]
			held_obj = first_cat
			first_cat.get_picked_up(self)
			$AudioStreamPlayer2.play()
		elif held_obj:
			held_obj.get_put_down()
			held_obj = null

func _on_Area2D_body_entered(body):
	bodies[body.get_instance_id()] = body

func _on_Area2D_body_exited(body):
	bodies.erase(body.get_instance_id())
