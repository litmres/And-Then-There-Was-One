extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_PowerSource_bit_consumed():
	global_position -= Vector2(0, 64)

func _on_BPow_area_exited(area):
#	if area.name.find("PowerSource") > -1:
#		modulate = Color("1b4a52")
	pass
