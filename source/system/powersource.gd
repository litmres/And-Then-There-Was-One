extends Area2D

var SparkScn = preload("res://system/spark.tscn")
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
	bit.global_position = Vector2(target.x, 
							  target.y - 300)
	bit.set_bit(mode)
	bit.target = target
	
	var spark = SparkScn.instance()
	get_parent().add_child(spark)
	spark.global_position = global_position
	spark.target = target
	
	var spark2 = SparkScn.instance()
#	spark2.speed = spark.speed - 200
	get_parent().add_child(spark2)
	spark2.global_position = global_position 
	spark2.target = target
	
	var spark3 = SparkScn.instance()
#	spark3.speed = spark2.speed - 200
	get_parent().add_child(spark3)
	spark3.global_position = global_position
	spark3.target = target
	
func resume_idle_anim():
	$bitAnim.play("idle")