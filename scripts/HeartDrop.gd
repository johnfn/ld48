extends Area2D

var textures = [preload("res://assets/art/cupcake.png"), preload("res://assets/art/donut.png"), preload("res://assets/art/chocolate.png")]

func _ready():
    var _res = connect("body_entered", self, "on_enter")
    $heart_full.texture = textures[floor(randf()*len(textures))]
  
func on_enter(other: Node2D):
  if other is Player:
    other.get_health(1)
    queue_free()


var tick = 0

func _process(delta):
  tick += delta * 5.0
  
  var size = 1.0 + (sin(tick) + 1) / 9.0
  
  scale = Vector2(size, size)
