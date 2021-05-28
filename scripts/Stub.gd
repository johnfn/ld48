tool
extends Sprite

# TODO: Render under (0, 0)

export var done = false
export var scene_path = ""

func get_all_nodes(node):
  var list = []
  
  for child in node.get_children():
    if child.get_child_count() > 0:
      list += get_all_nodes(child)
    list.push_back(child)
  
  return list

func get_dimensions(node) -> Rect2:
  var all_nodes = get_all_nodes(node)
  
  var top_left = null
  var bot_right = null
  
  for node in all_nodes:
    if node.name == "Tree78":
      var parent: Node2D = node
      
      var child = parent.get_child(0)
      
    if node is Sprite:
      var new_top_left = node.global_position
      var new_bot_right = node.global_position + node.texture.get_size()
  
      if top_left == null:
        top_left = new_top_left
        bot_right = new_bot_right
      else:
        top_left = Vector2(min(new_top_left.x, top_left.x), min(new_top_left.y, top_left.y))
        bot_right = Vector2(max(new_bot_right.x, bot_right.x), max(new_bot_right.y, bot_right.y))
  
  return Rect2(top_left, bot_right - top_left)

func render_scene_to_texture(scene_path: String):
  var scene = load(scene_path).instance()
  var viewport = Viewport.new()
  
  add_child(viewport)
  
  viewport.add_child(scene)
  
  var scene_dimensions = get_dimensions(scene)
  
  print(scene_dimensions)
  
  scene.position = Vector2.ZERO # - scene_dimensions.position * 2
  
  var f = ColorRect.new()
  f.rect_size = Vector2(50, 50)
  f.color = Color.red
  viewport.add_child(f)
  
  print("F position", f.rect_position)
  print("Scene position", scene.position)
  
  yield(get_tree(), "idle_frame")
  
  viewport.render_target_v_flip = true
  viewport.size = scene_dimensions.size
  viewport.render_target_update_mode = Viewport.UPDATE_ALWAYS

  # Wait for content
  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")

  var filename = "res://level_textures/" + scene_path.substr(scene_path.find_last("/") + 1, scene_path.find_last(".") - scene_path.find_last("/") - 1) + ".png"
  
  offset = - scene_dimensions.position
  centered = false
  
  viewport.get_texture().get_data().save_png(filename)
  
  var editor = EditorPlugin.new()
  var rf = editor.get_editor_interface().get_resource_filesystem()
  
  rf.scan()
  
  yield(rf, "resources_reimported")
  
  editor.queue_free()
  
  yield(get_tree(), "idle_frame")

  self.texture = load(filename)  
  
  # Cleanup
  
  scene.queue_free()
  viewport.queue_free()

func _ready():
  centered = true

func _process(delta: float):
  if not done and scene_path != "":
    done = true

    render_scene_to_texture(scene_path)
