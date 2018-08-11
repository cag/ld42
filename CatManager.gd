extends Node

var protocat = preload("res://Cat.tscn")
var navpoly
var navbounds

func calc_bounds(vertices):
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF

	for v in vertices:
		min_x = min(min_x, v.x)
		min_y = min(min_y, v.y)
		max_x = max(max_x, v.x)
		max_y = max(max_y, v.y)

	return PoolVector2Array([
		Vector2(min_x, min_y),
		Vector2(max_x, max_y),
	])

func rand_pt_in_navpoly():
	assert(navbounds && navpoly)
	var minv = navbounds[0]
	var maxv = navbounds[1]
	var w = maxv.x - minv.x
	var h = maxv.y - minv.y
	while true:
		var pt = Vector2(randf() * w, randf() * h)
		if pt == $Navigation2D.get_closest_point(pt):
			# point is in the navigation polygon
			return pt

func spawn_cat_somewhere():
	var cat = protocat.instance()
	cat.global_position = rand_pt_in_navpoly()
	cat.manager = self
	if randf() < 0.5:
		cat.gender = "male"
	else:
		cat.gender = "female"
	add_child(cat)

func _ready():
	navpoly = $Navigation2D/NavigationPolygonInstance.navpoly
	navbounds = calc_bounds(self.navpoly.get_vertices())
	for i in range(1):
		spawn_cat_somewhere()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
