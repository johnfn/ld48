extends Node2D

onready var TopRect = $CanvasLayer/TopRect
onready var BottomRect = $CanvasLayer/BottomRect
onready var EntireScreenFadeRect = $CanvasLayer/EntireScreenFadeRect
onready var camera: Camera2D = null
onready var main = null
onready var Cards = [$CanvasLayer/Title1, $CanvasLayer/Title2]
onready var FireflySpawner = $"/root/Main/FireflySpawner"
onready var ItemGet = $CanvasLayer/ItemGet
var DialogScene = load("res://scenes/Dialog.tscn")
var SwordPickup = load("res://components/SwordPickup.tscn")
var WeaponName = preload("res://scripts/WeaponName.gd").WeaponName
var item_scenes = {
  WeaponName.Sword: preload("res://components/SwordPickup.tscn"),
  WeaponName.Bow: preload("res://components/BowPickup.tscn")
}

var shown_card = [false, false, false, false]
var letterbox_animation_length = 45.0
var zoom_in_amount = 0.8

# are we currently in any sort of cinematic at all?
var in_cinematic = false

# are we currently animating the letterbox? (are the boxes actually moving?)
var is_animating = false

var max_dusk = 0.2
var max_night = 0.3

func _ready():
  camera = $"/root/Main/Camera"
  main = $"/root/Main"

  z_index = 1000
  
  TopRect.rect_position.y -= TopRect.rect_size.y
  BottomRect.rect_position.y += BottomRect.rect_size.y
  EntireScreenFadeRect.visible = false 
  ItemGet.visible = false
  
  for card in Cards:
    card.visible = false

#  DuskOverlay.modulate.a = 0.0
#  NightOverlay.modulate.a = 0.0

#func _process(f: float):
#  DuskOverlay.modulate.a = 0.2
#  NightOverlay.modulate.a = 1


func get_item_cinematic(item: Pickup):
  in_cinematic = true
  
  # TODO: Just use a custom graphic lol
  
  # Show the animation and item you got
  var lofted_item_scene = item_scenes[item.weapon_id]
  var main_item = lofted_item_scene.instance()
  var bg_item = lofted_item_scene.instance()
  
  var player = $"/root/Main/Levels/Player"
  var player_screen_pos = player.get_global_transform_with_canvas().origin
  var pos = player_screen_pos + Vector2(0, -150)
  var old_player_parent = player.get_parent()
  var old_player_global_position = player.global_position

  player.Sprite.play("itemget")
#  player.z_index = 4005
  
  # necessary for the player to sort properly over the fade layer
  old_player_parent.remove_child(player)
  
  $CanvasLayer.add_child(main_item)
  $CanvasLayer.add_child(bg_item)
  $AboveCanvasLayer.add_child(player)
  
  player.Equipment.visible = false
  player.global_position = old_player_global_position
  
  main_item.position = pos
  bg_item.position = pos
  ItemGet.position = pos
  
  bg_item.get_node("Sprite").material.set_shader_param("whited", 1.0)
  main_item.z_index = 4000
  bg_item.z_index = 3999
  # bg_item.get_node("StickSprite").material.set_shader_param("white", 0.0)
  
  # main_item.scale = Vector2(2, 2)
  bg_item.scale = Vector2(1.3, 1.3)
  
  bg_item.rotation_degrees = 0
  bg_item.modulate = Color(1, 1, 1, 1)
  
  item.position = ItemGet.position + Vector2(40, -100)
  item.scale = Vector2(2, 2)
  
  ItemGet.visible = true
  
  yield(fade_to_black(20.0, 0.8), "completed")
  
  var new_dialog = DialogScene.instance()
  
  yield(new_dialog.display_text_sequence_co(ItemGet, item.pickup_dialog, 500.0), "completed")
  
  player.Sprite.play("up")
  ItemGet.visible = false
  
  player.Equipment.visible = true
  player.get_parent().remove_child(player)
  old_player_parent.add_child(player)
  main_item.queue_free()
  bg_item.queue_free()
  player.global_position = old_player_global_position
  
  yield(unfade_to_black_timed(30.0), "completed")
  
  in_cinematic = false

