extends Area2D

export(int) onready var damage = 1


func _ready() -> void:
    self.connect("body_entered", self, "on_enter")


func on_enter(other) -> void:
    if other.has_method("is_player") and other.is_player():
      other.damage(damage, self)
