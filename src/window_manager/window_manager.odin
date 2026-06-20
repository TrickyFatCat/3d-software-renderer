package window_manager

import "core:log"
import sdl "vendor:sdl2"

WINDOW_WIDTH : i32 : 800
WINDOW_HEIGHT : i32 : 600

@require_results
init_window :: proc() -> (window : ^sdl.Window, renderer : ^sdl.Renderer, success: bool){
	if sdl.Init(sdl.INIT_EVERYTHING) != 0 {
		log.fatal("Failed to initialize SDL.\n")
	success = false
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
	}

	renderer = sdl.CreateRenderer(window, -1, sdl.RENDERER_SOFTWARE)

	if renderer == nil {
		log.fatal("Failed to create renderer.\n")
		success = false
	}

	success = true

	if ODIN_DEBUG && success{
		log.info("SDL successfull initialized.\n")
	}

	return window, renderer, success
}