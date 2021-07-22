extends Node2D

var heart_drop = load("res://components/HeartDrop.tscn")
var coin_drop = load("res://components/CoinDrop.tscn")
var arrow_drop = load("res://components/ArrowDrop.tscn")

func damage_anim_sprite(target: Sprite):
 return _damage_anim(target)

func damage_anim_animated_sprite(target: AnimatedSprite):
  return _damage_anim(target)

func drop_item(target: Node2D):
  var parent = target.get_parent()
  var player = $"/root/Main/Levels/Player"
    
  if randi() % 5 == 0 or Globals.always_drop_arrow:
    var which_drop = randi() % 3
    
    if Globals.always_drop_arrow:
      which_drop = 2
    
    # re-roll so we don't get hearts at max hearts
    while which_drop == 0 and player.health == player.max_health:
      which_drop = randi() % 2
    
    if which_drop == 0:
      var new_heart = heart_drop.instance()
      
      parent.add_child(new_heart)
      new_heart.position = target.position
    
    elif which_drop == 1:
      var new_coin = coin_drop.instance()
      
      parent.add_child(new_coin)
      new_coin.position = target.position
    elif which_drop == 2:
      var new_arrow = arrow_drop.instance()
      
      parent.add_child(new_arrow)
      new_arrow.position = target.position

func _damage_anim(target):
  assert(target != null, "null target in _damage_anim")
    
  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")

  if is_enemy(target):
      target.material.set_shader_param("red", 1.0)
      yield(get_tree().create_timer(0.1), "timeout")
      target.material.set_shader_param("red", 0.0)
  else: 
      target.material.set_shader_param("white", 1.0)
      yield(get_tree().create_timer(0.1), "timeout")
      target.material.set_shader_param("white", 0.0)
  
  for _i in range(1):
     if target == null:
        break
     target.visible = false
    
     yield(get_tree().create_timer(0.05), "timeout")
    
     if target == null:
        break
     target.visible = true
    
     yield(get_tree().create_timer(0.05), "timeout")

func is_enemy(target):
  if target == null:
    return false
    
  if target.has_method("is_enemy") and target.is_enemy():
    return true
    
  return is_enemy(target.get_parent())
