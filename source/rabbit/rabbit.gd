extends Node2D

signal bit_requested(j)

var BitsSpr = [preload("res://bit/sprites/0.PNG"),
				preload("res://bit/sprites/1.PNG")]
				
var CrosshairSpr = preload("res://system/sprites/crosshair.PNG")

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

onready var Turn = get_parent().get_node("Turn")
onready var Clock = get_parent().get_parent().get_node("Clock")
onready var PowerSource = get_parent().get_node("PowerSource")

onready var J_sprite = $body/head/earl/J2
onready var K_sprite = $body/head/earr/K2

onready var PRE_button_sprite = $body/PRE_button
onready var CLR_button_sprite = $body/CLR_button

onready var display_sprite = $body/display/bit

onready var J_position = $body/head/earl/J.global_position
onready var K_position = $body/head/earr/K.global_position

var turnAnim

func reset():	
	is_enemy = false
	is_my_turn = false
	is_alive = true
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
	
	Turn.rabbits.append(self)
	$aliveAnim.playback_speed = rand_range(0.08, 0.1)

func _process(delta):
	if not has_j:
		J_sprite.texture = null
	if not has_k:
		K_sprite.texture = null	
	if is_alive:
		if is_my_turn:
			if not turnAnim.is_playing():			
				turnAnim.play("modulate")
			$body/turnarrow.show()
		else:		
			turnAnim.stop()
			$body.modulate = Color(color)
			$body/turnarrow.hide()
	else:
		$body/turnarrow.hide()

func connect_clock(clock):
	if not clock.is_connected("tick", self, "_on_Clock_ticked"):
		clock.connect("tick", self, "_on_Clock_ticked")
	
func disconnect_clock(clock):
	if clock.is_connected("tick", self, "_on_Clock_ticked"):
		clock.disconnect("tick", self, "_on_Clock_ticked")

func _on_Clock_ticked():
	tick()
	
func tick():
	randomize()
	if is_alive:
		$tickAnim.play("tick")
		
		if is_my_turn and can_get_bit:
			if rand_range(0, 1) > 0.5:		
				emit_signal("bit_requested", J_position)
			else: 
				emit_signal("bit_requested", K_position)
			can_get_bit = false
		elif not is_my_turn:			
			$aliveAnim.playback_speed = rand_range(0.08, 0.5)
			$aliveAnim.stop()
			$aliveAnim.play("alive")
	else:
		dead()
		
	if has_j and has_k:
		if j == 1 and k == 1:
			if q == 0:
				set_q(1)
			elif q == 1:
				set_q(0)
		elif j == 1 and k == 0:
			set_q(1)
		elif j == 0 and k == 1 :
			set_q(0)

func dead():
	has_j = false
	has_k = false
	J_sprite.texture = null
	K_sprite.texture = null
	$aliveAnim.stop()
	$deadAnim.play("dead")
	disconnect_clock(Clock)

func connect_source(source):
	if not is_connected("bit_requested", source, "_on_bit_requested"):
		connect("bit_requested", source, "_on_bit_requested")
	
func disconnect_source(source):
	if is_connected("bit_requested", source, "_on_bit_requested"):
		disconnect("bit_requested", source, "_on_bit_requested")

func receive_jk(bit):
	if is_alive and is_my_turn:
		$aliveAnim.playback_speed = rand_range(0.2, 0.7)
		$aliveAnim.stop()
		$aliveAnim.play("alive")

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

func set_q(bit):
	q = bit
	display_sprite.texture = BitsSpr[q]

func send_q():
	return q
