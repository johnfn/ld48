extends Area2D

export(int) onready var damage = 1

func _ready():
    self.connect("body_entered", self, "on_enter")

func on_enter(other) -> void:
    if other is Player:
      other.damage(1)
