# tool
extends Node2D

export(bool) var solid_leaves = true
export(bool) var fake_tree = false

const MAX_OPACITY = 0.6

onready var mat = load("res://assets/shaders/WindSwept.tres")

func set_shaders(shader):
  $Trunk.set_material(shader)
  $Leaves.set_material(shader)
  $Shadow.set_material(shader)

func _process(_delta):
  if Engine.editor_hint:
    #we need to do this b/c otherwise this destroys grant's CPU
    set_shaders(null)
    
    if fake_tree:
      modulate = Color(1.0, 0.5, 0.5, 1.0)
    else:
      modulate = Color(1.0, 1.0, 1.0, 1.0)

func _ready():
  modulate = Color(1.0, 1.0, 1.0, 1.0)
  
  if Engine.editor_hint:
    return
  
  set_shaders(mat)
  
  if fake_tree:
    $Tree/FullHitbox.queue_free()
    $TreeTrunk.queue_free()
    $Trunk.queue_free()
    
    var _unused = $LeafArea.connect("body_entered", self, "_on_body_entered")
    _unused = $LeafArea.connect("body_exited", self, "_on_body_exited")
  elif solid_leaves:
    $TreeTrunk/TrunkHitbox.queue_free()

    $LeafArea.queue_free()
  else:
    $Tree/FullHitbox.queue_free()
    var _unused = $LeafArea.connect("body_entered", self, "_on_body_entered")
    _unused = $LeafArea.connect("body_exited", self, "_on_body_exited")
  
  var trunkMaterial = $Trunk.material
  var leavesMaterial = $Leaves.material
  var shadowMaterial = $Shadow.material
  
  trunkMaterial.set_shader_param("global_xy", global_position)
  leavesMaterial.set_shader_param("global_xy", global_position)
  shadowMaterial.set_shader_param("global_xy", global_position)
  

func _on_body_entered(body):
  if body.has_method("is_player") and body.is_player():
    $Tween.interpolate_property($Leaves, "modulate", Color.white, Color(1, 1, 1, MAX_OPACITY), 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
    $Tween.start()

func _on_body_exited(body):
  if body.has_method("is_player") and body.is_player():
    $Tween.interpolate_property($Leaves, "modulate", Color(1, 1, 1, MAX_OPACITY), Color.white, 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
    $Tween.start()
