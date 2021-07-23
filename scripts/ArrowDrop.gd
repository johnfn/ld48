extends Area2D

func pickup(body: Player):
  body.get_arrows(5)
  
  queue_free()
 
var tick = 0

func _process(delta):
  tick += delta * 5.0
  
  $Sprite.position.y = -10 + (sin(tick / 2.0) + 1) * 10.0

func _on_ArrowDrop_body_entered(body):
  if body is Player:
    pickup(body)
