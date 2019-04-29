extends Node2D

var speed = 2100
var target = Vector2()
var done_moving = false

onready var Sprite = $Sprite

func _ready():
	speed = rand_range(speed, speed + 500)
	$sparkAnim.playback_speed = rand_range($sparkAnim.playback_speed, $sparkAnim.playback_speed + 20)
	randomize()

func _process(delta):
	move_to(target, delta)			
	
func move_to(pos, delta):
	if global_position.distance_to(pos) > 20:
		var dir = pos - global_position
		global_position += dir.normalized() * speed * delta		
	else:		
		done_moving = true
		queue_free()
