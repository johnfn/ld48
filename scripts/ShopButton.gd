tool
extends ColorRect

var mouse_over = false

signal mouse_move(position)
signal mouse_out

enum ShopItem {
  Heart,
  Arrow,
  Damage,  
}

var shop_data = {
  ShopItem.Heart: {
    "name": "Heart",
    "description": "Gain a heart of health back.",
    "cost": 15,
    "texture": preload("res://assets/art/heart_full.png")
  },
  ShopItem.Arrow: {
    "name": "Arrow",
    "description": "Buy 10 arrows.",
    "cost": 10,
    "texture": preload("res://assets/art/arrow.png")
  },
  ShopItem.Damage: {
    "name": "Damage",
    "description": "Deal double damage for the next 3 screens.",
    "cost": 20,
    "texture": preload("res://assets/art/crayonsword.png")
  },
}

export(ShopItem) var item = ShopItem.Heart

onready var animation = $AnimationPlayer
onready var buy_label = $HBoxContainer/VBoxContainer/BuyLabel
onready var cost_label = $HBoxContainer/VBoxContainer/HBoxContainer/CostLabel
onready var sprite = $HBoxContainer/ItemSprite
onready var player: Player = $"/root/Main/Levels/Player"

var sprite_size = Vector2(100, 100)
var my_description = ""

func update_content():
  $HBoxContainer/VBoxContainer/BuyLabel.text = "Buy " + shop_data[item].name
  $HBoxContainer/VBoxContainer/HBoxContainer/CostLabel.text = str(shop_data[item].cost)
  $HBoxContainer/ItemSprite.texture = shop_data[item].texture
  my_description = shop_data[item].description

func _ready():
  update_content()

func can_buy(): 
  return player.coins >= shop_data[item].cost

func _process(_delta):
  if Engine.editor_hint:
    update_content()
    return
  
  if not can_buy():
    $HBoxContainer/VBoxContainer/HBoxContainer/CostLabel.modulate = Color.gray
    $HBoxContainer/VBoxContainer/HBoxContainer/CostLabel.modulate = Color.red
  else:
    $HBoxContainer/VBoxContainer/HBoxContainer/CostLabel.modulate = Color.white
    $HBoxContainer/VBoxContainer/HBoxContainer/CostLabel.modulate = Color.white
    
func _on_ColorRect_mouse_entered():
  if not can_buy():
    return
    
  animation.play("MouseOver")
  mouse_over = true

func _on_ColorRect_mouse_exited():
  if not can_buy():
    return
  
  animation.play_backwards("MouseOver")
  mouse_over = false
  
  emit_signal("mouse_out")

func buy():
  if player.coins < shop_data[item].cost:
    return
  
  player.coins -= shop_data[item].cost
  
  match item:
    ShopItem.Arrow:
      player.get_arrows(10)
    ShopItem.Heart:
      player.get_health(2)
    ShopItem.Damage:
      print("unimplemented TODO")

func _input(event):
  if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
    buy()

  if event is InputEventMouseMotion:
    if mouse_over:
      emit_signal("mouse_move", event.position)
