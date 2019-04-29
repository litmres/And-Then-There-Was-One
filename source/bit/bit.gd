extends Area2D

var BitsSpr = [preload("res://bit/sprites/0.PNG"),
				preload("res://bit/sprites/1.PNG")]

var bit = 0

var speed = 1200
var target = Vector2()
var done_moving = false

var Rabbit
var recipient

onready var Sprite = $Sprite

func _ready():
	set_bit(0)

func set_bit(value):
	bit = value
	if value != 0:
		bit = 1
	Sprite.texture = BitsSpr[bit]

func _process(delta):
	move_to(target, delta)
	if done_moving && Rabbit != null:
		if recipient == "J":
			Rabbit.receive_j(bit)			
		if recipient == "K":
			Rabbit.receive_k(bit)				
	
func move_to(pos, delta):
	if global_position.distance_to(pos) > 10:
		var dir = pos - global_position
		global_position += dir.normalized() * speed * delta		
	else:
		done_moving = true
		queue_free()

func _on_Bit_area_entered(area):
	recipient = area.name
	if area.name.find("J") > -1 or area.name.find("K") > -1:
		Rabbit = area.get_parent().get_parent().get_parent().get_parent().get_parent()
