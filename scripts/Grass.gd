extends BaseHittableArea

var grassMaterial = null

onready var mat = load("res://assets/shaders/WindSwept.tres")

func set_shaders(shader):
  $Sprite.set_material(shader)

func _init().():
  self.health = 1
  self.hit_sfx = "Bush"
  
func _ready():
  set_shaders(mat.duplicate())
  
  grassMaterial = $Sprite.material
  grassMaterial.set_shader_param("global_xy", global_position)
