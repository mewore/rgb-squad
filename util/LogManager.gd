extends Node

# Source:
# https://github.com/ivanskodje-godotengine/godot-logging-util
# But with some modifications

const ENABLE_LOGGING: bool = true
const LOG_TO_FILE: bool = true # ENABLE_LOGGING must be enabled
const DEFAULT_LOG_PATH: String = "res://logs/"
const DEFAULT_LOG_NAME: String = "logger"
var START_TIME: Dictionary = OS.get_datetime()

# Use this on each script you wish to use the Logger
func get_log(object, log_path: String = DEFAULT_LOG_PATH, log_file: String = DEFAULT_LOG_NAME) -> Log:
    if not OS.is_debug_build() or not ENABLE_LOGGING:
        return DummyLog.new()
    return RealLog.new(LogSettings.new(object, log_path, log_file))

#####################
######## Log ########
#####################
# TODO: Move this to a separate file eventually

class LogSettings:
    var prefix: String
    var script_name: String
    var prefix_node: Node
    
    var file_writer: IFileWriter
    
    func _init(object, log_path: String, log_file: String) -> void:
        if object is String:
            self.prefix = object
        elif object is Object:
            var script_path: String = object.get_script().resource_path
            self.script_name = script_path.substr(script_path.find_last("/") + 1)
            if object is Node:
                _determine_prefix_based_on_node(object)
            else:
                self.prefix = self.script_name
        else:
            self.prefix = str(object)
        
        if LOG_TO_FILE:
            self.file_writer = FileWriter.new(log_path, log_file)
        else:
            self.file_writer = DummyFileWriter.new()
    
    func _determine_prefix_based_on_node(node: Node) -> void:
        self.prefix_node = node
        _refresh_prefix_with_node()
        if node.name:
            return
        
        yield(node, "ready")
        self._refresh_prefix_with_node()
        var error: int = node.connect("renamed", self, "_on_prefix_node_renamed")
        if error != OK:
            printerr("Error [%d] when connecting to the 'renamed' signal of node '%s'" %
                [error, node.name])
    
    func _on_prefix_node_renamed() -> void:
        self._refresh_prefix_with_node()
    
    func _refresh_prefix_with_node(node: Node = self.prefix_node) -> void:
        self.prefix = self._get_node_prefix(node)
    
    func _get_node_prefix(node: Node) -> String:
        if not node:
            return self.script_name
            
        if not node.name:
            return "... (%s)" % self.script_name
            
        if not node.owner or not node.owner.name:
            return "%s (%s)" % [node.name, self.script_name]
            
        return "%s:%s (%s)" % [node.owner.name, node.name, self.script_name]

