extends Node2D

signal bit_requested(j)

var BitsSpr = [preload("res://bit/sprites/0.PNG"),
				preload("res://bit/sprites/1.PNG")]

var DepressedSpr = preload("res://rabbit/sprites/depressed.PNG")
var PressedSpr = preload("res://rabbit/sprites/pressed.PNG")

var is_enemy = false
var is_my_turn = false

var j = 0
var k = 0
var pre_bar = 1
var clr_bar = 1
var q = 1

onready var Clock = get_parent().get_parent().get_node("Clock")
onready var PowerSource = get_parent().get_node("PowerSource")

onready var J_sprite = $body/head/earl/J2
onready var K_sprite = $body/head/earr/K2

onready var PRE_button_sprite = $body/PRE_button
onready var CLR_button_sprite = $body/CLR_button

onready var display_sprite = $body/display/bit

onready var J_position = $body/head/earl/J.global_position
onready var K_position = $body/head/earr/K.global_position

func _ready():
	connect_clock(Clock)
	connect_source(PowerSource)
	display_sprite.texture = BitsSpr[q]

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
	if rand_range(0, 1) > 0.5:		
		emit_signal("bit_requested", J_position) # ASK FOR A BIT
	else: 
		emit_signal("bit_requested", K_position) # ASK FOR A BIT
	
	if j == 1 and k == 1:
		if q == 0:
			set_q(1)
		elif q == 1:
			set_q(0)
	elif j == 1 and k == 0:
		set_q(1)
	elif j == 0 and k == 1 :
		set_q(0)

func connect_source(source):
	if not is_connected("bit_requested", source, "_on_bit_requested"):
		connect("bit_requested", source, "_on_bit_requested")
	
func disconnect_source(source):
	if is_connected("bit_requested", source, "_on_bit_requested"):
		disconnect("bit_requested", source, "_on_bit_requested")

func receive_source(bit):
	pass
	
func receive_j(bit):
	j = bit
	J_sprite.texture = BitsSpr[bit]
	
func receive_k(bit):
	k = bit
	K_sprite.texture = BitsSpr[bit]
	
func receive_pre_bar(bit):
	pre_bar = bit
	
func receive_clr_bar(bit):
	clr_bar = bit

func set_q(bit):
	q = bit
	display_sprite.texture = BitsSpr[q]

func send_q():
	return q
