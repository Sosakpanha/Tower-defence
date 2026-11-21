## Tells the game when the app goes to the background (phone) so it can pause.
class_name AppLifecycle
extends Node

signal backgrounded


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED:
			backgrounded.emit()
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			if OS.has_feature("mobile"):  # on desktop, losing focus must not pause
				backgrounded.emit()
