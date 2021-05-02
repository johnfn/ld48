extends BaseHittable

func _init().():
  self.health = 1
  self.hit_sfx = "Bush"
  
  
func _ready():
  var shrubMaterial = $Sprite.material
  material.set_shader_param("global_xy", global_position)
