extends ColorRect

var tick = 0.0

func _process(delta):
  tick += delta
  
  $Label.modulate.a = 0.5 + (sin(tick * 4.0) + 1) / 4.0
  $Label.rect_scale = Vector2(
    1.0 + (sin(tick * 4.0 + 1.0) + 1) / 32.0,
    1.0 + (sin(tick * 4.0 + 1.0) + 1) / 32.0
   )

func _on_ClickToPlay_gui_input(event):
  if event is InputEventMouseButton:
    queue_free()

