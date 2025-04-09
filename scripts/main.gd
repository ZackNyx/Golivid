extends Node3D


var desktop_viewport: Viewport
var vr_viewport: Viewport

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass
    #desktop_viewport = %DesktopViewport
    #vr_viewport = %VRViewport
    #
    #var desktop_camera = %PlayerCamera
    #desktop_viewport.set_camera(desktop_camera)
    #
    #var vr_camera = %VRViewport
    #vr_viewport.set_camera(vr_camera)
    

func reload_current_scene():
    # Get the current scene's file path
    var current_scene = get_tree().current_scene
    var scene_path = current_scene.scene_file_path
    
    # Delete the old scene
    current_scene.queue_free()
    
    # Load and instantiate the new scene
    var new_scene = load(scene_path).instantiate()
    get_tree().root.add_child(new_scene)
    get_tree().current_scene = new_scene
    
    

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    # Restart functionality
    if Input.is_action_just_pressed('DEBUG_RESTART'):
        reload_current_scene()
    
    #desktop_viewport.update()
    #vr_viewport.update()
    