func animate_in(target: Node2D):
  if is_animating:
    # two people called animate_in at the same time. wait until it finishes and then just end
    while is_animating:
      yield(get_tree(), "idle_frame")
    
    return
    
  is_animating = true
  
  var start_pos = camera.global_position
  var end_pos = target.global_position
  
  end_pos.x = start_pos.x # don't adjust x at all
  
  for x in range(int(letterbox_animation_length)):
    yield(get_tree(), "idle_frame")
    
    camera.global_position = start_pos + (end_pos - start_pos) * (float(x) / letterbox_animation_length)
    camera.zoom = Vector2(1, 1) - Vector2(1 - zoom_in_amount, 1 - zoom_in_amount) * (float(x) / letterbox_animation_length)
    
    TopRect.rect_position.y += TopRect.rect_size.y / letterbox_animation_length
    BottomRect.rect_position.y -= TopRect.rect_size.y / letterbox_animation_length
    
  is_animating = false

func animate_out():
  if is_animating: 
    return
    
  is_animating = true
  
  var start_pos = camera.global_position
  var end_pos = Vector2(start_pos.x, main.get_desired_cam_position(999999.0)) # pass in massive delta to get the final position
  
  for x in range(int(letterbox_animation_length)):
    yield(get_tree(), "idle_frame")

    camera.global_position = start_pos + (end_pos - start_pos) * (float(x) / letterbox_animation_length)
    camera.zoom = Vector2(zoom_in_amount, zoom_in_amount) + Vector2(1 - zoom_in_amount, 1 - zoom_in_amount) * (float(x) / letterbox_animation_length)

    TopRect.rect_position.y -= TopRect.rect_size.y / letterbox_animation_length
    BottomRect.rect_position.y += TopRect.rect_size.y / letterbox_animation_length

  is_animating = false

func fade_to_black(fade_length, fade_percentage = 1.0):
  if is_animating: 
    return
    
  is_animating = true
  
  EntireScreenFadeRect.visible = true
  EntireScreenFadeRect.modulate.a = 0.0
  
  for x in range(int(fade_length)):
    yield(get_tree(), "idle_frame")
    
    EntireScreenFadeRect.modulate.a = (float(x) / fade_length) * fade_percentage
  
  is_animating = false
  
func unfade_to_black_timed(fade_length):
  if is_animating: 
    return
    
  is_animating = true
  EntireScreenFadeRect.visible = true
  
  var starting = EntireScreenFadeRect.modulate.a
  
  for x in range(int(fade_length)):
    yield(get_tree(), "idle_frame")
    
    EntireScreenFadeRect.modulate.a = starting - starting * (float(x) / fade_length)
  
  EntireScreenFadeRect.visible = false
  is_animating = false

func show_title_card(num: int, trigger_lighting = false) -> void:
  if shown_card[num + 1]:
    return
  
  shown_card[num + 1] = true
  
  in_cinematic = true
  
  yield(fade_to_black(30), "completed")
  
  var c = Cards[num - 1]
  c.visible = true
  
  for x in range(30):
    c.modulate.a = x / 30.0
    yield(get_tree(), "idle_frame")
  
  yield(get_tree().create_timer(2.0), "timeout")

  if trigger_lighting:
    FireflySpawner.initial_firefly_spawn()
    # TODO: use fn on Main
    $"/root/Main/CanvasModulate".visible = true
    $"/root/Main/Levels/Player/Light2D".visible = true
    $"/root/Main/Levels/Player/Light2DDark".visible = false
    
  for x in range(30):
    c.modulate.a = 1.0 - x / 30.0
    yield(get_tree(), "idle_frame")
  
  c.visible = false
  
  yield(unfade_to_black_timed(30), "completed")
  
  in_cinematic = false
  
func unfade_to_black_instant():
  EntireScreenFadeRect.visible = false
  EntireScreenFadeRect.modulate.a = 0.0
