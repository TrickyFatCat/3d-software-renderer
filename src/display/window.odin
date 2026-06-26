package display

import "core:log"
import sdl "vendor:sdl2"

@(private)
window: ^sdl.Window = nil
@(private)
renderer: ^sdl.Renderer = nil

@(private)
window_width: u32 = 800
@(private)
window_height: u32 = 600

@(private)
init_window :: proc() -> (success: bool) {
	when ODIN_DEBUG {
		log.info("Start initializing window.")
	}

	sdl_ok := init_sdl()
	window_ok := create_window()
	renderer_ok := create_renderer()

	success = sdl_ok && window_ok && renderer_ok

	if success {
		sdl.SetWindowFullscreen(window, sdl.WINDOW_FULLSCREEN)
	}

	when ODIN_DEBUG {
		if success {
			log.info("Window successfully initialized.")
		} else {
			log.fatal("Failed to initialize window")
		}
	}

	return success
}

get_window :: proc() -> (^sdl.Window) {
	return window
}

get_window_dimentions :: proc() -> (u32, u32) {
	return window_width, window_height
}

get_window_middle :: proc() -> (u32, u32) {
	return window_width / 2, window_height / 2
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
	display_mode: sdl.DisplayMode
	sdl.GetCurrentDisplayMode(0, &display_mode)

	window_width = u32(display_mode.w)
	window_height = u32(display_mode.h)

	window = sdl.CreateWindow(
		nil,
		sdl.WINDOWPOS_CENTERED,
		sdl.WINDOWPOS_CENTERED,
		i32(window_width),
		i32(window_height),
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

@(private)
destroy_window :: proc() {
	sdl.DestroyWindow(window)
	sdl.DestroyRenderer(renderer)
	sdl.Quit()

	when ODIN_DEBUG {
		log.info("Window and renderer are destroyed.")
	}
}

get_renderer :: proc() -> ^sdl.Renderer {
	return renderer
}