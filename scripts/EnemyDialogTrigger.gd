extends "res://scripts/DialogTrigger.gd"

export(NodePath) var enemy_speaker: NodePath

func _ready():
  self.speaker = get_node(enemy_speaker)
