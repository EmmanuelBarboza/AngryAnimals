class_name Animal
extends RigidBody2D

@onready var on_screen_notifier: VisibleOnScreenNotifier2D = $OnScreenNotifier

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_screen_exited() -> void:
	print("Despawning")
	set_process(false)
	queue_free()
