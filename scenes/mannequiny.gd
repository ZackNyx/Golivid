class_name KnightSkin extends Node3D

@onready var animation_tree = %AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
@onready var move_tilt_path : String = "parameters/StateMachine/Move/tilt/add_amount"

func idle():
    state_machine.travel("idle")

func move():
    state_machine.travel("run")

func fall():
    state_machine.travel("air_land")

func jump():
    state_machine.travel("air_jump")

func dash():
    state_machine.travel("dash")
