extends RigidBody2D

export(int) onready var health = 1

onready var Sprite: Sprite = $Sprite

var dying = false
var being_hit = false

# only in the most general sense 
func is_enemy() -> bool:
  return true

func damage(amount: int, source: Node2D) -> void:
  if being_hit:
    return
    
  health -= amount
  
  being_hit = true
  yield(CombatHelpers.damage_anim_sprite(Sprite), "completed")
  
  if health <= 0:
    queue_free()
    
  being_hit = false
