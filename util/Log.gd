class_name Log

func start(_function_name: String) -> void:
    pass

func end() -> void:
    pass

func set_log_level(_level: String = "") -> void:
    pass

func info(_message: String, _function_name: String = "") -> void:
    pass

func debug(_message: String, _function_name: String = "") -> void:
    pass

func warn(_message: String, _function_name: String = "") -> void:
    pass

func error(_message: String, _function_name: String = "") -> void:
    pass

func check_error_code(
        _error_code: int,
        _action_description: String = "",
        _function_name: String = "") -> void:
    pass
