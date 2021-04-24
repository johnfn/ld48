extends Node2D

export(Vector2) var spawn_point = Vector2(0, 0)
export(float) var top_wall = 0;
export(float) var bottom_wall = 0;
export(bool) var is_top_open = false;

func _ready():
  if spawn_point == Vector2(0, 0):
    spawn_point = $Markers/SpawnPoint.position
  top_wall = $Markers/LevelTop.position.y
  bottom_wall = $Markers/LevelBottom.position.y

func _on_Donut_tree_exited():
  is_top_open = true
