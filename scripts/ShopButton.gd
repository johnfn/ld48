extends ColorRect

onready var animation = $AnimationPlayer

func _ready():
  print("hello")

func _on_ColorRect_mouse_entered():
  animation.play("MouseOver")
  print(animation)

func _on_ColorRect_mouse_exited():
  animation.play_backwards("MouseOver")
  print("b")
