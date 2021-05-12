extends Sprite

export(float) var rotation_speed = 5.0

func _process(delta):
  if visible:
    rotation_degrees += delta * rotation_speed
