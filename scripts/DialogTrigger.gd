class_name DialogTrigger
extends Area2D

export var dialog: Array = [
  "I'm some dialog that someone should really rewrite!"
]
export var cinematic_style_dialog = false
export var fade_to_black = false
var speaker = null # null implies player - otherwise this will be passed down by someone who inherits us

var triggered = false
onready var area = $DialogTrigger
var DialogScene = load("res://scenes/Dialog.tscn")

func _ready():
  connect("body_entered", self, "body_entered")

func body_entered(other: Node2D):
  if triggered:
    return
  
  triggered = true
  
  if other is Player:
    begin_cinematic(other)
    
func begin_cinematic(player: Player):
  var new_dialog = DialogScene.instance()
  
  if speaker == null:
    speaker = player
  
  if not cinematic_style_dialog:
    new_dialog.display_text_sequence_co(player, dialog)
    return
  
  Letterbox.in_cinematic = true
  
  yield(Letterbox.animate_in(speaker), "completed")
    
  yield(new_dialog.display_text_sequence_co(speaker, dialog), "completed")
  
  if fade_to_black:
    yield(Letterbox.fade_to_black(), "completed")
  
  yield(Letterbox.animate_out(), "completed")
  
  Letterbox.in_cinematic = false
