extends Area2D

func _ready():
    var _res = connect("body_entered", self, "on_enter")
  
func on_enter(other: Node2D):
  if other is Player:
    other.get_arrows(5)
    
    queue_free()

var tick = 0

func _process(delta):
  tick += delta * 5.0
  
  $Sprite.position.y = -10 + (sin(tick / 2.0) + 1) * 10.0
