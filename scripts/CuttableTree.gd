extends BaseHittable

func _init().():
  self.health = 3

func on_die():
  print("Dead tree")
  
  queue_free()
