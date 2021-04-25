class_name BaseHittable
extends RigidBody2D

export(int) var health = 1

onready var sprite = $Sprite
onready var parent = get_node("../")

var heart_drop = load("res://components/HeartDrop.tscn")
var being_hit = false
var knockback_vector: Vector2 = Vector2.ZERO
var knockback: bool = false

func is_enemy() -> bool:
  return true

# can be overridden if u want custom behavior.
func on_die():
  var new_heart = heart_drop.instance()
  parent.add_child(new_heart)
  new_heart.position = position
  
  queue_free()

func damage(amount: int, source: Node2D) -> void:
  if being_hit:
    return

  being_hit = true
  health -= amount
  
  knockback_vector = position.direction_to(source.position) * 10000
  knockback = true

  if sprite is Sprite:
    yield(CombatHelpers.damage_anim_sprite(sprite), "completed")
  elif sprite is AnimatedSprite:
    yield(CombatHelpers.damage_anim_animated_sprite(sprite), "completed")
  else:
    print("unhandled sprite type in damage()")
  
  if health <= 0:
    on_die()
    
  being_hit = false
