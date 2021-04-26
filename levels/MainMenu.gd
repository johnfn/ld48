extends Control

var max_lean = 40
var mouse_max = 300
func _process(delta):
  var mouse_vec = get_global_mouse_position() - Vector2(640, 640)
  var strength = min(mouse_max, mouse_vec.length()) / mouse_max * max_lean
  var pos = strength * mouse_vec.normalized()
  $Title.margin_left = pos.x
  $Title.margin_top = pos.y


func _on_Quit_pressed():
  get_tree().quit()


func _on_Play_pressed():
  get_tree().change_scene("res://Main.tscn")


func _on_VolumeBar_value_changed(value):
  SoundManager.set_volume(value)


func _on_Credits_pressed():
  get_tree().change_scene("res://Credits.tscn")
