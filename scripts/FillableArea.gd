extends StaticBody2D


func _on_body_entered(body):
  if body.has_method("is_pushable") and body.is_pushable():
    body.fill_in_hole()
    queue_free()
