extends Node2D

export(Vector2) var spawn_point = Vector2(0, 0)
export(float) var top_wall = 0;
export(float) var bottom_wall = 0;
export(bool) var is_top_open = false;
export(bool) var dirty = false

const SCREEN_SIZE = 1280

var has_displayed_bar = false
onready var goblin_king = $Enemies/GoblinKing
onready var main = $"/root/Main"
var player = null

func _ready():
  if spawn_point == Vector2(0, 0):
    spawn_point = $Markers/SpawnPoint.position
  top_wall = $Markers/LevelTop.position.y
  bottom_wall = $Markers/LevelBottom.position.y
  dirty = true
  $HealthBar/TextureProgress.modulate = Color(1, 1, 1, 0)
  goblin_king.set_player(player)
  goblin_king.poss_jump_targets = [
    $Markers/LeftJumpTarget.global_position, 
    $Markers/LeftJumpTarget2.global_position, 
    $Markers/RightJumpTarget.global_position, 
    $Markers/RightJumpTarget2.global_position
  ]
  

func _on_cinematic_ended():
  var tween = $HealthBar/Tween
  tween.interpolate_property($HealthBar/TextureProgress, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)
  tween.start()
  goblin_king.activate()
  main.center_camera = true
  

func _process(delta):
  $HealthBar/TextureProgress.value = goblin_king.health * 100 / goblin_king.MAX_HEALTH


func set_player(p):
  player = p


func _on_GoblinKing_died():
  main.center_camera = false
  var tween = $HealthBar/Tween
  tween.interpolate_property($HealthBar/TextureProgress, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)
  tween.start()
  is_top_open = true
  dirty = true
