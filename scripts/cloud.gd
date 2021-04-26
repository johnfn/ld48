extends Node2D
onready var clouds: Array = get_children()
var speed = 20.0

func _ready():
  # Choose a random cloud
  
  var index = randi() % len(clouds)
  
  for i in range(len(clouds)):
    if i != index:
      clouds[i].visible = false

func _process(delta: float):
  position.x += speed * delta
  
  if position.x > 2000.0:
    queue_free()
