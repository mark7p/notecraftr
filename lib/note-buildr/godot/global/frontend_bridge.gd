extends Node

signal on_frontend_message(data)
signal send_to_frontend(data)
var _callback_ref = JavaScriptBridge.create_callback(_message_handler)


func _ready() -> void:
	_initialize_listeners()


func _initialize_listeners():
	if not OS.is_debug_build():
		# Create variable in window to hold message data
		JavaScriptBridge.eval("var frontend_message = null;", true)

		var window = JavaScriptBridge.get_interface("window")
		window.addEventListener('frontendMessage', _callback_ref)

		send_to_frontend.connect(_send_to_frontend)


func _message_handler(args):
	var message_json = JavaScriptBridge.eval("frontend_message", true)
	var message = JSON.parse_string(message_json)
	on_frontend_message.emit(message)


func _send_to_frontend(data):
	var window = JavaScriptBridge.get_interface("window")
	var data_string = JSON.stringify(data)
	JavaScriptBridge.eval("window.dispatchEvent(new CustomEvent('godotMessage', { payload: " + data_string + "}))")