package main

import "core:fmt"
import "core:log"
import "window_manager"
import sdl "vendor:sdl2"

window: ^sdl.Window = nil
renderer: ^sdl.Renderer = nil
is_running : bool = false

setup :: proc() {

}

process_input :: proc() {
	event : sdl.Event
	sdl.PollEvent(&event)

	#partial switch event.type {
		case sdl.EventType.QUIT:
			is_running = false
			break

		case sdl.EventType.KEYDOWN:
			if event.key.keysym.sym == sdl.Keycode.ESCAPE {
				is_running = false
			}
			break
	}
}

update :: proc() {

}

render :: proc() {
	sdl.SetRenderDrawColor(renderer, 25, 0, 0, 255)
	sdl.RenderClear(renderer)

	sdl.RenderPresent(renderer)
}

main :: proc() {
	context.logger = log.create_console_logger()

	success : bool = false
	window, renderer, success = window_manager.init_window()

	if !success {
		return
	}

	is_running = true;

	for is_running {
		process_input()
		update()
		render()
	}
}
