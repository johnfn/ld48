extends Node2D

var contains_player = false



func _on_Bounds_body_entered(body):
  if body.has_method('is_player') and body.is_player():
    contains_player = true


func _on_Bounds_body_exited(body):
  if body.has_method('is_player') and body.is_player():
    contains_player = false
