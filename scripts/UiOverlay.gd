extends Node2D

onready var hearts: Array = [
  $CanvasLayer/Heart,
  $CanvasLayer/Heart2,
  $CanvasLayer/Heart3
  ]

# passed in by Main
var player: Player
var old_player_health: int

func render_hearts():
  for i in range(3):
    if player.health >= 2 + i * 2:
      hearts[i].set_status("full")
    elif player.health >= 1 + i * 2:
      hearts[i].set_status("half")
    else:
      hearts[i].set_status("empty")

func _process(delta: float) -> void:
  if player.health != old_player_health:
    render_hearts()
    old_player_health = player.health
