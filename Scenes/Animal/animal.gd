class_name Animal
extends RigidBody2D


#Enums
enum ANIMAL_STATE {READY, DRAG, RELEASE}

#Constants
const DRAG_LIM_MAX: Vector2 = Vector2(0,60)
const DRAG_LIM_MIN: Vector2 = Vector2(-60,0)

#Variables
@onready var on_screen_notifier: VisibleOnScreenNotifier2D = $OnScreenNotifier
@onready var label: Label = $Label

var _state: ANIMAL_STATE = ANIMAL_STATE.READY

var _start: Vector2 = Vector2.ZERO

var _drag_start: Vector2  = Vector2.ZERO

var _dragged_vector: Vector2 = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_start = position


func _physics_process(delta: float) -> void:
	#Esta funcion va actualizar lo que hace el animal
	update(delta)
	label.text = "%s \n" % ANIMAL_STATE.keys()[_state]
	label.text += "%.1f,%.1f" % [_dragged_vector.x, _dragged_vector.y]

func set_new_state(new_state: ANIMAL_STATE) -> void:
	#Esta funcion maneja el cambio de estado del animal
	_state = new_state
	if _state == ANIMAL_STATE.RELEASE:
		#Si es nuevo estado es RELEASE osea que lo solto
		#Entonces colocamos freeze en falso, para que el motor de fisicas
		#Tome control sobre el animal
		freeze = false
	elif _state == ANIMAL_STATE.DRAG:
		_drag_start = get_global_mouse_position()

func detect_release() -> bool:
	#Esta funcion detecta si estamos en el estado de arrastrar y si se suelta el mouse
	if _state == ANIMAL_STATE.DRAG:
		if Input.is_action_just_released("drag"):
			set_new_state(ANIMAL_STATE.RELEASE)
			return true
	return false

func get_dragged_vector(gmp: Vector2) -> Vector2:
	return get_global_mouse_position() - _drag_start

func drag_in_limits() -> void:
	
	_dragged_vector.x = clampf(_dragged_vector.x, DRAG_LIM_MIN.x, DRAG_LIM_MAX.x)
	_dragged_vector.y = clampf(_dragged_vector.y, DRAG_LIM_MIN.y, DRAG_LIM_MAX.y)
	
	position = _start + _dragged_vector


func update_drag() -> void:
	#Actualiza la posicion del animal a la posicion del mouse
	if detect_release() == true:
		return
	var gmp = get_global_mouse_position()
	_dragged_vector = get_dragged_vector(gmp)
	drag_in_limits()

func update(delta: float) -> void:
	#Actualiza que hace el animal segun su estado
	match  _state:
		ANIMAL_STATE.DRAG:
			update_drag()

func _on_screen_exited() -> void:
	#Cuando el animal sale de la pantalla lo despawneamos
	despawn()

func despawn() -> void:
	#Emitimos la señal de que el animal murio
	SignalManager.on_animal_died.emit()
	set_process(false)
	queue_free()

#Señal que detecta inputs de mouse
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#Aca basicamente estamos comprobando que el estado sea READY
	#Y que si tambien el evento de la señal es drag, entonces queremos cambiar
	#El estadoa a drag
	if _state == ANIMAL_STATE.READY and event.is_action_pressed("drag"):
		set_new_state(ANIMAL_STATE.DRAG)
