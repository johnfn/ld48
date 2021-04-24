class_name Player
extends KinematicBody2D

var input_vec : Vector2 = Vector2(0, 0)
export(float) var max_speed = 600.0
export(float) var invuln_time = 0.25

export(int) var health = 6
onready var Equipment = $Equipment
onready var Weapons = $Equipment/weapons
var equipment_slots = {}
var invuln_time_left = 0.0

var knockback = false
var knockback_source: Node2D = null

func _process(delta: float) -> void:
  look_at(get_global_mouse_position())
  invuln_time_left -= delta
  

func _physics_process(delta: float) -> void:
  var direction = input_vec.normalized() * max_speed
  
  if knockback:
    var bump_direction = (global_position - knockback_source.global_position).normalized()
    direction += bump_direction * 10000
    
    knockback = false
    knockback_source = null
  
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
        weapon.set_in_use(true)
    elif Input.is_action_just_released("interact"):
      for weapon in Weapons.get_children():
        weapon.set_in_use(false)


func damage(amount: int, source: Node2D) -> void:
  if invuln_time_left <= 0:
    # take damage
    
    health -= amount
    invuln_time_left = invuln_time
    
    # bump player back a little
    
    knockback = true
    knockback_source = source



func equip(equipment: Node, slot: String) -> void:
  print("o..k")
  if equipment.has_method("init"):
    equipment.init(self)
  
  if slot in equipment_slots:
    equipment_slots[slot].queue_free()
  Equipment.get_node(slot).call_deferred("add_child", equipment)
  equipment_slots[slot] = equipment


func is_player() -> bool:
  return true
