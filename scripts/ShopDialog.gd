extends Node2D

signal closed

func _ready():
  $Description.visible = false

func _on_DoneButton_click():
  $AnimationPlayer.play("Close")
  
  yield($AnimationPlayer, "animation_finished")
  
  queue_free()
  
  emit_signal("closed")

func _on_button_mouse_move(position, which):
  $Description.visible = true
  
  $Description.rect_position = Vector2(700 + 20, position.y)
  $Description.text = which.my_description

func on_button_mouse_out():
  $Description.visible = false

func _on_Button_mouse_move(position):
  _on_button_mouse_move(position, $VBoxContainer/Button)


func _on_Button2_mouse_move(position):
  _on_button_mouse_move(position, $VBoxContainer/Button2)


func _on_Button3_mouse_move(position):
  _on_button_mouse_move(position, $VBoxContainer/Button3)
