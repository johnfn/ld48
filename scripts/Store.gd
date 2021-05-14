extends Node2D

onready var Ping = $PingSprite
onready var ping_y = Ping.position.y
var tick = 0.0

func _ready(): 
  Ping.visible = false

func _process(delta: float): 
  tick += delta
  
  Ping.position.y = ping_y - 20 + sin(tick * 4) * 20.0

func _on_InteractionArea_body_entered(body):
  if not (body is Player):
    return
  
  print(body.name)
  Ping.visible = true

func _on_InteractionArea_body_exited(body):
  if not (body is Player):
    return

  print(body.name)    
  Ping.visible = false
