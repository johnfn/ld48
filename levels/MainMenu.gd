extends Control

func _process(delta):
  var mouse_vec = get_global_mouse_position()
  var pos = mouse_vec / 40
  $Title.margin_left = pos.x
  $Title.margin_top = sqrt(pos.y) * 2


func _on_Quit_pressed():
  get_tree().quit()


func _on_Play_pressed():
  get_tree().change_scene("res://Main.tscn")


func _on_VolumeBar_value_changed(value):
  SoundManager.set_volume(value)


func _on_Credits_pressed():
  get_tree().change_scene("res://scenes/Credits.tscn")


func _on_Volume_pressed():
  $VolumeBar.visible = not $VolumeBar.visible
