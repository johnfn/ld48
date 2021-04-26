class_name CardTrigger
extends Area2D

var triggered = false
export(int) var which_card = 1

func _ready():
  connect("body_entered", self, "body_entered")

func body_entered(other: Node2D):
  if triggered:
    return
  
  if other is Player:
    triggered = true
    Letterbox.show_title_card(which_card)
