extends Node2D

#Variables
@onready var animal_start: Marker2D = $AnimalStart
@onready var respawn_timer: Timer = $AnimalRespawn

#Constantes
const ANIMAL: PackedScene = preload("res://Scenes/Animal/animal.tscn")





func _ready() -> void:
	#Conectamos el nivel al signal manager, especificamente a la señal
	#Que se emite cuando un Animal muere (despawnea)
	SignalManager.on_animal_died.connect(_on_animal_died)
	#Spawneamos un animal al inicio
	spawn_animal()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_animal_died() -> void:
	#Iniciamos un temporizador
	respawn_timer.start()

func _on_animal_respawn_timeout() -> void:
	#Cuando el temporizador se le acaba el tiempo spawneamos un animal
	spawn_animal()

func spawn_animal() -> void:
	#Instanciamos al animal
	var new_animal = ANIMAL.instantiate()
	#Colocamos su posicion
	new_animal.global_position = animal_start.global_position
	#Lo añadimos al arbol
	self.add_child(new_animal)
