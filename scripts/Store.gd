class_name Store
extends Node2D

onready var Ping = $PingSprite
onready var ping_y = Ping.position.y
var tick = 0.0
var can_interact = false
var DialogScene = load("res://scenes/Dialog.tscn")
var interacting = false
var shop_dialog = preload("res://scenes/ShopDialog.tscn")
onready var Letterbox = $"/root/Main/Letterbox"

func _ready(): 
  Ping.visible = false

func _process(delta: float): 
  tick += delta
  
  Ping.position.y = ping_y - 20 + sin(tick * 4) * 20.0

  if Input.is_action_just_pressed("ui_select") and can_interact and not Letterbox.in_cinematic:
    interact()

func interact():
  Letterbox.in_cinematic = true
  
  var new_dialog = DialogScene.instance()

  new_dialog.display_text_sequence_co(self, ["Hi Olive!", "Would you like to buy something?"], 5)
  yield(new_dialog, "dialog_complete")
  
  var dialog = shop_dialog.instance()
  
  $"/root/Main/UI/CanvasLayer".add_child(dialog)
  
  yield(dialog, "closed")
  Letterbox.in_cinematic = false

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
