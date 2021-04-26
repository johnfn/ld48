extends BaseHittable

var LogScene = load("res://components/PushableTemplate.tscn")

func _init().():
  self.health = 3

func on_die():
  var new_log = LogScene.instance()
  
  parent.add_child(new_log)
  new_log.position = position
  
  queue_free()
  SoundManager.play_sound("Hit")
