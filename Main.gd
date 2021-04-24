extends Node2D

onready var Player = $Player
onready var Cam = $Camera
onready var Ui = $UI

# Called when the node enters the scene tree for the first time.
func _ready():
  Ui.player = Player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  Cam.position.y = Player.position.y
