extends Area2D

var _speed = 0
var target = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# move toward target at speed
	var direction = target.global_position - self.global_position
	var velocity = direction.normalized() * _speed
	self.position = self.position + velocity * delta
