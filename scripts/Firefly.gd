extends Node2D
onready var clouds: Array = get_children()
var speed = 20.0
var noise = OpenSimplexNoise.new()
var count = 0


func _ready():
  # Choose a random cloud
  noise.seed = randi()
  noise.octaves = 4
  noise.period = 300.0
  
  var index = randi() % len(clouds)
  
  for i in range(len(clouds)):
    if i != index:
      clouds[i].visible = false

func _process(_delta: float):
  count += 1
  
  var x_vel = noise.get_noise_1d(count)
  var y_vel = noise.get_noise_1d(-count)
  var direction = Vector2(x_vel, y_vel).normalized() * 1.0
  
  position += direction
  
  if position.x > 2000.0 or position.x < 0:
    queue_free()
