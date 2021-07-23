extends Area2D

func _ready():
    var _res = connect("body_entered", self, "on_enter")

func pickup(other: Player):
  other.get_coin(1)
  queue_free()

func on_enter(other: Node2D):
  if other is Player:
    pickup(other)

var tick = 0

func _process(delta):
  tick += delta * 5.0
  
  var size = 1.0 + (sin(tick) + 1) / 9.0
  
  scale = Vector2(size, size)
