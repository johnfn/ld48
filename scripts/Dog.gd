class_name Dog
extends Area2D

onready var Sprite: AnimatedSprite = $Sprite

func _ready():
  Sprite.play("idle")
