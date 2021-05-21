extends Node2D

onready var Ping = $PingSprite
onready var ping_y = Ping.position.y
var tick = 0.0
var can_interact = false
var DialogScene = preload("res://scenes/Dialog.tscn")
var interacting = false

func _ready(): 
  Ping.visible = false

func _process(delta: float): 
  tick += delta
  
  Ping.position.y = ping_y - 20 + sin(tick * 4) * 20.0

  if Input.is_action_just_pressed("ui_select") and can_interact and not interacting:
    interact()

func interact():
  interacting = true
  
  var new_dialog = DialogScene.instance()

  yield(new_dialog.display_text_sequence_co(self, ["Hi Olive!", "Would you like to buy something?"], 5), "completed")
  
  interacting = false

func _on_InteractionArea_body_entered(body):
  if not (body is Player):
    return
  
  Ping.visible = true
  can_interact = true

func _on_InteractionArea_body_exited(body):
  if not (body is Player):
    return

  Ping.visible = false
  can_interact = false
