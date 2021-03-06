extends Control

onready var hearts: Array = $CanvasLayer/Hearts.get_children()
onready var slots: Array = $CanvasLayer/InventorySlots.get_children()
onready var CoinText = $CanvasLayer/Coins/CoinText
onready var ArrowText = $CanvasLayer/Arrows/ArrowText

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
    hearts[i].visible = (i + 1) * 2 <= player.max_health
      
func display_items(item_names):
  for i in range(min(len(slots), len(item_names))):
    slots[i].set_contents(item_names[i])

func render_coins():
  CoinText.text = str(player.coins)
  
func render_arrows():
  ArrowText.text = str(player.arrows)

func _process(_delta: float) -> void:
  if player.health != old_player_health:
    render_hearts()
    old_player_health = player.health
    
  render_coins()
  render_arrows()
