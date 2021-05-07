extends Area2D

export(String) var song 

func _ready():
  connect("body_entered", self, "body_entered")

func body_entered(other: Node2D):
  if not (other is Player):
    return
  
  SoundManager.update_song(song)
