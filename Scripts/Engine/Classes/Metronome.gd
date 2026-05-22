class_name Metronome
extends Node

@export var autostart = false

@export var bpm := 120.0
@export var beats := 4
@export var steps := 4

@export var playMetronomeSound := false

var running := false

signal beat
signal step

var cur_beat := 0
var cur_step := 0

# Track the absolute start time in seconds
var start_time : float = 0.0

@onready var startping := AudioStreamPlayer.new()
@onready var ping := AudioStreamPlayer.new()

func calculateBeatLength() -> float:
	return (60.0 / bpm)

func calculateStepLength() -> float:
	return calculateBeatLength() / steps

func _ready() -> void:
	add_child(ping)
	add_child(startping)
	
	ping.stream = preload("res://Audio/Sounds/snd_metronome.wav")
	startping.stream = preload("res://Audio/Sounds/snd_metronome_start.wav")
	
	if autostart:
		start()

func _init(Bpm:float, Beats:int, Steps:int, autoStart:=true, sound:=false):
	bpm = Bpm
	beats = Beats
	steps = Steps
	autostart = autoStart
	playMetronomeSound = sound

func start() -> void:
	# Store the absolute start time using the highly accurate system tick
	start_time = float(Time.get_ticks_usec()) / 1000000.0
	running = true
	
	# Trigger the very first beat immediately on start
	cur_beat = 0
	cur_step = 0
	if playMetronomeSound:
		startping.play()
	beat.emit(cur_beat)
	step.emit(cur_step)

func stop() -> void:
	running = false

func _process(_delta) -> void:
	if not running:
		return

	# 1. Get the current absolute time and find total elapsed time since start
	var current_time : float = float(Time.get_ticks_usec()) / 1000000.0
	var elapsed_time : float = current_time - start_time
	
	# 2. Calculate exactly how many beats and steps SHOULD have occurred by now
	var beat_length := calculateBeatLength()
	var step_length := calculateStepLength()
	
	var expected_beat := int(elapsed_time / beat_length)
	var expected_step := int(elapsed_time / step_length)
	
	# 3. Catch up if the absolute time has crossed into a new beat
	while cur_beat < expected_beat:
		cur_beat += 1
		if playMetronomeSound:
			# Use cur_beat to determine if it's the downbeat (0, 4, 8, etc.)
			if cur_beat % beats == 0:
				startping.play()
			else:
				ping.play()
		beat.emit(cur_beat)
		
	# 4. Catch up if the absolute time has crossed into a new step
	while cur_step < expected_step:
		cur_step += 1
		step.emit(cur_step)
