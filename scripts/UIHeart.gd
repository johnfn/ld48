extends Control

onready var Left = $Left
onready var Right = $Right

func _ready():
  Left.visible = true
  Right.visible = true

func set_status(new_status: String) -> void:
  if not new_status in ["full", "half", "empty"]:
    print("invalid status to UIHeart#set_status:", new_status)
  else:
    Left.visible = new_status != "empty"
    Right.visible = new_status == "full"
