@autoload
export class TestClass extends Node2D {
  constructor() {
    super()

    this.get_node_safe("/root/Node2D/Label").text = "This is a game!"
  }
}

export const Test = new TestClass()
