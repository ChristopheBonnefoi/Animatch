extends Node2D

func init(pos, value):
	position = pos
	$Label.text = str(value)
	$Tween.interpolate_property(self, "position", pos, Vector2(pos.x, pos.y -64), 1, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "scale", Vector2(1,1), Vector2(0,0), 0.1, Tween.TRANS_SINE, Tween.EASE_OUT, 0.8)
	$Tween.start()
	yield($Tween, "tween_completed")
	queue_free()
