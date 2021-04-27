class_name DialogTrigger
extends Area2D

signal cinematic_ended


onready var Letterbox = $"/root/Main/Letterbox"
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
  
  if other is Player:
    triggered = true
    begin_cinematic(other)
    
func begin_cinematic(player: Player):
  yield(get_tree(), "idle_frame")
  
  var new_dialog = DialogScene.instance()
  
  if speaker == null:
    speaker = player
  
  if not cinematic_style_dialog:
    new_dialog.display_text_sequence_co(speaker, dialog)
    emit_signal("cinematic_ended")
    return
  
  Letterbox.in_cinematic = true
  
  if not is_instance_valid(speaker): return
  yield(Letterbox.animate_in(speaker), "completed")
    
  if is_instance_valid(speaker):
    yield(new_dialog.display_text_sequence_co(speaker, dialog), "completed")
  
  if fade_to_black:
    yield(Letterbox.fade_to_black(120.0), "completed")
  
  yield(Letterbox.animate_out(), "completed")
  
  Letterbox.in_cinematic = false
  emit_signal("cinematic_ended")
