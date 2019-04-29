extends Area2D

signal bit_consumed

var SparkScn = preload("res://system/spark.tscn")
var BitScn = preload("res://bit/bit.tscn")

var BitPowerScn = preload("res://system/bitpower.tscn")

var bit_count = 16
var mode = 0

var target_positions = []

onready var Rabbit = get_parent().get_node("Battle/Rabbit")
onready var RabbitEnemy = get_parent().get_node("Battle/RabbitEnemy")

func _ready():
	set_mode(1)
		
	var start_y = global_position.y	+ 128 - 20
	var gap = 64
	
	for i in range(128):
		var bpow = add_pow(Vector2(global_position.x, -90 + i * gap))
		bpow.modulate = Color("1b4a52")
	
	for i in range(bit_count):
		var bpow = add_pow(Vector2(global_position.x, start_y + i * gap))
		connect("bit_consumed", bpow, "_on_PowerSource_bit_consumed")

func add_pow(pos):
	var BitPow = BitPowerScn.instance()
	add_child(BitPow)
	BitPow.global_position = pos
	return BitPow

func set_mode(bit):
	mode = bit	
	if bit != 0:
		mode = 1
		$Sprite/SwitchSprite.position.y = -28.629
	else:
		$Sprite/SwitchSprite.position.y = 29.829

func _on_bit_requested(target):
	$RestTo1Timer.stop()
	$RestTo1Timer.start()
	
	if bit_count > 0:
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
		spark.scale *= 0.3
		spark.target = target
		
		var spark2 = SparkScn.instance()
	#	spark2.speed = spark.speed - 200
		get_parent().add_child(spark2)
		spark2.global_position = global_position 
		spark2.scale *= 0.3
		spark2.target = target
		
		var spark3 = SparkScn.instance()
	#	spark3.speed = spark2.speed - 200
		get_parent().add_child(spark3)
		spark3.global_position = global_position
		spark3.scale *= 0.3
		spark3.target = target
		
		emit_signal("bit_consumed")
		bit_count -= 1
	
	else: 
		$bitAnim.stop()
		
		Rabbit.is_my_turn = false
		Rabbit.is_game_over = true
		RabbitEnemy.is_my_turn = false
		RabbitEnemy.is_game_over = true
		
		Rabbit.Turn.disconnect_clock(Rabbit.Clock)
		RabbitEnemy.Turn.disconnect_clock(RabbitEnemy.Clock)
		
		if Rabbit.battery_bits > 0:
			if Rabbit.q == RabbitEnemy.q:
				get_parent().game_over_tied()
			elif Rabbit.q > RabbitEnemy.q:
				RabbitEnemy.dead()
				get_parent().game_over_won()
			else: 
				Rabbit.dead()
				get_parent().game_over_lost()
		else:
			Rabbit.dead()
			get_parent().game_over_lost()

func resume_idle_anim():
	$bitAnim.play("idle")

func _on_PowerSource_area_entered(area):
	if area.name.find("Bit") > -1:
		set_mode(area.bit)

func _on_RestTo1Timer_timeout():
	set_mode(1)
