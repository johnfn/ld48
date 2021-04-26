extends Node2D

func damage_anim_sprite(target: Sprite):
 return _damage_anim(target)

func damage_anim_animated_sprite(target: AnimatedSprite):
  return _damage_anim(target)

func _damage_anim(target):
  assert(target != null, "null target in _damage_anim")
    
  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")
  
  # Prevent crash, no catches in gdscript
  target.material.set_shader_param("white", 1.0)
  target.material.set_shader_param("red", 1.0)
  
  yield(get_tree().create_timer(0.05), "timeout")
  target.material.set_shader_param("white", 0.0)
  target.material.set_shader_param("red", 0.0)
  
  for i in range(3):
     if target == null:
        break
     target.visible = false
    
     yield(get_tree().create_timer(0.05), "timeout")
    
     if target == null:
        break
     target.visible = true
    
     yield(get_tree().create_timer(0.05), "timeout")
