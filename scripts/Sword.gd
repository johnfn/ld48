class_name Sword
extends Node2D

onready var Letterbox = $"/root/Main/Letterbox"
onready var AnimationPlayer = $SwordObj/AnimationPlayer
onready var swing_animation = $SwordObj/AnimationPlayer.get_animation("Swing")
onready var Hitbox: CollisionPolygon2D = $Hitbox
onready var SwordSprite = $SwordObj/SwordSprite
onready var StickSprite = $StickSprite
onready var SwordArea = self
onready var root = $"/root"
onready var SliceAnimation = $SliceAnimation
onready var HitsparkAnimation = $Hitspark/HitsparkAnimation
var raycast_instance: RayCast2D
var HitsparkScene = load("res://scenes/Hitspark.tscn")

var damage = 1
onready var player: Player = $"/root/Main/Player"
var swinging = false
var has_raycasted_this_swing = true

func _ready() -> void:
  raycast_instance = RayCast2D.new()
  raycast_instance.enabled = true
  raycast_instance.collide_with_areas = true
  raycast_instance.set_collision_mask_bit(0, false)
  raycast_instance.set_collision_mask_bit(1, true)
  raycast_instance.set_collision_mask_bit(2, true) # obstacle
  raycast_instance.set_collision_mask_bit(7, true) # flying
  raycast_instance.set_collision_mask_bit(10, true) # boss
#  raycast_instance.set_collision_mask_bit(11, true) # sword passthrough (grass)
    
  raycast_instance.add_exception(player)
  
  root.call_deferred("add_child", raycast_instance)
  SliceAnimation.visible = false
  SliceAnimation.connect("animation_finished", self, "hide_anim")
  
  SwordArea.connect("body_entered", SwordArea, "on_enter")

func hide_anim():
  SliceAnimation.visible = false

func set_in_use(in_use: bool) -> void:
  if not in_use:
    return
    
  if Letterbox.in_cinematic:
    return
    
  if swinging:
    return
  
  SoundManager.play_sound("Sword")
  swinging = true
  has_raycasted_this_swing = false
  SwordSprite.modulate.a = 1.0
  
  # this is necessary so that we DEFINITELY trigger a body_entered when we start the swing (e.g. if the sword starts IN the enemy it will not trigger body_entered)
  Hitbox.set_disabled(false)
  
  SliceAnimation.visible = true
  SliceAnimation.frame = 0
  SliceAnimation.play("slice")
  AnimationPlayer.play("Swing")

  yield(AnimationPlayer, "animation_finished")

  Hitbox.set_disabled(true)
  AnimationPlayer.clear_queue()

  SwordSprite.modulate.a = 0.3
  
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
  
  update()
  
  var successful_hits = []
  
  for potential_enemy in hits:
    if potential_enemy.has_method("is_hittable") and potential_enemy.is_hittable():
      raycast_instance.global_position = player.global_position
      raycast_instance.cast_to = (potential_enemy.global_position - player.global_position)
      raycast_instance.force_raycast_update()
      
      var hit = raycast_instance.get_collider()
      
      var damaged = false
      
      if hit == potential_enemy:
        hit.damage(damage, self)
        successful_hits.push_back(potential_enemy)
      
      if hit == null and potential_enemy.get_collision_layer_bit(11):
        potential_enemy.damage(damage, self)
        successful_hits.push_back(potential_enemy)
  
  # render hitspark
  
  for hit in hits:
    raycast_instance.global_position = player.global_position
    raycast_instance.cast_to = hit.global_position - player.global_position
    raycast_instance.force_raycast_update()
    
    if raycast_instance.get_collider() == null:
      continue
    
    var hitspark = HitsparkScene.instance()
    
    $"/root/Main".add_child(hitspark)
    
    hitspark.global_position = hit.global_position
    
#    yield(hitspark, "ready")
    
    hitspark.global_position = raycast_instance.get_collision_point()
    hitspark.visible = true
    hitspark.HitsparkAnimation.frame = 0
    hitspark.HitsparkAnimation.play("hitspark")
        
    hitspark.look_at(player.global_position)
    hitspark.rotation_degrees += 180
    
    SoundManager.play_sound("OOT_Sword_Smack1")
    
    yield(hitspark.HitsparkAnimation, "animation_finished")
    
    hitspark.queue_free()

    break
