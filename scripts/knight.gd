extends CharacterBody3D

@export_group('Camera')
@export var camera_pivot: Node3D
@export var camera: Camera3D
@export_range(0.0, 1.0) var mouse_sensitivity := .25
@export_group('Movement')
@export var move_speed := 8.0
@export var acceleration := 40.0
@export var rotation_speed := 7.0
@export var jump_impulse := 20.0
@export var _gravity := -50.0
@export var roll_speed := 15.0
@export var grapple_speed := 15.0
@export_group('Stats')
@export var max_health := 20
@export var health := 20
@export var has_hammer := true
@export var rockets := 5
@export var max_grapples := 1000
@export var grapples := 1000

var _camera_input_direction := Vector2.ZERO
var _last_move_direction := Vector3.BACK
var is_rolling := false
var is_grappling := false
var grapple_target: Vector3
var grapple_direction: Vector3

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %KnightCamera
@onready var _skin: GobotSkin = %GobotSkin
@onready var roll_timer: Timer = %RollTimer
@onready var roll_cooldown: Timer = %RollCooldown
@onready var grapple_cast: RayCast3D = %GrappleCast

func _input(event: InputEvent) -> void:
    if event.is_action_pressed('left_click'):
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    if event.is_action_pressed('ui_cancel'):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event: InputEvent) -> void:
    # This checks whether or not the game should move the camera
    # based on if the mouse is moving (InputEventMouseMotion) and
    # if the mouse is active (Input.MOUSE_MODE_CAPTURED)
    var is_camera_motion := (
        event is InputEventMouseMotion and
        Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
    )
    
    if is_camera_motion:
        _camera_input_direction = event.screen_relative * mouse_sensitivity
    
    if event.is_action_pressed('roll') and is_on_floor() and !(0 < roll_cooldown.time_left and roll_cooldown.time_left < roll_cooldown.wait_time):
        is_rolling = true
    
    if event.is_action_pressed('grapple') and grapple_cast.is_colliding() and grapples > 0:
        grapple_target = grapple_cast.get_collision_point()
        is_grappling = true
        grapples -= 1
    
    if event.is_action_released('grapple'):
        is_grappling = false


func _physics_process(delta: float) -> void:
    ## Camera
    # Vertical camera movement. Clamped to prevent flipping
    _camera_pivot.rotation.x += _camera_input_direction.y * delta
    _camera_pivot.rotation.x = clamp(
        _camera_pivot.rotation.x,
        -(2*PI)/5, PI/3
    )
    # Horizontal camera movement
    _camera_pivot.rotation.y -= _camera_input_direction.x * delta
    
    # Resets camera input direction so that the camera
    # doesn't keep moving infinitely.
    _camera_input_direction = Vector2.ZERO 
    
    
    ## Physics
    # Movement logic
    var raw_input := Input.get_vector('move_left', 'move_right',
    'move_forward', 'move_backward')
    var forward := _camera.global_basis.z
    var right := _camera.global_basis.x
    
    var move_direction := forward * raw_input.y + right * raw_input.x
    move_direction.y = 0.0
    move_direction = move_direction.normalized()
    
    var y_velocity := velocity.y
    
    
    if is_rolling:
        if roll_timer.time_left == 0:
            roll_timer.start()
        if roll_timer.time_left == roll_timer.wait_time:
            _skin.edge_grab()
        velocity.y = 0.0
        velocity = _last_move_direction * roll_speed
        velocity.y = y_velocity + _gravity * delta
    elif is_grappling:
        grapple_direction = (grapple_target - transform.origin) * grapple_speed
        if transform.origin.distance_to(grapple_target) < 5:
            velocity = velocity.move_toward(grapple_direction, grapple_speed * (delta*8)*4)
        elif transform.origin.distance_to(grapple_target) < 2:
            velocity = velocity.move_toward(grapple_direction, grapple_speed * 4)
        else:
            velocity = velocity.move_toward(grapple_direction, grapple_speed * (delta*8)*2)
        if transform.origin.distance_to(grapple_target) < 1 and velocity.x < 5 and velocity.z < 5:
            is_grappling = false

    else: 
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
        
        velocity.y = 0.0
        velocity = velocity.move_toward(
            move_direction * move_speed, acceleration * delta)
        velocity.y = y_velocity + _gravity * delta
        
        # Jumping
        var is_starting_jump := Input.is_action_just_pressed('jump') and is_on_floor()
        if is_starting_jump:
            velocity.y += jump_impulse
        
        # Friction
        pass
        
        # Grappling
        var is_grappling := Input.is_action_pressed('grapple')
        if is_on_floor():
            grapples = 3
        
        ## Animation
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
        
    move_and_slide()


func _on_roll_timer_timeout() -> void:
    is_rolling = false
    roll_cooldown.start()
