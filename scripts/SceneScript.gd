extends Node2D

onready var black_tex: Texture = load("res://assets/black_square.png")
onready var white_tex: Texture = load("res://assets/white_square.png")
onready var sq: Sprite = $Sprite/white_square
var color = "white"

func _ready():
    print(sq)


func set_color(new_color: String) -> void:
    if new_color == "white":
        sq.texture = white_tex

    if new_color == "black":
        sq.texture = black_tex
    
    color = new_color
    
func get_color() -> String:
    return color

func _process(delta):
   pass
