extends RigidBody2D

var movement_force_mag = 50000

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
