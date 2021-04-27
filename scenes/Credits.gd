extends Control

export(float) var time_per_screen = 3
func _ready():
  $AudioStreamPlayer.volume_db = SoundManager.get_db()
  var layer = get_node("Delete").get_child_count() - 1
  while layer >= 0:
    yield(get_tree().create_timer(time_per_screen), "timeout")
    get_node("Delete").get_child(layer).queue_free()
    layer -= 1
  get_tree().change_scene("res://levels/MainMenu.tscn")
