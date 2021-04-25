class_name Player
extends KinematicBody2D

signal died

const IDLE_FRAME = 1

var input_vec : Vector2 = Vector2(0, 0)
export(float) var max_speed = 600.0
export(float) var invuln_time = 0.4
export(int) var max_health = 6

onready var Sprite: AnimatedSprite = $Sprite
onready var Equipment = $Equipment
onready var Weapons = $Equipment/weapons
onready var health = max_health

var equipment_slots = {}
var is_invuln = false

var knockback = false
var knockback_source: Node2D = null

func _process(delta: float) -> void:
  Weapons.look_at(get_global_mouse_position())

func _physics_process(delta: float) -> void:
  if Letterbox.in_cinematic: 
    Sprite.stop()
    Sprite.frame = IDLE_FRAME
        
    return
  
  var direction = input_vec.normalized() * max_speed
  
  if knockback:
    var bump_direction = (global_position - knockback_source.global_position).normalized()
    direction += bump_direction * 5000
    
    knockback = false
    knockback_source = null
  
  if input_vec.y < 0:
    if input_vec.x > 0:
      set_direction("upright")
    elif input_vec.x < 0:
      set_direction("upleft")
    else:
      set_direction("up")
  elif input_vec.y > 0:
    if input_vec.x > 0:
      set_direction("downright")
    elif input_vec.x < 0:
      set_direction("downleft")
    else:
      set_direction("down")
  elif input_vec.x > 0:
    set_direction("right")
  elif input_vec.x < 0:
    set_direction("left")

  if input_vec == Vector2(0, 0) and Sprite.is_playing():
    Sprite.stop()
    Sprite.frame = IDLE_FRAME  
  
  move_and_slide(direction, Vector2(0, 0), false, 4, 0.785398, false)

func _unhandled_input(event: InputEvent) -> void:
  if Input.is_action_just_pressed("move_down"):
    input_vec.y = 1
  elif Input.is_action_just_pressed("move_up"):
    input_vec.y = -1
  elif not Input.is_action_pressed("move_down") and not Input.is_action_pressed("move_up"):
    input_vec.y = 0
    
  if Input.is_action_just_pressed("move_right"):
    input_vec.x = 1
  elif Input.is_action_just_pressed("move_left"):
    input_vec.x = -1
  elif not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
    input_vec.x = 0
  
  if Weapons.get_child_count() > 0:
    if Input.is_action_just_pressed("interact"):
      for weapon in Weapons.get_children():
        if weapon.has_method("set_in_use"):
          weapon.set_in_use(true)
    elif Input.is_action_just_released("interact"):
      for weapon in Weapons.get_children():
        if weapon.has_method("set_in_use"):
          weapon.set_in_use(false)
  




func set_direction(dir_name):
  if Sprite.animation != dir_name or not Sprite.playing:
    Sprite.play(dir_name)
  if dir_name.find("up") >= 0 or dir_name == "left":
    Weapons.z_index = 0
  else:
    Weapons.z_index = 2
  match dir_name:
    "up":
      Weapons.position = $Equipment/rh_up.position
    "down":
      Weapons.position = $Equipment/rh_down.position
    "left":
      Weapons.position = $Equipment/rh_left.position
    "right":
      Weapons.position = $Equipment/rh_right.position
    "upleft":
      Weapons.position = $Equipment/rh_upleft.position
    "downleft":
      Weapons.position = $Equipment/rh_downleft.position
    "upright":
      Weapons.position = $Equipment/rh_upright.position
    "downright":
      Weapons.position = $Equipment/rh_downright.position

func damage(amount: int, source: Node2D) -> void:
  if not is_invuln and health > 0:
    is_invuln = true
    
    # take damage
    
    health -= amount
    
    if health <= 0:
      emit_signal("died")
      is_invuln = false
      return
    
    # bump player back a little
    
    knockback = true
    knockback_source = source

    yield(CombatHelpers.damage_anim_animated_sprite(Sprite), "completed")
    
    is_invuln = false


func reset_equipment():
  for equipment in equipment_slots.values():
    equipment.queue_free()
  equipment_slots = {}

func equip(equipment: Node, slot: String) -> void:
  if equipment.has_method("init"):
    equipment.init(self)
  
  if slot in equipment_slots:
    equipment_slots[slot].queue_free()
  Equipment.get_node(slot).call_deferred("add_child", equipment)
  equipment_slots[slot] = equipment


func is_player() -> bool:
  return true
