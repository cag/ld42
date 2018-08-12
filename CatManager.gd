extends Node

var protocat = preload("res://Cat.tscn")
export(NodePath) var entities
export(NodePath) var debug_label
var navpoly
var navbounds
var cat_count = 0
var fullcat = true

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
		var pt = minv + Vector2(randf() * w, randf() * h)
		if pt == $Navigation2D.get_closest_point(pt):
			# point is in the navigation polygon
			return pt

func spawn_cat_at(pos):
	var cat = protocat.instance()
	cat.global_position = pos
	cat.manager = self

	if randf() < 0.5:
		cat.gender = "male"
	else:
		cat.gender = "female"

	cat_count += 1
	if debug_label:
		get_node(debug_label).text = str(cat_count)

	get_node(entities).add_child(cat)
	return cat

func spawn_cat_somewhere():
	return spawn_cat_at(rand_pt_in_navpoly())

func _ready():
	navpoly = $Navigation2D/NavigationPolygonInstance.navpoly
	navbounds = calc_bounds(self.navpoly.get_vertices())

	for i in range(5):
		spawn_cat_somewhere()

var cat_timer = 0.0
var til_next_spawn = randf() * 0.07
func _physics_process(delta):
	if !fullcat:
		cat_timer += delta
		if cat_timer >= til_next_spawn:
			cat_timer -= til_next_spawn
			til_next_spawn = randf() * 0.07
			var cat = spawn_cat_somewhere()
			cat.get_node("AudioStreamPlayer2D2").play()
		
