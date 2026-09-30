@tool
extends EditorPlugin
var exporter
class SafeExport extends EditorExportPlugin:
 func _get_name():return "CinderBannerSafe"
 func _supports_platform(platform):return platform is EditorExportPlatformAndroid
 func _get_android_libraries(_platform,_debug):return PackedStringArray(["res://addons/banner_safe/banner-safe.aar"])
func _enter_tree():
 exporter=SafeExport.new();add_export_plugin(exporter)
func _exit_tree():remove_export_plugin(exporter)
