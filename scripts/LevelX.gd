extends Node2D

export(Vector2) var spawn_point = Vector2(0, 0)
export(float) var top_wall = 0;
export(float) var bottom_wall = 0;
export(bool) var is_top_open = true;
export(bool) var dirty = false
export(String) var song = "Chapter1Song"

func get_song():
  return song

func _on_DialogTrigger_cinematic_ended():
  var _err = get_tree().change_scene("res://scenes/Credits.tscn")
