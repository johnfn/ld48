extends Control

onready var Items = $Items
onready var Background = $Background


func set_contents(item_name):
  clear_slot()
  if item_name != null:
    var item_image = Items.get_node(item_name)
    if item_image == null:
      print("Tried to display non-existent item ", item_name)
    else:
      item_image.visible = true
      Background.visible = true
    

func _ready():
  clear_slot()


func clear_slot():
  for child in Items.get_children():
    child.visible = false
  Background.visible = false
