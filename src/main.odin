package main

import "core:fmt"
import "core:log"
import sdl "vendor:sdl2"

window: ^sdl.Window = nil
renderer: ^sdl.Renderer = nil
is_running : bool = false

WINDOW_WIDTH : i32 : 800
WINDOW_HEIGHT : i32 : 600

init_window :: proc() -> bool {
	if sdl.Init(sdl.INIT_EVERYTHING) != 0 {
		log.fatal("Failed to initialize SDL.\n")
	return false
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
		return false
	}

	renderer = sdl.CreateRenderer(window, -1, sdl.RENDERER_SOFTWARE)

	if renderer == nil {
		log.fatal("Failed to create renderer.\n")
		return false
	}

	if ODIN_DEBUG {
		log.info("SDL successfull initialized.\n")
	}

	return true
}

main :: proc() {
	is_running = init_window()
}
