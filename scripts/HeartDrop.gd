extends Area2D

func _ready():
    connect("body_entered", self, "on_enter")
  
func on_enter(other: Node2D):
  if other is Player:
    other.get_health(1)
    queue_free()
