extends RigidBody2D

export(int) onready var health = 1

onready var Sprite = $Sprite

var dying = false

# only in the most general sense 
func is_enemy() -> bool:
  return true

func damage(amount: int, source: Node2D) -> void:
  print("Hello")
  health -= amount
  
  if health <= 0 and not dying:
    dying = true
    yield(CombatHelpers.damage_anim(Sprite), "completed")
    queue_free()
    
    return      
  
  CombatHelpers.damage_anim(Sprite)
