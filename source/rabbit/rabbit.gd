extends Node2D

signal bit_requested(j)

var BitsSpr = [preload("res://bit/sprites/0.PNG"),
				preload("res://bit/sprites/1.PNG")]

var SparkScn = preload("res://system/spark.tscn")
var BitScn = preload("res://bit/bit.tscn")

var CrosshairScn = preload("res://system/crosshair.tscn")

var DepressedSpr = preload("res://rabbit/sprites/depressed.PNG")
var PressedSpr = preload("res://rabbit/sprites/pressed.PNG")

export var is_enemy = false
var is_my_turn = false
var is_game_over = false
var is_alive = true
var can_get_bit = true
var battery_bits = 8

const ORI_COLOR = "ffffff"
const ORI_ENEMY_COLOR = "daff03"
var color = ORI_COLOR

var j = 0
var k = 0
var has_j = false
var has_k = false
var pre_bar = 1
var clr_bar = 1
var q = 1

var foe

onready var Turn = get_parent().get_node("Turn")
onready var Clock = get_parent().get_parent().get_node("Clock")
onready var PowerSource = get_parent().get_parent().get_node("PowerSource")

onready var J_sprite = $body/head/earl/J2
onready var K_sprite = $body/head/earr/K2

onready var PRE_button_sprite = $body/PRE_button
onready var CLR_button_sprite = $body/CLR_button

onready var display_sprite = $body/display/bit

onready var J_position = $body/head/earl/J.global_position
onready var K_position = $body/head/earr/K.global_position

onready var weapon = $body/armr/weapon

onready var keys = get_parent().get_node("UI/keys")
onready var arrow_up = get_parent().get_node("UI/keys/arrow_up")
onready var arrow_down = get_parent().get_node("UI/keys/arrow_down")
onready var arrow_left = get_parent().get_node("UI/keys/arrow_left")
onready var arrow_right = get_parent().get_node("UI/keys/arrow_right")
onready var spacebar = get_parent().get_node("UI/keys/spacebar")

var battery_levels

var turnAnim

var attack_targets = []
var current_attack_target_index = 0
var Crosshair

func reset():	
	is_enemy = false
	is_my_turn = false
	is_game_over = false
	is_alive = true
	can_get_bit = true
	battery_bits = 8
	j = 0
	k = 0
	has_j = false
	has_k = false
	pre_bar = 1
	clr_bar = 1
	q = 1
	_ready()

func _ready():
	battery_levels = [ 
		$body/battery/level1,
		$body/battery/level2,
		$body/battery/level3,
		$body/battery/level4,
		$body/battery/level5,
		$body/battery/level6,
		$body/battery/level7,
		$body/battery/level8	
	]
	
	$body/turnarrow.hide()
	
	if is_enemy:
		color = ORI_ENEMY_COLOR
		turnAnim = $turnEnemyAnim
	else:
		color = ORI_COLOR
		turnAnim = $turnAnim
	$body.modulate = Color(color)
		
	connect_clock(Clock)
	connect_source(PowerSource)
	display_sprite.texture = BitsSpr[q]
	$aliveAnim.playback_speed = rand_range(0.08, 0.1)
	
	Turn.rabbits.append(self)
	
	if Crosshair == null:
		Crosshair = CrosshairScn.instance()
		add_child(Crosshair)
		Crosshair.hide()
			
func clear_bits_if_no_j_or_k():
	if not has_j:
		J_sprite.modulate = Color("986767")
	else:
		J_sprite.modulate = Color("ffffff")
	if not has_k:
		K_sprite.modulate = Color("986767")
	else:
		K_sprite.modulate = Color("ffffff")

func consume_battery():
	if battery_bits > 0:
		battery_bits -= 1
		
		for battery in battery_levels:
			if battery_levels.find(battery) == battery_bits:
				battery.hide()
				break
			battery.show()

