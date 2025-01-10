extends Node2D


@onready var animal_start: Marker2D = $AnimalStart

const ANIMAL: PackedScene = preload("res://Scenes/Animal/animal.tscn")




func _ready() -> void:
	spawn_animal()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_animal() -> void:
	var new_animal = ANIMAL.instantiate()
	new_animal.global_position = animal_start.global_position
	self.add_child(new_animal)
