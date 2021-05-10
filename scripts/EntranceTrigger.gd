extends Area2D

export(String) var scene_dest
export(String) var exit_name

func _ready():
  self.connect("body_entered", self, "body_enter")

func body_enter(other: Node2D):
  print("Hewo")
  if other is Player:
    $"/root/Main".load_cave(scene_dest, exit_name)
