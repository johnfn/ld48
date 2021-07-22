extends CanvasLayer


func _ready():
  get_tree().paused = true


func _on_Resume_pressed():
  get_tree().paused = false
  queue_free()


func _on_Restart_pressed():
  var main = $"/root/Main"
  main.start_level(main.curr_level_num)
  get_tree().paused = false
  queue_free()


func _on_Quit_pressed():
  get_tree().quit()


func _unhandled_input(_event):
  if Input.is_action_just_pressed("pause"):
    get_tree().paused = false
    queue_free()
