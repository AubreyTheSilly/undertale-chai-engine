class_name Metronome
extends Node

@export var bpm := 120.0
@export var steps := 4

var running := false
var beat_timer := 0.0
var step_timer := 0.0

signal beat
signal step

var cur_beat := 0
var cur_step := 0

func calculateBeatLength() -> float:
	return (bpm/60)

func calculateStepLength() -> float:
	return (bpm/60)/steps

func _process(_delta) -> void:
	if running:
		beat_timer += _delta
		step_timer += _delta
		
		if beat_timer >= calculateBeatLength():
			beat_timer -= calculateBeatLength()
			cur_beat += 1
			beat.emit(cur_beat)
		if step_timer >= calculateStepLength():
			step_timer -= calculateStepLength()
			cur_step += 1
			step.emit(cur_step)
	else:
		beat_timer = 0
		step_timer = 0
		cur_beat = 0
		cur_step = 0
