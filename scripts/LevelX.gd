extends Node2D

export(Vector2) var spawn_point = Vector2(0, 0)
export(float) var top_wall = 0;
export(float) var bottom_wall = 0;
export(bool) var is_top_open = true;
export(bool) var dirty = false
export(String) var song = "Chapter1Song"


func get_song():
  return song


func _ready():
  if spawn_point == Vector2(0, 0):
    spawn_point = $Markers/SpawnPoint.position
  top_wall = $Markers/LevelTop.position.y
  bottom_wall = $Markers/LevelBottom.position.y
  dirty = true
