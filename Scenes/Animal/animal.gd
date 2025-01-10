class_name Animal
extends RigidBody2D

#Variables
@onready var on_screen_notifier: VisibleOnScreenNotifier2D = $OnScreenNotifier

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	pass

func _on_screen_exited() -> void:
	#Cuando el animal sale de la pantalla lo despawneamos
	despawn()


func despawn() -> void:
	#Emitimos la señal de que el animal murio
	SignalManager.on_animal_died.emit()
	set_process(false)
	queue_free()
