extends Node2D

func damage_anim(target: Sprite):
  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")
  
  target.material.set_shader_param("white", 1.0)

  yield(get_tree().create_timer(0.1), "timeout")
  
  target.material.set_shader_param("white", 0.0)

  for i in range(3):
    target.visible = false
    
    yield(get_tree().create_timer(0.05), "timeout")
    
    target.visible = true
    
    yield(get_tree().create_timer(0.05), "timeout")
