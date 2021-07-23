class_name DialogTrigger
extends Area2D

signal cinematic_ended

onready var Letterbox = $"/root/Main/Letterbox"
export var dialog: Array = [
  "I'm some dialog that someone should really rewrite!"
]
export var cinematic_style_dialog = false
export(String) var sfx = ""
export var fade_to_black = false
var speaker = null # null implies player - otherwise this will be passed down by someone who inherits us

var triggered = false
var DialogScene = load("res://scenes/Dialog.tscn")
export var autodismiss_time = 20

func _ready():
  var _unused = connect("body_entered", self, "body_entered")

func body_entered(other: Node2D):
  if triggered:
    return
  
  if not (other is Player):
    return
    
  if Globals.skip_cinematics():
    emit_signal("cinematic_ended")
    return
  
  if Globals.seen_dialogs.has(dialog):
    return
    
  Globals.seen_dialogs[dialog] = true

  triggered = true
  begin_cinematic(other)
    
func begin_cinematic(_initiator: Node2D):
  yield(get_tree(), "idle_frame")
  
  if sfx != "":
    SoundManager.play_sound(sfx)
  
  var new_dialog = DialogScene.instance()
  
  if speaker == null:
    speaker = $"/root/Main/Levels/Player"
  
  if not cinematic_style_dialog:
    new_dialog.display_text_sequence_co(speaker, dialog, autodismiss_time)
    emit_signal("cinematic_ended")
    return
  
  Letterbox.in_cinematic = true
  
  if not is_instance_valid(speaker): 
    yield(get_tree(), "idle_frame")
    return
    
  yield(Letterbox.animate_in(speaker), "completed")
    
  if is_instance_valid(speaker):
    yield(new_dialog.display_text_sequence_co(speaker, dialog, autodismiss_time), "completed")
  
  if fade_to_black:
    yield(Letterbox.fade_to_black(120.0), "completed")
  
  yield(Letterbox.animate_out(), "completed")
  
  Letterbox.in_cinematic = false
  emit_signal("cinematic_ended")
