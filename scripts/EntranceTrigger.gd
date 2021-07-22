extends Area2D

export(String) var scene_dest
export(String) var exit_name
export(bool) var is_cave

func _ready():
  if self.connect("body_entered", self, "body_enter") != OK: print("connect error [4]")

func body_enter(other: Node2D):
  if other is Player:
    $"/root/Main".load_cave(scene_dest, exit_name, is_cave)
