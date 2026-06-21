package main

import "core:fmt"
import "core:log"
import "core:mem"
import wm "window_manager"
import cb "color_buffer"
import sdl "vendor:sdl2"

is_running: bool = false

setup :: proc() -> (success: bool) {
	success = wm.init_window()

	if success {
		buffer_size :: u32(wm.WINDOW_WIDTH * wm.WINDOW_HEIGHT)
		cb.init_color_buffer(buffer_size)
	}

	return success
}

cleanup :: proc() {
	cb.delete_color_buffer()
	wm.destroy_window()
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
				when ODIN_DEBUG {
					log.info("ESC key was pressed. Start program termination.")
				}

				is_running = false
			}
			break
	}
}

update :: proc() {

}

render :: proc() {
	sdl.SetRenderDrawColor(wm.renderer, 255, 0, 0, 255)
	sdl.RenderClear(wm.renderer)

	sdl.RenderPresent(wm.renderer)
}

main :: proc() {
	// Tracking allocator. Taken from www.odin-lang.com
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}

		context.logger = log.create_console_logger()
		defer log.destroy_console_logger(context.logger)
	}

	is_running = setup()
	defer cleanup()
	
	for is_running {
		process_input()
		update()
		render()
	}
}
