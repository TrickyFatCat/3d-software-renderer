package display

import "core:log"
import "core:reflect"

CullingMethod :: enum u8 {
	CullNone,
	CullBackface,
}

@(private)
culling_method: CullingMethod = .CullBackface

change_culling_method :: proc(new_method: CullingMethod) {
	if new_method == culling_method {
		return
	}

	culling_method = new_method

	when ODIN_DEBUG {
		method_name: string = reflect.enum_string(new_method)
		log.infof("Culling method was changed to %s", method_name)
	}
}

get_culling_method :: proc() -> CullingMethod {
	return culling_method
}

is_culling_method :: proc(method: CullingMethod) -> bool {
	return culling_method == method
}

DebugRenderOption :: enum u8 {
	Vertex,
	Edge,
	Triangle,
}

DebugRenderOptions :: bit_set[DebugRenderOption]

@(private)
debug_render_options: DebugRenderOptions = {.Vertex, .Edge, .Triangle}

toggle_render_option :: proc(option: DebugRenderOption) {
	if option in debug_render_options {
		debug_render_options -= {option}

	} else {
		debug_render_options += {option}
	}

	when ODIN_DEBUG {
		result: string = "ENABLED" if option in debug_render_options else "DISABLED"
		option_name: string = reflect.enum_string(option)
		log.infof("%s render is %s.", option_name, result)
	}
}

is_debug_option_enabled :: proc(option: DebugRenderOption) -> bool {
	return option in debug_render_options
}

