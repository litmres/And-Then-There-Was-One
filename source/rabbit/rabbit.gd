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
var is_alive = true
var can_get_bit = true

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

var turnAnim

var attack_targets = []
var current_attack_target_index = 0
var Crosshair

func reset():	
	is_enemy = false
	is_my_turn = false
	is_alive = true
	can_get_bit = true
	j = 0
	k = 0
	has_j = false
	has_k = false
	pre_bar = 1
	clr_bar = 1
	q = 1
	_ready()

func _ready():
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
		J_sprite.texture = null
	if not has_k:
		K_sprite.texture = null	

func _process(delta):			
	clear_bits_if_no_j_or_k()
	
	if not is_my_turn:
		Crosshair.hide()
	
	if is_alive:
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
	if is_my_turn and not is_enemy and Crosshair.visible:
		if event.is_action_pressed("ui_left"):			
			if current_attack_target_index > 0:
				current_attack_target_index -= 1
		if event.is_action_pressed("ui_right"):			
			if current_attack_target_index < attack_targets.size() - 1:
				current_attack_target_index += 1
		if event.is_action_pressed("ui_select"):
			if current_attack_target_index < attack_targets.size():
				shoot(attack_targets[current_attack_target_index])
				Crosshair.hide()

func shoot(target):	
	var bit = send_q(target)	
	
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
	$deadAnim.play("dead")
	disconnect_clock(Clock)

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
		$aliveAnim.playback_speed = rand_range(0.2, 0.7)
		$aliveAnim.stop()
		$aliveAnim.play("alive")	
	yield(Clock, "tick")
	foe.Crosshair.show()

func receive_pre_clr(bit):
	if pre_bar == 0 and clr_bar == 1:
		set_q(1)
	if pre_bar == 1 and clr_bar == 0:
		set_q(0)

func receive_pre_bar(bit):
	pre_bar = bit
	receive_pre_clr(bit)
	
func receive_clr_bar(bit):
	clr_bar = bit
	receive_pre_clr(bit)

func compute_flipflop():
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
