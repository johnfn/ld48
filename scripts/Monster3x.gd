extends "res://scripts/Monster.gd"

var SmallBlobScene = load("res://components/Monster.tscn")

func _init().():
  self.health = 3

func on_die():
  var bs = [
    SmallBlobScene.instance(),
    SmallBlobScene.instance(),
    SmallBlobScene.instance(),
   ]
  
  for newblob in bs:
    self.parent.add_child(newblob)
    newblob.position = self.position + Vector2(randf() * 50.0 - 25.0, randf() * 50.0 - 25.0)
  
  queue_free()