func _process(delta):			
	if get_parent().get_parent().has_game_started:
		arrow_up.show()
		arrow_down.show()
		arrow_left.show()
		arrow_right.show()
	else:
		arrow_up.hide()
		arrow_down.hide()
		arrow_left.hide()
		arrow_right.hide()
	
	if get_parent().get_parent().is_game_over:
		arrow_up.hide()
		arrow_down.hide()
		arrow_left.hide()
		arrow_right.hide()
	
	if battery_bits <= 0:
		is_alive = false
		set_q(0)
	
	clear_bits_if_no_j_or_k()
	
	if not is_my_turn or is_game_over:
		Crosshair.hide()
		
	if pre_bar == 0:
		PRE_button_sprite.texture = PressedSpr
	elif pre_bar == 1:
		PRE_button_sprite.texture = DepressedSpr
		
	if clr_bar == 0:
		CLR_button_sprite.texture = PressedSpr
	elif clr_bar == 1:
		CLR_button_sprite.texture = DepressedSpr
	
	if is_alive and get_parent().get_parent().has_game_started:
		if is_my_turn:
			if not turnAnim.is_playing():			
				turnAnim.play("modulate")
			$body/turnarrow.show()
			
			if attack_targets.size() > current_attack_target_index and Crosshair.visible:
				Crosshair.global_position = attack_targets[current_attack_target_index]
			
		else:		
			turnAnim.stop()
			$body.modulate = Color(color)
			$body/turnarrow.hide()
	else:
		$body/turnarrow.hide()

func _unhandled_input(event):	
	if not is_enemy:
		if event.is_action_released("ui_select"):	
			spacebar.modulate = Color("ffffff")
		if event.is_action_pressed("ui_select"):
			spacebar.modulate = Color("610054")
		if not is_game_over and get_parent().get_parent().has_game_started:
			if event.is_action_released("ui_left"):
				arrow_left.modulate = Color("ffffff")
			if event.is_action_released("ui_right"):
				arrow_right.modulate = Color("ffffff")
			if event.is_action_released("ui_up"):	
				arrow_up.modulate = Color("ffffff")
			if event.is_action_released("ui_down"):	
				arrow_down.modulate = Color("ffffff")			
			if is_my_turn and not is_enemy:
				if event.is_action_pressed("ui_left"):
					press_pre_bar()
					arrow_left.modulate = Color("610054")
				elif event.is_action_pressed("ui_right"):
					press_clr_bar()
					arrow_right.modulate = Color("610054")
					
			if is_my_turn and not is_enemy and Crosshair.visible:		
				if event.is_action_pressed("ui_down"):			
					arrow_down.modulate = Color("610054")
					if current_attack_target_index > 0:
						current_attack_target_index -= 1
				if event.is_action_pressed("ui_up"):			
					arrow_up.modulate = Color("610054")
					if current_attack_target_index < attack_targets.size() - 1:
						current_attack_target_index += 1
					
				if event.is_action_pressed("ui_select"):
					spacebar.modulate = Color("610054")
					if current_attack_target_index < attack_targets.size():
						shoot(attack_targets[current_attack_target_index])
						Crosshair.hide()
			
		
func shoot(target):	
	$attackAnim.play("attack")
	yield($attackAnim, "animation_finished")
	
	var bit = send_q(target)	
	
	var spark = SparkScn.instance()
	get_parent().add_child(spark)
	spark.global_position = weapon.global_position - Vector2(-20, 400)
	spark.target = target
	spark.Bit.texture = BitsSpr[q]
	
	var spark2 = SparkScn.instance()
#	spark2.speed = spark.speed - 200
	get_parent().add_child(spark2)
	spark2.global_position = weapon.global_position - Vector2(-20, 400)
	spark2.target = target
	
	var spark3 = SparkScn.instance()
#	spark3.speed = spark2.speed - 200
	get_parent().add_child(spark3)
	spark3.global_position = weapon.global_position - Vector2(-20, 400)
	spark3.target = target

	if not bit.is_connected("area_entered", Turn, "end_turn"):
		bit.connect("area_entered", Turn, "end_turn")	

func connect_clock(clock):
	if not clock.is_connected("tick", self, "_on_Clock_ticked"):
		clock.connect("tick", self, "_on_Clock_ticked")
	
func disconnect_clock(clock):
	if clock.is_connected("tick", self, "_on_Clock_ticked"):
		clock.disconnect("tick", self, "_on_Clock_ticked")

func _on_Clock_ticked():	
	randomize()
	if is_alive:
		get_foe()
		$tickAnim.play("tick")
		
		if is_my_turn:
			get_foe_targets()			
		elif can_get_bit:
			if rand_range(0, 1) > 0.5:		
				emit_signal("bit_requested", J_position)
			else: 
				emit_signal("bit_requested", K_position)
			can_get_bit = false
		else:
			$aliveAnim.playback_speed = rand_range(0.08, 0.5)
			$aliveAnim.stop()
			$aliveAnim.play("alive")
	else:
		dead()

	compute_flipflop()

