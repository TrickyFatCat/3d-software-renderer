package window_manager

import "core:log"
import sdl "vendor:sdl2"

window: ^sdl.Window = nil
renderer: ^sdl.Renderer = nil

WINDOW_WIDTH : i32 : 800
WINDOW_HEIGHT : i32 : 600

@require_results
init_window :: proc() -> (success: bool){
	when ODIN_DEBUG {
		log.info("Start SDL initialization.")
	}

	if sdl.Init(sdl.INIT_EVERYTHING) != 0 {
		log.fatal("Failed to initialize SDL.\n")
	success = false
	return success
	}
	
	window = sdl.CreateWindow(
		nil,
		sdl.WINDOWPOS_CENTERED,
		sdl.WINDOWPOS_CENTERED,
		WINDOW_WIDTH,
		WINDOW_HEIGHT,
		sdl.WINDOW_BORDERLESS
	)

	if window == nil {
		log.fatal("Failed to create window.\n")
		success = false
		return success
	}

	renderer = sdl.CreateRenderer(window, -1, sdl.RENDERER_SOFTWARE)

	if renderer == nil {
		log.fatal("Failed to create renderer.\n")
		success = false
		return success
	}

	success = true

	if ODIN_DEBUG && success{
		log.info("SDL successfully initialized.")
	}

	return success
}

destroy_window :: proc() {
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