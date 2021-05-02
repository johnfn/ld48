extends BaseHittableArea

var grassMaterial = null

func _init().():
  self.health = 1
  self.hit_sfx = "Bush"
  
func _ready():
  grassMaterial = $Sprite.material
  grassMaterial.set_shader_param("global_xy", global_position)

