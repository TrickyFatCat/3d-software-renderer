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
RenderOption :: enum u8 {
	Vertex,
	Edge,
	Triangle,
	Shading,
	Texture,
}

RenderOptions :: bit_set[RenderOption]

@(private)
render_options: RenderOptions = {.Vertex, .Edge, .Shading, .Texture}

toggle_render_option :: proc(option: RenderOption) {
	if option in render_options {
		render_options -= {option}

	} else {
		render_options += {option}
	}

	when ODIN_DEBUG {
		result: string = "ENABLED" if option in render_options else "DISABLED"
		option_name: string = reflect.enum_string(option)
		log.infof("%s render is %s.", option_name, result)
	}
}

enable_render_option :: proc(option: RenderOption) -> (success: bool = true) {
	if option in render_options {
		return !success
	}

	render_options += {option}

	when ODIN_DEBUG {
		option_name: string = reflect.enum_string(option)
		log.infof("%s render is ENABLED.", option_name)
	}

	return success
}

disable_render_option :: proc(option: RenderOption) -> (success: bool = true) {
	if !(option in render_options) {
		return !success
	}

	render_options -= {option}

	when ODIN_DEBUG {
		option_name: string = reflect.enum_string(option)
		log.infof("%s render is DISABLED.", option_name)
	}

	return success
}

swap_render_options :: proc(option_a, option_b: RenderOption) {
	if option_a in render_options {
		disable_render_option(option_a)
		enable_render_option(option_b)
	} else {
		enable_render_option(option_a)
		disable_render_option(option_b)
	}
}

is_debug_option_enabled :: proc(option: RenderOption) -> bool {
	return option in render_options
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

