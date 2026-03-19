class_name Trigger
extends Area2D

@export var trigger_once : bool = true

var touching = false

signal triggered

func _process(_delta):
	for i in get_overlapping_bodies():
		if i.name.to_lower().contains("player"):
			if !touching:
				triggered.emit()
			touching = true
		elif !trigger_once:
			touching = false
