extends ColorRect

export(String) var text
onready var animation = $AnimationPlayer

signal click

func _on_DoneButton_mouse_entered():
  animation.play("MouseOver")

func _on_DoneButton_mouse_exited():
  animation.play_backwards("MouseOver")


func _on_DoneButton_gui_input(event):
  if (event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT):
    emit_signal("click")
    print("Click")