class RealLog:
    extends Log
    
    # GLOBAL DEFAULT LOGGING CONFIGURATION
    # - This can be overridden within each script that utilizes the log tool.
    var LEVEL_MAP: Dictionary = {
        LEVEL_TRACE: 1,
        LEVEL_DEBUG: 2,
        LEVEL_INFO: 3,
        LEVEL_WARN: 4,
        LEVEL_ERROR: 5,
    }
    
    var trace_logging: bool = true
    var debug_logging: bool = true
    var info_logging: bool = true
    var warn_logging: bool = true
    var error_logging: bool = true
    
    # LOGGING 
    const LOG_FORMAT: String = \
        "[{current_time}] | {level} | [{prefix}] [{function_name}] >> {message}"
    const DATE_TIME_FORMAT: String = "{year}.{month}.{day} {hour}:{minute}:{second}";
    const DATE_TIME_PADDING: int = 2;
    
    const LEVEL_TRACE: String = "TRACE"
    const LEVEL_DEBUG: String = "DEBUG"
    const LEVEL_INFO: String = "INFO"
    const LEVEL_WARN: String = "WARN"
    const LEVEL_ERROR: String = "ERROR"
    
    const DEFAULT_LOG_LEVEL: String = LEVEL_INFO
    
    # Logger script name
    var settings: LogSettings
    var current_function_name: String = ""
    
    var file_writer: IFileWriter
    
    # Initializes the logger with the script name that is using it
    func _init(initial_settings: LogSettings) -> void:
        self.settings = initial_settings
        self.file_writer = settings.file_writer
        self.set_log_Level(DEFAULT_LOG_LEVEL)
    
    # Used to set function name at the beginning of each function, 
    # in order to populate the logger with function name
    func start(function_name) -> void:
        current_function_name = function_name
    
    func end() -> void:
        current_function_name = ""
    
    func set_log_Level(log_level: String) -> void:
        var log_level_numeric: int = LEVEL_MAP[log_level]
        self.trace_logging = LEVEL_MAP[LEVEL_TRACE] >= log_level_numeric
        self.debug_logging = LEVEL_MAP[LEVEL_DEBUG] >= log_level_numeric
        self.info_logging = LEVEL_MAP[LEVEL_INFO] >= log_level_numeric
        self.warn_logging = LEVEL_MAP[LEVEL_WARN] >= log_level_numeric
        self.error_logging = LEVEL_MAP[LEVEL_ERROR] >= log_level_numeric
    
    # TODO: Just get the function name (and line) from the stack.
        
    func trace(message: String, function_name: String = "") -> void:
        if trace_logging:
            _log(LEVEL_TRACE, message, function_name)
        
    func debug(message: String, function_name: String = "") -> void:
        if debug_logging:
            _log(LEVEL_DEBUG, message, function_name)
    
    func info(message: String, function_name: String = "") -> void:
        if info_logging:
            _log(LEVEL_INFO, message, function_name)

    func warn(message: String, function_name: String = "") -> void:
        if warn_logging:
            _log(LEVEL_WARN, message, function_name)
        
    func error(message: String, function_name: String = "") -> void:
        if error_logging:
            _log(LEVEL_ERROR, message, function_name)    

    func check_error_code(
            error_code: int,
            action_description: String = "",
            function_name: String = "") -> void:
        if error_logging and error_code != OK:
            var action_description_phase: String = \
                "the following action: %s" % action_description if action_description \
                else "an unknown action"
            var message: String = \
                "Encountered ERROR [%d] while performing the %s" % \
                [error_code, action_description_phase]
            
            _log(LEVEL_ERROR, message, function_name)
        assert(error_code == OK)
    
    func _log(level: String, message: String, function_name: String = "") -> void:
        if not function_name:
            function_name = current_function_name
        var log_message: String = LOG_FORMAT.format({
            "level": level,
            "current_time": _get_current_time(),
            "prefix": self.settings.prefix, 
            "function_name": function_name,
            "message": message
        })
        if level == LEVEL_ERROR:
            push_error(log_message)
            log_message += "\n" + _get_stack_string()
            printerr(log_message)
        elif level == LEVEL_WARN:
            push_warning(log_message)
            log_message += "\n" + _get_stack_string()
            printerr(log_message)
        else:
            print(log_message)
        file_writer.write(log_message)
    
    func _get_current_time() -> String:
        var date_time: Dictionary = OS.get_datetime()
        _pad_zeros_in_dictionary(date_time, DATE_TIME_PADDING)
        return DATE_TIME_FORMAT.format(date_time)
    
    func _pad_zeros_in_dictionary(dictionary: Dictionary, padding: int) -> void:
        for key in dictionary:
            dictionary[key] = str(dictionary[key]).pad_zeros(padding)
    
    func _get_stack_string() -> String:
        var stack: Array = get_stack()

        var first_non_log_frame: int = 0
        # TODO: Use a smarter approach for this comparison. self.get_script().resource_path
        # does not work.
        while first_non_log_frame < stack.size() \
            and stack[first_non_log_frame].source.ends_with("LogManager.gd"):
            first_non_log_frame += 1
        
        var frame_strings: Array = []
        var start_index: int = 0 if first_non_log_frame == stack.size() else first_non_log_frame
        for i in range(start_index, stack.size()):
            frame_strings.append("\tat [Frame %d] - %s:%s in function '%s'%s" % 
                [i, stack[i].source, stack[i].line, stack[i].function,
                " <---" if i == start_index else ""])

        return PoolStringArray(frame_strings).join("\n")


# DummyLog prevents logging when we have disabled logging.
# An efficient way to disable functionality without affecting performance or having to make code changes.
class DummyLog:
    extends Log

    func check_error_code(
            error_code: int,
            _message: String = "",
            _function_name: String = "") -> void:
        assert(error_code == OK)

############################
######## FileWriter ########
############################
# TODO: Move this to a separate file eventually

class IFileWriter:
    func write(_log_line: String) -> void:
        pass


class FileWriter:
    extends IFileWriter

    const DATE_TIME_FORMAT: String = "{year}-{month}-{day}-{hour}-{minute}-{second}"
    const DATE_TIME_PADDING: int = 2
    
    var file: File = null
    var full_file_path: String = ""
    
    func _init(file_path: String, file_name: String) -> void:
        self.full_file_path = file_path  + _get_game_start_time() + "-" + file_name + ".log"
        self.file = File.new()
    
    func _create_file_if_not_exist() -> void:
        if not file.file_exists(full_file_path):
            var error: int = file.open(full_file_path, File.WRITE)
            if error != OK:
                printerr("Error [%d] when creating file %s" % [error, full_file_path])
            file.close()
    
    func write(log_line: String) -> void:
        _create_file_if_not_exist()

        var error: int = self.file.open(full_file_path, File.READ_WRITE)
        if error != OK:
            printerr("Error [%d] when opening file %s" % [error, full_file_path])
        self.file.seek_end()
        self.file.store_line(log_line + "\n\r")
        self.file.close()
    
    func _get_game_start_time() -> String:
        var date_time: Dictionary = LogManager.START_TIME
        _pad_zeros_in_dictionary(date_time, DATE_TIME_PADDING)
        return DATE_TIME_FORMAT.format(date_time)
    
    func _pad_zeros_in_dictionary(dictionary: Dictionary, padding: int) -> void:
        for key in dictionary:
            dictionary[key] = str(dictionary[key]).pad_zeros(padding)


# DummyFileWriter prevents writing a file when we have disabled file writing.
# An efficient way to disable functionality without affecting performance or having to make code changes.
class DummyFileWriter:
    extends IFileWriter