func get_foe():
	for rabbit in Turn.rabbits:
		if is_enemy and not rabbit.is_enemy:
			foe = rabbit
		elif not is_enemy and rabbit.is_enemy:
			foe = rabbit

func get_foe_targets():
	if foe != null:
		var targets = []
		targets.append(PowerSource.global_position)	
		if not foe.has_j:
			targets.append(foe.J_position)
		if not foe.has_k:
			targets.append(foe.K_position)
		attack_targets = targets

func dead():
	has_j = false
	has_k = false
	$aliveAnim.stop()
	$displayAnim.stop()
	$tickAnim.stop()
	$turnAnim.stop()
	disconnect_clock(Clock)
	is_my_turn = false
	is_alive = false
	is_game_over = true
	if not $deadAnim.is_playing():
		$deadAnim.play("dead")
	get_parent().get_parent().game_over_lost()

func connect_source(source):
	if not is_connected("bit_requested", source, "_on_bit_requested"):
		connect("bit_requested", source, "_on_bit_requested")
	
func disconnect_source(source):
	if is_connected("bit_requested", source, "_on_bit_requested"):
		disconnect("bit_requested", source, "_on_bit_requested")

func receive_j(bit):
	j = bit
	J_sprite.texture = BitsSpr[bit]
	$sourceAnim.play("bit")	
	has_j = true
	receive_jk(bit)

func receive_k(bit):
	k = bit
	K_sprite.texture = BitsSpr[bit]
	$sourceAnim.play("bit")	
	has_k = true
	receive_jk(bit)

func receive_jk(bit):
	if not has_j:
		j = 0
	if not has_k:
		k = 0
	if is_alive and is_my_turn:
		$aliveAnim.playback_speed = rand_range(0.5, 1.0)
		$aliveAnim.stop()
		$aliveAnim.play("alive")
	yield(Clock, "tick")
	if foe != null:
		foe.Crosshair.show()
		if foe.is_enemy:
			foe.Crosshair.modulate = Color("66ff07")

func receive_pre_clr(bit):
	if pre_bar == 0 and clr_bar == 0:
		pre_bar = 1
		clr_bar = 1
		
	elif battery_bits > 0:
		consume_battery()
		if pre_bar == 0 and clr_bar == 1:			
			receive_j(1)
			receive_k(0)
		if pre_bar == 1 and clr_bar == 0:			
			receive_j(0)
			receive_k(1)
		has_j = true
		has_k = true
		
#	can_get_bit = true
#	is_my_turn = true
					
	compute_flipflop()	
		
func press_pre_bar():	
	if pre_bar == 1:
		receive_pre_bar(0)
		
func press_clr_bar():
	if clr_bar == 1:
		receive_clr_bar(0)

func receive_pre_bar(bit):
	pre_bar = bit
	receive_pre_clr(pre_bar)
	
func receive_clr_bar(bit):
	clr_bar = bit
	receive_pre_clr(clr_bar)

func compute_flipflop():
	if not is_game_over:
		if j == 1 and k == 1:
			if q == 0:
				set_q(1)
			elif q == 1:
				set_q(0)
		elif j == 1 and k == 0:
			set_q(1)
		elif j == 0 and k == 1 :
			set_q(0)

func set_q(bit):
	q = bit
	display_sprite.texture = BitsSpr[q]

func send_q(target):
	var bit = BitScn.instance()
	add_child(bit)
	bit.global_position = Vector2(target.x, 
								  target.y - 300)
	bit.set_bit(q)
	bit.target = target
	return bit

func _on_J_area_entered(area):
	if area.name.find("Spark") > -1:
		$shockedAnim.play("shocked")

func _on_K_area_entered(area):
	if area.name.find("Spark") > -1:
		$shockedAnim.play("shocked")

func _on_AITimer_timeout():
	if is_enemy and Crosshair.visible:
		if q == 0 and rand_range(0, 100) > 20:
			press_pre_bar()
		if current_attack_target_index < attack_targets.size():
			shoot(attack_targets[current_attack_target_index])
			Crosshair.hide()

func _on_AISelectTargetTimer_timeout():
	if is_enemy and Crosshair.visible:
		if attack_targets.size() > 0:
			current_attack_target_index = randi() % attack_targets.size()

func _on_RestorePRECLRTimer_timeout():	
	pre_bar = 1
	clr_bar = 1
