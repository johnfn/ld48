tool
extends Node2D

export var permanent = false
export var scene_path = ""
var plugin = EditorPlugin.new() if Engine.editor_hint else null

func get_all_nodes(node):
  var list = []
  
  for child in node.get_children():
    #if child.name == "EditorBackground":
    #  continue
       
    if child.get_child_count() > 0:
      list += get_all_nodes(child)
    list.push_back(child)
  
  return list

func get_dimensions(node) -> Rect2:
  var all_nodes = get_all_nodes(node)
  
  var top_left = null
  var bot_right = null
  
  for child in all_nodes:
    if not ("global_position" in child):
      continue
    
    var new_top_left = child.global_position
    var new_bot_right = child.global_position 
  
    if child is Sprite:      
      if child.centered:
        new_top_left = child.global_position - child.texture.get_size() / 2
        new_bot_right = child.global_position + child.texture.get_size() / 2
      else:
        new_top_left = child.global_position - child.offset
        new_bot_right = child.global_position + child.texture.get_size() - child.offset

    if top_left == null:
      top_left = new_top_left
      bot_right = new_bot_right
    else:
      top_left = Vector2(min(new_top_left.x, top_left.x), min(new_top_left.y, top_left.y))
      bot_right = Vector2(max(new_bot_right.x, bot_right.x), max(new_bot_right.y, bot_right.y))

  return Rect2(top_left - node.global_position, bot_right - top_left)

func is_selected():
  var scene = get_node_or_null("Scene")
  var selected_nodes = EditorPlugin.new().get_editor_interface().get_selection().get_selected_nodes()
  
  return self in selected_nodes or $Rect in selected_nodes or (scene != null and scene in selected_nodes)

func on_select_change():
  var scene = get_node_or_null("Scene")
  var should_show = is_selected() or permanent
  
  if should_show and scene == null:
    scene = load(scene_path).instance()
    scene.set_meta("_edit_lock_", true)
    scene.name = "Scene"
    add_child(scene)
    scene.set_owner(get_tree().get_edited_scene_root())
    
    var dim = get_dimensions(scene)

    $Rect.rect_size = dim.size
    $Rect.rect_position = dim.position
    $Label.text = scene_path.substr(scene_path.find_last("/") + 1, scene_path.find_last(".") - scene_path.find_last("/") - 1)
  
  if not should_show and scene != null:
    scene.queue_free()

func _process(delta):
  if Engine.editor_hint and is_selected():
    if Input.is_key_pressed(KEY_SPACE):
      if Input.is_key_pressed(KEY_SHIFT):
        permanent = false
        property_list_changed_notify()
      else:
        permanent = true
        property_list_changed_notify()

func _ready():
  if Engine.editor_hint:
    plugin.get_editor_interface().get_selection().connect("selection_changed", self, "on_select_change")
  
  if not Engine.editor_hint:
    yield(get_tree(), "idle_frame")
    
    var parent = get_parent()
    var index = get_position_in_parent()
    var position = self.position
    var new_scene = load(scene_path).instance()

    # new_scene.set_owner(self.owner)
    parent.remove_child(self)
    parent.add_child(new_scene)
    parent.move_child(new_scene, index)
    new_scene.position = position
    
    queue_free()
