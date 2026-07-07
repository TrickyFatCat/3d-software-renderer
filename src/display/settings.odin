package display

import "core:log"
import "core:reflect"

// Culling methods options
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


// Debug render options
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

// Grid draw option
DebugGridType :: enum u8 {
	None,
	Dots,
}

@(private)
debug_grid_type: DebugGridType = .None

set_debug_grids_type :: proc(new_grid_type: DebugGridType) {
	if new_grid_type == debug_grid_type {
		return
	}

	debug_grid_type = new_grid_type

	when ODIN_DEBUG {
		result: string =
			"Debug grid is ENABLED" if new_grid_type != .None else "Debug grid is DISABLED"

		switch new_grid_type {
		case .None:
			log.infof("%s.", result)
			break

		case .Dots:
			option_name: string = reflect.enum_string(new_grid_type)
			log.infof("%s. New type %s.", result, option_name)
			break
		}
	}
}

toggle_debug_grid :: proc() {
	new_grid_type: DebugGridType = .Dots if debug_grid_type == .None else .None
	set_debug_grids_type(new_grid_type)
}

is_debug_grid :: proc(grid_type: DebugGridType) -> bool {
	return debug_grid_type == grid_type
}

