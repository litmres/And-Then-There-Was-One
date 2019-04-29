extends Node2D

var rabbits = []
var turn_count = 0
var turn = 0

onready var Clock = get_parent().get_parent().get_node("Clock")

func _ready():
	connect_clock(Clock)

func connect_clock(clock):
	if not clock.is_connected("tick", self, "_on_Clock_ticked"):
		clock.connect("tick", self, "_on_Clock_ticked")
		
func disconnect_clock(clock):
	if clock.is_connected("tick", self, "_on_Clock_ticked"):
		clock.disconnect("tick", self, "_on_Clock_ticked")

func _on_Clock_ticked():
	pass

func _unhandled_input(event):	
	if event.is_action_pressed("ui_page_down"):
		end_turn("")

func _on_Timer_timeout():	
	for rabbit in rabbits:		
		if rabbits.find(rabbit) == turn:
			rabbit.is_my_turn = true
		else:
			rabbit.is_my_turn = false			

func end_turn(area):	
	rabbits[turn].can_get_bit = true
	yield(Clock, "tick")
	turn += 1
	if turn == rabbits.size():
		for rabbit in rabbits:
			rabbit.has_j = false
			rabbit.has_k = false
			rabbit.is_my_turn = false
		turn = 0
