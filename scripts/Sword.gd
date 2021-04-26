extends Node2D

onready var AnimationPlayer = $AnimationPlayer
onready var swing_animation = $AnimationPlayer.get_animation("Swing")
onready var Hitbox: CollisionPolygon2D = $Hitbox
onready var SwordSprite = $SwordSprite
onready var StickSprite = $StickSprite
onready var SwordArea = self
onready var root = $"/root"
var raycast_instance: RayCast2D

var damage = 1
var player: Player
var swinging = false
var has_raycasted_this_swing = true

func _ready() -> void:
  raycast_instance = RayCast2D.new()
  raycast_instance.enabled = true
  raycast_instance.collide_with_areas = true
  raycast_instance.set_collision_mask_bit(0, false)
  raycast_instance.set_collision_mask_bit(1, true)
  raycast_instance.set_collision_mask_bit(2, true)
  raycast_instance.set_collision_mask_bit(7, true) # flying
  raycast_instance.set_collision_mask_bit(10, true) # boss
  
  raycast_instance.add_exception(player)
  
  root.call_deferred("add_child", raycast_instance)
  
  SwordArea.connect("body_entered", SwordArea, "on_enter")

func on_pick_up() -> void:
  Hitbox.set_disabled(true)
  SwordSprite.visible = true
  StickSprite.visible = false

func init(player: Player):
  self.player = player

func set_in_use(in_use: bool) -> void:
  if not in_use:
    return
    
  if Letterbox.in_cinematic:
    return
    
  if swinging:
    return
  
  swinging = true
  has_raycasted_this_swing = false
  SwordSprite.visible = true
  
  # this is necessary so that we DEFINITELY trigger a body_entered when we start the swing (e.g. if the sword starts IN the enemy it will not trigger body_entered)
  Hitbox.set_disabled(false)
  
  AnimationPlayer.play("Swing")

  yield(AnimationPlayer, "animation_finished")

  Hitbox.set_disabled(true)
  AnimationPlayer.clear_queue()
  SwordSprite.visible = false
  
  swinging = false

  # ... continues in _physics_process, b/c we need to wait for the overlapping bodies to be updated!

func _physics_process(delta):
  if Hitbox.disabled:
    return
  
  if SwordArea.get_overlapping_bodies().size() == 0 and SwordArea.get_overlapping_areas().size() == 0:
    return
    
  if has_raycasted_this_swing:
    return
  
  has_raycasted_this_swing = true

  var hits: Array = SwordArea.get_overlapping_bodies()
  var more_hits = SwordArea.get_overlapping_areas()
  
  hits.append_array(more_hits)
  
  print(hits)
  
  update()
  
  for potential_enemy in hits:
    if potential_enemy.has_method("is_enemy") and potential_enemy.is_enemy():
      
      raycast_instance.global_position = player.global_position
      raycast_instance.cast_to = (potential_enemy.global_position - player.global_position)
      raycast_instance.force_raycast_update()
      
      var hit = raycast_instance.get_collider()
      
      if hit == potential_enemy:
        hit.damage(damage, self)
