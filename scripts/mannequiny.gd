class_name KnightSkin extends Node3D

#@onready var animation_tree = %AnimationTree
#@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
#
#func idle():
    #state_machine.travel('idle')
#
#func move():
    #state_machine.travel('run')
#
#func jump():
    #state_machine.travel('air_jump')
#
#func fall():
    #state_machine.travel('air_land')
