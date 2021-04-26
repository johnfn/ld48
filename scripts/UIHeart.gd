extends Node2D

onready var full_heart = $FullHeart
onready var half_heart = $HalfHeart
onready var empty_heart = $EmptyHeart

var tick = 0.0
var random_initial_offset = 0.0

func _ready():
  hide_all()

  full_heart.visible = true
  random_initial_offset = randf() * 5.0

func hide_all():
  full_heart.visible = false
  half_heart.visible = false
  empty_heart.visible = false

func set_status(new_status: String) -> void:
  hide_all()
  
  if new_status == "full":
    full_heart.visible = true

  if new_status == "half":
    half_heart.visible = true
  
  if new_status == "empty":
    empty_heart.visible = true
  
  if not new_status in ["full", "half", "empty"]:
    print("invalid status to UIHeart#set_status:", new_status)

func _process(delta: float) -> void:
  tick += delta
  
  var size = 1.0 + (sin(tick) + 1) / 9.0
  
  scale = Vector2(size, size)
  rotation = sin(random_initial_offset + tick * 2.0) / 10.0
