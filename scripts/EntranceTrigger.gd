extends Area2D

export(PackedScene) var scene_dest
export(String) var exit_name

func _ready():
  self.connect("body_entered", self, "body_enter")

func body_enter(other: Node2D):
  if other is Player:
    other.enter_cave(scene_dest)
