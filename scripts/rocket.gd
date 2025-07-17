extends RigidBody3D


func _physics_process(delta: float) -> void:
    set_rotation(Vector3(rotation.x, rotation.y, linear_velocity.z))
