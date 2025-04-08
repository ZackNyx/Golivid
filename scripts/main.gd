extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

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
    if Input.is_action_just_pressed('DEBUG_RESTART'):
        reload_current_scene()
