extends Node2D

var rabbits = []
var turn_count = 0
var turn = 0

var is_on_clock_edge = false

func connect_clock(clock):
	if not clock.is_connected("tick", self, "_on_Clock_ticked"):
		clock.connect("tick", self, "_on_Clock_ticked")
		
func disconnect_clock(clock):
	if clock.is_connected("tick", self, "_on_Clock_ticked"):
		clock.disconnect("tick", self, "_on_Clock_ticked")

func _on_Clock_ticked():
	is_on_clock_edge = true

func _input(event):	
	if event.is_action_pressed("ui_select"):
		end_turn()

func _on_Timer_timeout():
	for rabbit in rabbits:		
		if rabbits.find(rabbit) == turn:
			rabbit.is_my_turn = true
#			rabbit.can_get_bit = false
		else:
			rabbit.is_my_turn = false			
#			rabbit.can_get_bit = true

func end_turn():
	rabbits[turn].can_get_bit = true
	turn += 1
	if turn == rabbits.size():
		turn = 0
		for rabbit in rabbits:
			rabbit.has_j = false
			rabbit.has_k = false
			rabbit.is_my_turn = false
#			rabbit.can_get_bit = false
	
	is_on_clock_edge = false
