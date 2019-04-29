extends Area2D

var BitScn = preload("res://bit/bit.tscn")

var mode = 0

var target_positions = []

func _ready():
	set_mode(1)

func set_mode(bit):
	mode = bit	
	if bit != 0:
		mode = 1
		$Sprite/SwitchSprite.position.y = -28.629
	else:
		$Sprite/SwitchSprite.position.y = 29.829

func _on_bit_requested(target):
	$bitAnim.play("bit")
	
	randomize()
	
	var bit = BitScn.instance()
	get_parent().add_child(bit)
	bit.position = position
	bit.set_bit(mode)
	bit.target = target
	