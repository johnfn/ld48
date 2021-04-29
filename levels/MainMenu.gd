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

func hover(obj: TextureButton) -> void:
  $Tween.interpolate_property(
    obj, 
    "rect_scale",
    obj.rect_scale, 
    Vector2(1.2, 1.2), 
    0.1,
    Tween.TRANS_LINEAR, 
    Tween.EASE_IN_OUT
  )
  $Tween.start()

  $ColorTween.interpolate_property(
    obj,
    "modulate",
    obj.modulate,
    Color.white,
    0.1
   )
  $ColorTween.start()
  
func unhover(obj: TextureButton) -> void:
  $Tween.interpolate_property(
    obj, 
    "rect_scale",
    obj.rect_scale, 
    Vector2(1, 1), 
    0.1,
    Tween.TRANS_LINEAR, 
    Tween.EASE_IN_OUT
    )
  $Tween.start()
  
  $ColorTween.interpolate_property(
    obj,
    "modulate",
    obj.modulate,
    Color.black,
    0.1
   )
  $ColorTween.start()
  
func _on_Credits_mouse_entered():
  hover($VBoxContainer/Credits)

func _on_Credits_mouse_exited():
  unhover($VBoxContainer/Credits)
  


func _on_Quit_mouse_entered():
  hover($VBoxContainer/Quit)

func _on_Quit_mouse_exited():
  unhover($VBoxContainer/Quit)


func _on_Play_mouse_entered():
  hover($VBoxContainer/Play)


func _on_Play_mouse_exited():
  unhover($VBoxContainer/Play)


func _on_Volume_mouse_entered():
  hover($VBoxContainer/Container/Volume)


func _on_Volume_mouse_exited():
  unhover($VBoxContainer/Container/Volume)
