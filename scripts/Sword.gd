extends Node2D

onready var AnimationPlayer = $Sword/AnimationPlayer
onready var swing_animation = AnimationPlayer.get_animation("Swing")
onready var Hitbox: CollisionPolygon2D = $Sword/Hitbox
onready var SwordSprite = $Sword/SwordSprite
onready var StickSprite = $Sword/StickSprite
onready var SwordArea = $Sword
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
  raycast_instance.set_collision_mask_bit(1, true)
  raycast_instance.set_collision_mask_bit(2, true)
  
  root.add_child(raycast_instance)
  
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

var targets = []

func _draw():
  # draw_line(Vector2.ZERO, Vector2(500, 500), Color.blue)
  for target in targets:
    draw_line(Vector2.ZERO, (target.global_position - player.global_position), Color.blue)

func _physics_process(delta):
  if Hitbox.disabled:
    return
  
  if SwordArea.get_overlapping_bodies().size() == 0:
    return
    
  if has_raycasted_this_swing:
    return
  
  has_raycasted_this_swing = true

  var hits = SwordArea.get_overlapping_bodies()
  var enemy_hits = []
  
  targets = hits
  update()
  
  for potential_enemy in hits:
    if potential_enemy.has_method("is_enemy") and potential_enemy.is_enemy():
      raycast_instance.global_position = player.global_position
      raycast_instance.cast_to = (potential_enemy.global_position - player.global_position)
      raycast_instance.collide_with_areas = true
      raycast_instance.force_raycast_update()
      
      var hit = raycast_instance.get_collider()
      if hit == potential_enemy:
        hit.damage(damage, self)
