class_name BaseHittable
extends RigidBody2D

export(int) var health = 1

onready var sprite = $Sprite
onready var parent = get_node("../")
onready var Hitbox = $Hitbox
var hit_sfx = "Hit"

var being_hit = false
var knockback_vector: Vector2 = Vector2.ZERO
var knockback: bool = false

func _ready() -> void:
  self.contact_monitor = true
  self.contacts_reported = true
  
  var _unused = self.connect("body_entered", self, "on_enter")
  _unused = self.connect("body_exited", self, "on_exit")

func on_enter(other) -> void:
  if other.has_method("is_player") and other.is_player():
    other.damage(1, self)

func on_exit(_other) -> void:
  pass

func is_hittable() -> bool:
  return true

# can be overridden if u want custom behavior.
func on_die():
  CombatHelpers.drop_item(self)

  queue_free()

func disable_hitbox(delay = 0.1):
  # It feels better for there to be a short delay before the hitbox is removed
  yield(get_tree().create_timer(delay), "timeout")
  
  collision_layer = 0
  collision_mask = 0

func damage(amount: int, source: Node2D) -> void:
  if being_hit or health <= 0:
    return

  being_hit = true
  health -= amount
  SoundManager.play_sound(hit_sfx)
  
  knockback_vector = position.direction_to(source.position) * 10000
  knockback = true
  
  var dead = health <= 0
  
  # instantly turn off collisions, even before death animation
  if dead:
    disable_hitbox()

  if sprite is Sprite:
    yield(CombatHelpers.damage_anim_sprite(sprite), "completed")
  elif sprite is AnimatedSprite:
    yield(CombatHelpers.damage_anim_animated_sprite(sprite), "completed")
  else:
    print("unhandled sprite type in damage()")
  
  if dead:
    on_die()
  else:
    being_hit = false
