extends Node2D
const cell_size = 64
var tuiles = preload("res://prefab/tuiles.tscn")
var lbl = preload("res://prefab/lblscore.tscn")
var cols = 0
var rows = 0
var lst_piece = []
onready var Re = $ColorRect

var click1 = Vector2()
var click2 = Vector2()

var score = 0

#export
export (int) var rank_1 = 1000
export (int) var rank_2 = 2000
export (int) var rank_3 = 3000

export (int) var min_score = 1500
export (int) var umaru = 0
export (int) var ika = 0
export (int) var nezuko = 0
export (int) var megumin = 0
export (int) var yui = 0
export (int) var satania = 0
export (int) var kanna = 0
export (int) var hikage = 0

func _ready():
	cols = Re.rect_size.x / cell_size
	rows = Re.rect_size.y / cell_size
	lst_piece = dimension_empty()
	spawn()
	check_star()
	place_couleur()
	number_color()
	$lblminscore.text = "/" + str(min_score)

func _physics_process(delta):
	$lblscore.text = str(score)
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().reload_current_scene()
		
	if Input.is_action_just_pressed(("click")):
		click1 = get_global_mouse_position()
		
	if Input.is_action_just_released("click"):
		click2 = get_global_mouse_position()
		switch(click1, click2)
		
func switch(pos1, pos2):
	if is_on_grid(pos1) and is_on_grid(pos2):
		var grd1 = point_to_grid(pos1)
		var grd2 = point_to_grid(pos2)
		if grd1 == grd2 : return
		var tl1 = lst_piece[grd1.x][grd1.y]
		var tl2 = lst_piece[grd2.x][grd2.y]
		var pix1 = grid_to_point(grd1.x, grd1.y)
		var pix2 = grid_to_point(grd2.x, grd2.y)
		
		if move_test(grd1, grd2) == true:
#			tuile_move(tl1, pix1, tl2, pix2)
			tl1.bouge(pix2)
			tl2.bouge(pix1)
			lst_piece[grd1.x][grd1.y] = tl2
			lst_piece[grd2.x][grd2.y] = tl1
			
			if check_match() == false:
#				tuile_move(tl1, pix2, tl2, pix1)
				tl1.bouge(pix1)
				tl2.bouge(pix2)
				lst_piece[grd1.x][grd1.y] = tl1
				lst_piece[grd2.x][grd2.y] = tl2
			else:
				set_physics_process(false)
				var matching = true
				while matching !=false:
					destroy()
					yield(get_tree().create_timer(0.1), "timeout")
					gravity()
					yield(get_tree().create_timer(0.1), "timeout")
					spawn(true)
					yield(get_tree().create_timer(0.1), "timeout")
					matching = check_match()
					yield(get_tree().create_timer(0.1), "timeout")
				set_physics_process(true)
				
func move_test(gd1, gd2):
	var diff = gd2 - gd1
	if abs(diff.x) > 1 or abs(diff.y) > 1: return false
	if abs(diff.x) > 0 and abs(diff.y) >0: return false
	return true
	
		
		
