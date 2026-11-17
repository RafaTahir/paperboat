extends CanvasLayer
## Quiet menus kept outside the simulation pause.
signal begin_requested
signal pause_requested
signal resume_requested
signal restart_requested
signal recovery_requested
signal destination_requested
signal drift_requested
signal settings_changed

var music_level: float = 0.65
var effects_level: float = 0.75
var muted: bool = false
var reduced_motion: bool = false
var low_quality: bool = false
var panel: PanelContainer
var menu: VBoxContainer
var chapter: Label
var hint: Label
var toast: Label
var ending: VBoxContainer
var hud: Control
var mute_button: Button
var mode: String = "start"
var _toast_time: float = 0.0
var cream = Color("f4edda")
var teal = Color("153e3b")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	var theme = Theme.new()
	theme.default_font_size = 18
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color("c5b47e")
	normal.set_corner_radius_all(3)
	normal.content_margin_left = 22
	normal.content_margin_right = 22
	normal.content_margin_top = 10
	normal.content_margin_bottom = 10
	var hover = normal.duplicate()
	hover.bg_color = Color("e2d4a8")
	var focus = StyleBoxFlat.new()
	focus.bg_color = Color(0,0,0,0)
	focus.set_border_width_all(2)
	focus.border_color = cream
	focus.set_corner_radius_all(3)
	theme.set_stylebox("normal","Button",normal)
	theme.set_stylebox("hover","Button",hover)
	theme.set_stylebox("pressed","Button",hover)
	theme.set_stylebox("focus","Button",focus)
	theme.set_color("font_color","Button",teal)
	theme.set_color("font_hover_color","Button",teal)
	theme.set_color("font_pressed_color","Button",teal)
	theme.set_color("font_color","Label",cream)
	theme.set_color("font_color","CheckBox",cream)
	var clear=StyleBoxEmpty.new()
	theme.set_stylebox("normal","CheckBox",clear)
	theme.set_stylebox("hover","CheckBox",clear)
	theme.set_stylebox("pressed","CheckBox",clear)
	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = theme
	add_child(root)
	hud = Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(hud)
	chapter = _label("AFTER THE RAIN",20)
	chapter.position = Vector2(30,24)
	hud.add_child(chapter)
	var pause = _button("Pause  ·  Esc",func(): pause_requested.emit())
	pause.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	pause.position = Vector2(-193,22)
	hud.add_child(pause)
	hint = _label("WASD / arrows / left stick to guide   ·   Hold Space / south button for a breeze",16)
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	hint.position = Vector2(30,-42)
	hint.add_theme_color_override("font_shadow_color",Color("163332"))
	hint.add_theme_constant_override("shadow_offset_x",1)
	hint.add_theme_constant_override("shadow_offset_y",2)
	hud.add_child(hint)
	toast = _label("",20)
	toast.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	toast.position = Vector2(-250,-92)
	toast.custom_minimum_size.x = 500
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.add_theme_color_override("font_shadow_color",Color("163332"))
	toast.add_theme_constant_override("shadow_offset_y",2)
	root.add_child(toast)
	ending = VBoxContainer.new()
	ending.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	ending.position = Vector2(-310,-190)
	ending.add_theme_constant_override("separation",9)
	root.add_child(ending)
	ending.add_child(_label("Together, at last.",26))
	ending.add_child(_label("The courtyard is yours to linger in.",16))
	ending.add_child(_button("Keep drifting",func(): ending.hide(); drift_requested.emit()))
	ending.add_child(_button("Begin again",func(): restart_requested.emit()))
	ending.hide()
	panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-285,-285)
	panel.custom_minimum_size = Vector2(570,570)
	panel.resized.connect(func():
		if panel.get_parent() is Control:
			panel.position=panel.get_parent().size*.5-panel.size*.5)
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.045,0.14,0.135,0.95)
	bg.set_corner_radius_all(5)
	bg.content_margin_left = 44
	bg.content_margin_right = 44
	bg.content_margin_top = 28
	bg.content_margin_bottom = 28
	panel.add_theme_stylebox_override("panel",bg)
	root.add_child(panel)
	menu = VBoxContainer.new()
	menu.add_theme_constant_override("separation",11)
	panel.add_child(menu)
	show_menu("start")

