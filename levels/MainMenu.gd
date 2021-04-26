extends Control

func _on_Quit_pressed():
  get_tree().quit()


func _on_Play_pressed():
  get_tree().change_scene("res://Main.tscn")


func _on_VolumeBar_value_changed(value):
  SoundManager.set_volume(value)
