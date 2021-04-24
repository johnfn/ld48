extends Node2D

onready var black_square = $black_square
onready var white_square = $white_square

func _ready():
  black_square.visible = false
  white_square.visible = true

func set_status(new_status: String) -> void:
  if new_status == "full":
    white_square.visible = true
    black_square.visible = false
  elif new_status == "half":
    white_square.visible = true
    black_square.visible = true
  elif new_status == "empty":
    white_square.visible = false
    black_square.visible = true
  else:
    print("invalid status to UIHeart#set_status:", new_status)