func _label(text_value: String, size_value: int) -> Label:
	var label = Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size",size_value)
	label.add_theme_color_override("font_shadow_color",Color(.04,.12,.11,.7))
	label.add_theme_constant_override("shadow_offset_y",1)
	return label

func _button(text_value: String, callback: Callable) -> Button:
	var b = Button.new()
	b.text = text_value
	b.pressed.connect(callback)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return b

func show_menu(kind: String) -> void:
	mode = kind
	for c in menu.get_children():
		menu.remove_child(c)
		c.queue_free()
	panel.show()
	hud.visible = kind != "start"
	menu.add_child(_label("A SMALL JOURNEY IN A MALAYSIAN COURTYARD",12))
	menu.add_child(_label("AFTER THE RAIN" if kind == "start" else "A moment of stillness",36 if kind == "start" else 29))
	menu.add_child(_label("Find the little boat with stars like yours." if kind == "start" else "Your boat will wait here.",18))
	var lead = _button("Begin" if kind == "start" else "Resume",func():
		if mode == "start": begin_requested.emit()
		else: resume_requested.emit())
	menu.add_child(lead)
	menu.add_child(_label("WASD / arrows / left stick · Guide\nHold Space / south button · A little breeze\nRelease · Coast     Esc / Menu · Pause",16))
	var motion = CheckBox.new()
	motion.text = ("● " if reduced_motion else "○ ")+"Reduced camera motion"
	motion.button_pressed = reduced_motion
	motion.toggled.connect(func(v): reduced_motion=v; motion.text=("● " if v else "○ ")+"Reduced camera motion"; settings_changed.emit())
	menu.add_child(motion)
	var quality = CheckBox.new()
	quality.text = ("● " if low_quality else "○ ")+"Lower render resolution"
	quality.button_pressed = low_quality
	quality.toggled.connect(func(v): low_quality=v; quality.text=("● " if v else "○ ")+"Lower render resolution"; settings_changed.emit())
	menu.add_child(quality)
	_add_slider("Music",music_level,func(v): music_level=v; settings_changed.emit())
	_add_slider("Water & courtyard",effects_level,func(v): effects_level=v; settings_changed.emit())
	mute_button = _button("Sound: muted" if muted else "Sound: on",func():
		muted=not muted
		mute_button.text="Sound: muted" if muted else "Sound: on"
		settings_changed.emit())
	menu.add_child(mute_button)
	if kind != "start":
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation",10)
		menu.add_child(row)
		row.add_child(_button("Open water",func(): recovery_requested.emit()))
		row.add_child(_button("Begin again",func(): restart_requested.emit()))
		menu.add_child(_button("Show the sunny pool",func(): destination_requested.emit()))
	menu.add_child(_label("Original courtyard, paper craft & music · Made for this little journey",11))
	lead.call_deferred("grab_focus")

func _add_slider(title: String, value: float, cb: Callable) -> void:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation",18)
	var label = _label(title,16)
	label.custom_minimum_size.x = 165
	row.add_child(label)
	var slider = HSlider.new()
	slider.min_value=0.0
	slider.max_value=1.0
	slider.step=0.05
	slider.value=value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(cb)
	row.add_child(slider)
	menu.add_child(row)

func hide_menu() -> void:
	panel.hide()
	hud.show()

func say(message: String, seconds: float = 5.0) -> void:
	toast.text=message
	_toast_time=seconds
	toast.modulate.a=1.0

func show_ending() -> void:
	ending.show()

func reset_ui() -> void:
	ending.hide()
	hint.modulate.a=1.0
	chapter.text="AFTER THE RAIN"

func _process(delta: float) -> void:
	if _toast_time > 0:
		_toast_time -= delta
		toast.modulate.a = minf(1.0,_toast_time)

func _input(event: InputEvent) -> void:
	if get_tree().paused and event.is_action_pressed("pause"):
		resume_requested.emit()
		get_viewport().set_input_as_handled()
