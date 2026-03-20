class_name Trigger
extends Area2D

@export var trigger_once : bool = true

var touching = false

signal triggered

func _ready() -> void:
	triggered.connect(_triggered)

func _process(_delta) -> void:
	for i in get_overlapping_bodies():
		if i is Player:
			if !touching:
				triggered.emit()
			touching = true
		elif !trigger_once:
			touching = false

func _triggered() -> void:
	pass
