extends CharacterBody3D

@export_group('Camera')
@export_range(0.0, 1.0) var mouse_sensitivity := .25
@export_group('Movement')
@export var move_speed := 8.0
@export var acceleration := 30.0
@export var rotation_speed := 5.0
@export var jump_impulse := 20.0
@export var _gravity := -50.0

var _camera_input_direction := Vector2.ZERO
var _last_move_direction := Vector3.BACK

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin: GobotSkin = %GobotSkin


func _input(event: InputEvent) -> void:
    if event.is_action_pressed('left_click'):
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    if event.is_action_pressed('ui_cancel'):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
    var is_camera_motion := (
        event is InputEventMouseMotion and
        Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
    )
    
    if is_camera_motion:
        _camera_input_direction = event.screen_relative * mouse_sensitivity

func _physics_process(delta: float) -> void:
    ## Camera
    # Vertical camera movement. Clamped to prevent flipping
    _camera_pivot.rotation.x += _camera_input_direction.y * delta
    _camera_pivot.rotation.x = clamp(
        _camera_pivot.rotation.x,
        -PI/6, PI/3
    )
    # Horizontal camera movement
    _camera_pivot.rotation.y -= _camera_input_direction.x * delta
    
    _camera_input_direction = Vector2.ZERO
    
    ## Movement
    var raw_input := Input.get_vector('move_left', 'move_right',
    'move_forward', 'move_backward')
    var forward := _camera.global_basis.z
    var right := _camera.global_basis.x
    
    var move_direction := forward * raw_input.y + right * raw_input.x
    move_direction.y = 0.0
    move_direction = move_direction.normalized()

    var y_velocity := velocity.y
    velocity.y = 0.0
    velocity = velocity.move_toward(
        move_direction * move_speed, acceleration * delta)
    velocity.y = y_velocity + _gravity * delta
    
    # Jumping
    var is_starting_jump := Input.is_action_just_pressed('jump') and is_on_floor()
    if is_starting_jump:
        velocity.y += jump_impulse
    
    # Rolling
    var is_starting_roll := Input.is_action_just_pressed('roll') and is_on_floor()
    if is_starting_roll:
        pass
    
    move_and_slide()
    
    ## Animation
    # Character rotation
    if move_direction.length() > 0.1:
        _last_move_direction = move_direction
        
        # Calculate target rotation in global space
        var target_rotation := atan2(_last_move_direction.x, _last_move_direction.z)
        
        # lerp the skin's rotation
        _skin.global_rotation.y = lerp_angle(
            _skin.global_rotation.y,
            target_rotation,
            rotation_speed * delta
        )
    
    # Movement animations
    if is_starting_jump:
        _skin.jump()
    elif not is_on_floor() and velocity.y < 0:
        _skin.fall()
    elif is_on_floor():
        if move_direction.length() > 0.0:
            _skin.run()
        else:
            _skin.idle()
    
    
