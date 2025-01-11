class_name Animal
extends RigidBody2D


#Enums
enum ANIMAL_STATE {READY, DRAG, RELEASE}

#Constants
const DRAG_LIM_MAX: Vector2 = Vector2(0,60)
const DRAG_LIM_MIN: Vector2 = Vector2(-60,0)
const IMPULSE_MULT: float = 20.0
const IMPULSE_MAX: float = 1200.0

#Referencias
@onready var on_screen_notifier: VisibleOnScreenNotifier2D = $OnScreenNotifier
@onready var label: Label = $Label
@onready var stretch_sound: AudioStreamPlayer2D = $StretchSound
@onready var arrow: Sprite2D = $Arrow
@onready var launch_sound: AudioStreamPlayer2D = $LaunchSound


@onready var sprite_start: Sprite2D = $Sprite2D2
@onready var sprite_drag_start: Sprite2D = $Sprite2D3
@onready var sprite_dragged_vector: Sprite2D = $Sprite2D4
@onready var sprite_last_dragged: Sprite2D = $Sprite2D5

#Variables
var _state: ANIMAL_STATE = ANIMAL_STATE.READY
var _start: Vector2 = Vector2.ZERO
var _drag_start: Vector2  = Vector2.ZERO
var _dragged_vector: Vector2 = Vector2.ZERO
var _last_dragged_vector: Vector2 = Vector2.ZERO
var _arrow_scale_x: float = 0.0




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_arrow_scale_x = arrow.scale.x #Escala base de la flecha
	arrow.hide()
	_start = position


func _physics_process(delta: float) -> void:
	#Esta funcion va actualizar lo que hace el animal
	
	update(delta)
	label.text = "%s \n" % ANIMAL_STATE.keys()[_state]
	label.text += "%.1f,%.1f" % [_dragged_vector.x, _dragged_vector.y]
	show_vectors()
	

func get_impulse() -> Vector2:
	#Esta funcion devuelve un vector2, que basicamente es el vector
	#de cuanto arrastramos al animal, lo multiplicamos por -1
	#para darle la vuelta y asi tener un vector que indica una direccion
	return _dragged_vector * -1 * IMPULSE_MULT

func show_vectors() -> void:
	sprite_start.global_position = _start
	sprite_drag_start.global_position = _drag_start
	sprite_dragged_vector.position = _dragged_vector 
	sprite_last_dragged.position = _last_dragged_vector

func set_release() -> void:
	arrow.hide()
	freeze = false
	apply_central_impulse(get_impulse())
	launch_sound.play()

func set_drag() -> void:
	_drag_start = get_global_mouse_position()
	arrow.show()

func set_new_state(new_state: ANIMAL_STATE) -> void:
	#Esta funcion maneja el cambio de estado del animal
	_state = new_state
	if _state == ANIMAL_STATE.RELEASE:
		#Si es nuevo estado es RELEASE osea que lo solto
		#Entonces colocamos freeze en falso, para que el motor de fisicas
		#Tome control sobre el animal 
		#(DENTRO DE SET_RELEASE())
		set_release()
	elif _state == ANIMAL_STATE.DRAG:
		set_drag()


func detect_release() -> bool:
	#Esta funcion detecta si estamos en el estado de arrastrar y si se suelta el mouse
	if _state == ANIMAL_STATE.DRAG:
		if Input.is_action_just_released("drag"):
			set_new_state(ANIMAL_STATE.RELEASE)
			return true
	return false

func scale_arrow() -> void:
	#Esta variable contiene la magnitud del vector obtenido de get_impulse()
	#usamos length para obtener la magnitud de este
	var imp_length = get_impulse().length()
	#Esta variable reprensta un porcentaje de cuanto queremos escalar la flecha
	var perc = imp_length / IMPULSE_MAX
	
	arrow.scale.x = (_arrow_scale_x * perc) + _arrow_scale_x
	
	arrow.rotation = (_start - position).angle()

func play_stretch_sound() -> void:
	if(_last_dragged_vector -_dragged_vector).length() > 0:
		if stretch_sound.playing == false:
			stretch_sound.play()

func get_dragged_vector(_gmp: Vector2) -> Vector2:
	return get_global_mouse_position() - _drag_start

func drag_in_limits() -> void:
	
	_last_dragged_vector = _dragged_vector
	
	_dragged_vector.x = clampf(_dragged_vector.x, DRAG_LIM_MIN.x, DRAG_LIM_MAX.x)
	_dragged_vector.y = clampf(_dragged_vector.y, DRAG_LIM_MIN.y, DRAG_LIM_MAX.y)
	
	position = _start + _dragged_vector


func update_drag() -> void:
	#Actualiza la posicion del animal a la posicion del mouse
	if detect_release() == true:
		return
	var gmp = get_global_mouse_position()
	_dragged_vector = get_dragged_vector(gmp)
	play_stretch_sound()
	drag_in_limits()
	scale_arrow()

func update(_delta: float) -> void:
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
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	#Aca basicamente estamos comprobando que el estado sea READY
	#Y que si tambien el evento de la señal es drag, entonces queremos cambiar
	#El estadoa a drag
	if _state == ANIMAL_STATE.READY and event.is_action_pressed("drag"):
		set_new_state(ANIMAL_STATE.DRAG)
