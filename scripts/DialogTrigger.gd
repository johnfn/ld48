extends Area2D

export var dialog: Array = [
  "I'm some dialog that someone should really rewrite!"
]

var triggered = false
onready var area = $DialogTrigger
var DialogScene = load("res://scenes/Dialog.tscn")

func _ready():
  print("Hewo")
  connect("body_entered", self, "body_entered")

func body_entered(other: Node2D):
  if triggered:
    return
  
  triggered = true
  
  if other is Player:
      var new_dialog = DialogScene.instance()
      new_dialog.display_text_sequence_co(other, dialog)
