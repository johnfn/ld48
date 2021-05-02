extends Node2D

onready var HitsparkAnimation = $HitsparkAnimation

func _ready():
  emit_signal("ready")
