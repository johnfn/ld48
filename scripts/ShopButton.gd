tool
extends ColorRect

enum ShopItem {
  Heart,
  Arrow,
  Damage,  
}

var shop_data = {
  ShopItem.Heart: {
    "name": "Heart",
    "cost": 15,
    "texture": preload("res://assets/art/heart_full.png")
  },
  ShopItem.Arrow: {
    "name": "Arrow",
    "cost": 10,
    "texture": preload("res://assets/art/arrow.png")
  },
  ShopItem.Damage: {
    "name": "Damage",
    "cost": 20,
    "texture": preload("res://assets/art/crayonsword.png")
  },
}

export(ShopItem) var item = ShopItem.Heart

onready var animation = $AnimationPlayer
onready var buy_label = $BuyLabel
onready var cost_label = $CostLabel
onready var sprite = $ItemSprite

var sprite_size = Vector2(100, 100)

func update_content():
  buy_label.text = "Buy " + shop_data[item].name
  cost_label.text = str(shop_data[item].cost)
  sprite.texture = shop_data[item].texture
  sprite.scale = sprite_size / sprite.texture.get_size()

func _ready():
  update_content()

func _process(delta):
  if Engine.editor_hint:
    update_content()

func _on_ColorRect_mouse_entered():
  animation.play("MouseOver")

func _on_ColorRect_mouse_exited():
  animation.play_backwards("MouseOver")