func tuile_move(pc1, pos1, pc2, pos2):
	$Tween.interpolate_property(pc1, "position", pos1, pos2, 0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT) 
	$Tween.interpolate_property(pc2, "position", pos2, pos1, 0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")

func is_on_grid(point):
	var grid_point = point_to_grid(point)
	if grid_point.x >= 0 and grid_point.x < cols:
		if grid_point.y >= 0 and grid_point.y < rows:
			return true
	
	return false
	
		
func destroy():
	
	for x in cols:
		for y in rows:
			if lst_piece[x][y] != null:
				if lst_piece[x][y].to_kill == true:
					var pos = grid_to_point(x, y)
					var scr = lst_piece[x][y].score * 100
					var monlabel = lbl.instance()
					get_parent().add_child(monlabel)
					monlabel.init(pos, scr)
					score += scr
					check_all(lst_piece[x][y].color)
					lst_piece[x][y].remove()
					lst_piece[x][y] = null

func spawn(refill = false):
	randomize()
	for x in cols:
		for y in rows:
			if lst_piece[x][y] == null:
				var id = floor( rand_range(0,8) )
				var tuile = tuiles.instance()
				var temp_color = tuile.get_color(id)
	#			if check_spawn_match(x , y, temp_color) == true: print("warning")
				if refill == false:
					while(check_spawn_match(x,y, temp_color) == true):
						id = floor( rand_range(0,8) )
						temp_color = tuile.get_color(id)
					
					
				var pos = grid_to_point(x, y)
				add_child(tuile)
				tuile.init(id, pos)
				lst_piece[x][y] = tuile
			
			
func check_spawn_match(col, row, test_color):
	if row > 1:
		var prev1 = lst_piece[col][row - 1]
		var prev2 = lst_piece[col][row - 2]
		if test_color == prev1.color and test_color == prev2.color: return true
		
	if col > 1:
		var prev1 = lst_piece[col - 1][row]
		var prev2 = lst_piece[col - 2][row]
		if test_color == prev1.color and test_color == prev2.color: return true
		
	return false
		
func check_match():
	var ok = 0
	for x in cols:
		for y in rows:
			if y > 1:
				if lst_piece[x][y] != null &&  lst_piece[x][y - 1] != null &&  lst_piece[x][y -2] != null:
					var prev2 = lst_piece[x][y - 2].color
					var prev1 = lst_piece[x][y - 1].color
					var color = lst_piece[x][y].color
					if color == prev1 and color == prev2:
						lst_piece[x][y].kill(3)
						lst_piece[x][y].is_vertical = true
						lst_piece[x][y-1].kill(2)
						lst_piece[x][y].is_vertical = true
						lst_piece[x][y-2].kill(1)
						lst_piece[x][y].is_vertical = true
						ok+=1
						
			if x > 1:
				if lst_piece[x][y] != null &&  lst_piece[x - 1][y] != null &&  lst_piece[x - 2][y] != null:
					var prev2 = lst_piece[x - 2][y].color
					var prev1 = lst_piece[x - 1][y].color
					var color = lst_piece[x][y].color
					if color == prev1 and color == prev2:
						lst_piece[x][y].kill(3)
						lst_piece[x][y].is_horizontal = true
						lst_piece[x-1][y].kill(2)
						lst_piece[x][y].is_horizontal = true
						lst_piece[x-2][y].kill(1)
						lst_piece[x][y].is_horizontal = true
						ok+=1
	return ok!= 0
					
func gravity():
	var y = rows -1
	while y >=1:
		var x = cols -1
		while x >=0:
			if lst_piece[x][y] == null:
				var z = y
				while z >=0:
					if lst_piece[x][z] != null:
						var pos = grid_to_point(x, y)
						lst_piece[x][z].bouge(pos)
						lst_piece[x][y] = lst_piece[x][z]
						lst_piece[x][z] = null
						break
					z-=1
			x-=1
		y-=1

					
func dimension_empty():
	var matrix = []
	for x in cols:
		matrix.append([])
		for y in rows:
			matrix[x].append(null)
	return matrix



func grid_to_point(col, row):
	var x = Re.rect_position.x + (col * cell_size) + (cell_size / 2)
	var y = Re.rect_position.y + (row * cell_size) + (cell_size / 2)
	return Vector2(x, y)


func point_to_grid(point):
	var x = floor( (point.x - Re.rect_position.x ) / cell_size)
	var y = floor( (point.y - Re.rect_position.y ) / cell_size)
	return Vector2(x, y)


func check_star():
	$star1.visible = score >= rank_1
	$star2.visible = score >= rank_2
	$star3.visible = score >= rank_3
	
	
func check_all(couleur):
	check_star()
	
	match couleur:
		"umaru": if umaru != 0 : umaru -=1
		"ika": if ika != 0 : ika -=1
		"nezuko": if nezuko != 0 : nezuko -=1
		"megumin": if megumin != 0 : megumin -=1
		"yui": if yui != 0 : yui -=1
		"satania": if satania != 0 : satania -=1
		"kanna": if kanna != 0 : kanna -=1
		"hikage": if hikage != 0 : hikage -=1
	
	number_color()
		
	if umaru + ika + nezuko + megumin + yui + satania + kanna + hikage == 0 and score >= min_score:
		print("win")
		
		
func place_couleur():
	$panel/umaru.visible = umaru > 0
	$panel/ika.visible = ika > 0
	$panel/nezuko.visible = nezuko > 0
	$panel/megumin.visible = megumin > 0
	$panel/yui.visible = yui > 0
	$panel/satania.visible = satania > 0
	$panel/kanna.visible = kanna > 0
	$panel/hikage.visible = hikage > 0

func number_color():
	$panel/umaru.text = str(umaru) 
	$panel/ika.text = str(ika)
	$panel/nezuko.text = str(nezuko) 
	$panel/megumin.text = str(megumin) 
	$panel/yui.text = str(yui) 
	$panel/satania.text = str(satania) 
	$panel/kanna.text = str(kanna) 
	$panel/hikage.text = str(hikage) 
	
	$panel/umaru.pressed = umaru == 0
	$panel/ika.pressed = ika == 0
	$panel/nezuko.pressed = nezuko == 0
	$panel/megumin.pressed = megumin == 0
	$panel/yui.pressed = yui == 0
	$panel/satania.pressed = satania == 0
	$panel/kanna.pressed = kanna == 0
	$panel/hikage.pressed = hikage == 0
	
	
	
	
	
