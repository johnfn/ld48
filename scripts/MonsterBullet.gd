extends Node2D 

# TODO: hit walls
# TODO: hit enemies
# TODO: Hit player

# should be supplied by parent
var direction: Vector2
var speed = 6

func _process(delta):
   position += direction * speed

