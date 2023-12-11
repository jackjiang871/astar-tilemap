extends Area2D



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_units():
	return units

func area_entered(other):
	print(other)
	units.push_back(other)

func area_exited(other):
	var i = units.find(other)
	units.remove(i)
