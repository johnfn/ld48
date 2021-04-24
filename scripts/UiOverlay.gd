extends Control

onready var hearts: Array = $CanvasLayer/HeartContainer.get_children()

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
