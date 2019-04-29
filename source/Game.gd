extends Node2D

var LostSpr = preload("res://ui/sprites/LOST.PNG")
var TiedSpr = preload("res://ui/sprites/TIED.PNG")
var WonSpr = preload("res://ui/sprites/WON.PNG")

var has_game_started = false
var is_game_over = false

func _unhandled_input(event):
	if event.is_action_pressed("ui_select"):
		if not has_game_started:
			has_game_started = true
			$CanvasModulate.hide()
			$UI/Logo.hide()
		if is_game_over:
			get_tree().reload_current_scene()	
			is_game_over = false
	if event.is_action_pressed("ui_cancel"):
		get_tree().reload_current_scene()	
	
func game_over_tied():
	show_game_over_screen()
	$UI/GameOverTexture.texture = TiedSpr
	pass
	
func game_over_won():
	show_game_over_screen()
	$UI/GameOverTexture.texture = WonSpr
	pass	

func game_over_lost():
	show_game_over_screen()
	$UI/GameOverTexture.texture = LostSpr
	pass
	
func show_game_over_screen():
	is_game_over = true
	$CanvasModulate.show()