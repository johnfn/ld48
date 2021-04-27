extends KinematicBody2D

onready var sprite: Sprite = $Sprite
onready var Shadow = $Shadow
onready var parent = $"../"

var heart_drop = load("res://components/HeartDrop.tscn")
var height = 0.0
var initial_sprite_y = 0.0
var being_hit = false
var health = 5

func _ready():
  initial_sprite_y = sprite.position.y
  
  resize_shadow()
  
  go()

func resize_shadow():
  var sca = 2.0 / (1.0 + -height / 100.0)
  Shadow.scale = Vector2(sca, sca)

func go():
  while true:
    # walk
    
    var elem = randi() % 4
    var next_dir = [
      Vector2.LEFT, Vector2.RIGHT,
      Vector2.UP, Vector2.DOWN
    ][elem]
    var next_loc = position + next_dir * Vector2(200, 200)

    var ticks_before_jump = 300
    
    while position.distance_to(next_loc) > 50.0:
      yield(get_tree(), "idle_frame")
      
      var dir = self.position.direction_to(next_loc) * 100.0

      move_and_slide(dir)
      
      ticks_before_jump -= 1
      
      if get_slide_count() > 0:
        break
    
    while ticks_before_jump > 0:
      ticks_before_jump -= 1
      
      yield(get_tree(), "idle_frame")

    # jump
    
    var vy = -1.0
    
    height += vy
    sprite.position.y = initial_sprite_y + height
    
    next_dir = Vector2(randf(), randf()).normalized()

    while height < 0:
      yield(get_tree(), "idle_frame")
      
      move_and_slide(next_dir * 100.0)
      
      height += vy
      vy += 0.003
      sprite.position.y = initial_sprite_y + height

      resize_shadow()



















# copied from BaseHittable

func is_enemy() -> bool:
  return true

# can be overridden if u want custom behavior.
func on_die():
  if randi() % 5 == 0:
    var new_heart = heart_drop.instance()
    parent.add_child(new_heart)
    new_heart.position = position
  
  queue_free()

func damage(amount: int, source: Node2D) -> void:
  if height < -20.0:
    return
    
  if being_hit:
    return

  being_hit = true
  health -= amount
  SoundManager.play_sound("Hit")
  
  if sprite is Sprite:
    yield(CombatHelpers.damage_anim_sprite(sprite), "completed")
  # elif sprite is AnimatedSprite:
  #  yield(CombatHelpers.damage_anim_animated_sprite(sprite), "completed")
  
  if health <= 0:
    on_die()
  else:
    being_hit = false
