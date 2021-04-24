class_name Player
extends KinematicBody2D

var input_vec : Vector2 = Vector2(0, 0)
export(float) var max_speed = 600.0

export(int) var health = 6
onready var Equipment = $Equipment
var equipment_slots = {}


func _physics_process(delta):
  var direction = input_vec.normalized()
  move_and_slide(direction * max_speed)


func _unhandled_input(event):
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


func damage(amount: int) -> void:
  health -= 1
  print(health)


func equip(equipment: Node, slot: String):
  if slot in equipment_slots:
    equipment_slots[slot].queue_free()
  Equipment.add_child(equipment)
  equipment_slots[slot] = equipment
