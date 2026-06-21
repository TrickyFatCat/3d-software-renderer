package window

import "core:log"
import sdl "vendor:sdl2"

@(private)
window: ^sdl.Window = nil
@(private)
renderer: ^sdl.Renderer = nil

WINDOW_WIDTH : i32 : 800
WINDOW_HEIGHT : i32 : 600

@(require_results)
init :: proc() -> (success: bool) {
	when ODIN_DEBUG {
		log.info("Start initializing window.")
	}

	sdl_ok := init_sdl()
	window_ok := create_window()
	renderer_ok := create_renderer()

	success = sdl_ok && window_ok && renderer_ok

	if ODIN_DEBUG {
		if success {
			log.info("Window successfully initialized.")
		} else {
			log.fatal("Failed to initialize window")
		}
	}

	return success
}

get :: proc() -> (^sdl.Window) {
	return window
}

@(private)
init_sdl :: proc() -> (success: bool) {
	success = sdl.Init(sdl.INIT_EVERYTHING) == 0

	if ODIN_DEBUG {
		if success {
			log.info("SDL successfully initialized.")
		} else {
			log.fatal("Failed to initialize SDL.")
		}
	}

	return success
}

@(private)
create_window :: proc() -> (success: bool) {
	window = sdl.CreateWindow(
		nil,
		sdl.WINDOWPOS_CENTERED,
		sdl.WINDOWPOS_CENTERED,
		WINDOW_WIDTH,
		WINDOW_HEIGHT,
		sdl.WINDOW_BORDERLESS
	)

	success = window != nil

	if success {
		log.info("Window is created.")
	} else {
		log.fatal("Failed to create window.")
	}

	return success
}

@(private)
create_renderer :: proc() -> (success: bool) {
	renderer = sdl.CreateRenderer(window, -1, sdl.RENDERER_SOFTWARE)
	success = renderer != nil

	if success {
		log.info("Renderer is created.")
	} else {
		log.fatal("Failed to create renderer.")
	}

	return success
}

destroy :: proc() {
	when ODIN_DEBUG {
		log.info("Start destroying window and renderer.")
	}

	sdl.DestroyWindow(window)
	sdl.DestroyRenderer(renderer)
	sdl.Quit()

	when ODIN_DEBUG {
		log.info("Finish destroying window and renderer.")
	}
}

get_renderer :: proc() -> ^sdl.Renderer {
	return renderer
}