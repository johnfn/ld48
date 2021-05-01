class_name CardTrigger
extends Area2D

onready var FireflySpawner = $"/root/Main/FireflySpawner"
onready var Letterbox = $"/root/Main/Letterbox"
var triggered = false
export(int) var which_card = 1

func _ready():
  connect("body_entered", self, "body_entered")

func body_entered(other: Node2D):
  if triggered:
    return
  
  if other is Player:
    triggered = true
    Letterbox.show_title_card(which_card, which_card == 2) # true -> turn on lighting
