extends Node2D

signal tick

var is_world_clock = false

onready var Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _on_Timer_timeout():
	emit_signal("tick")
