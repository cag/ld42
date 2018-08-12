extends Node

var protocat = preload("res://Cat.tscn")
export(NodePath) var entities
export(NodePath) var debug_label
var navpoly
var navbounds
var cat_count = 0
var fullcat = false
var spewcat = false
var spawn_probe_counter = 0
var spawn_probe_timer = 0.0
var spawn_limit_rate = 10

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
	spawn_probe_counter += 1
	if spawn_probe_counter > spawn_limit_rate:
		spewcat = true

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
var til_next_spawn = randf() * 2.0 / spawn_limit_rate
func _physics_process(delta):
	if spewcat:
		cat_timer += delta
		if cat_timer >= til_next_spawn:
			cat_timer -= til_next_spawn
			til_next_spawn = randf() * 2.0 / spawn_limit_rate
			var entnode = get_node(entities)
			var parent = entnode.get_child(randi() % entnode.get_child_count())
			var cat = spawn_cat_at(parent.global_position + 3.0 * Vector2(randf(), randf()))
			cat.get_node("AudioStreamPlayer2D2").play()
	else:
		spawn_probe_timer += delta
		if spawn_probe_timer >= 1.0:
			spawn_probe_timer -= 1.0
			spawn_probe_counter = 0
