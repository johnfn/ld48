extends Area2D

export var dialog: Array = [
  "I'm some dialog that someone should really rewrite!"
]
export var cinematic_style_dialog = false

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
  
  if not cinematic_style_dialog:
    new_dialog.display_text_sequence_co(player, dialog)
    return
  
  Letterbox.in_cinematic = true
  
  yield(Letterbox.animate_in(), "completed")
  
  yield(new_dialog.display_text_sequence_co(player, dialog), "completed")
  
  yield(Letterbox.animate_out(), "completed")
  
  Letterbox.in_cinematic = false
