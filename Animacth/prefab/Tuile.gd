extends Node2D

var to_kill
var color = ''
var colors = {
	'0' : 'umaru',
	'1' : 'ika',
	'2' : 'nezuko',
	'3' : 'megumin',
	'4' : 'yui',
	'5' : 'satania',
	'6' : 'kanna',
	'7' : 'hikage',
}

var score = 0
var is_horizontal = false
var is_vertical = false

func init(nb, pos):
	$Sprite.frame = nb
	position = pos
	color = colors[str(nb)]
	to_kill = false
	$Tween.interpolate_property(self, "scale", Vector2(0,0), Vector2(1,1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "rotation_degrees", -90, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	
	
func get_color(nb):
	return colors[str(nb)]

func kill(value):
	to_kill = true
	modulate = Color(1,1,1,0.5)
	score += value
	
func bouge(pos):
	$Tween.interpolate_property(self, "position", position, pos, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT_IN)
	$Tween.start()
	yield ($Tween, "tween_completed")

func remove():
	$Tween.interpolate_property(self, "scale", Vector2(1,1), Vector2(0,0), 0.1, Tween.TRANS_SINE, Tween.EASE_OUT_IN)
	$Tween.start()
	yield ($Tween, "tween_completed")
	queue_free()
