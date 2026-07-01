package main

import "core:fmt"
import "core:log"
import "core:mem"
import "display"
import math "render_math"
import "mesh"
import sdl "vendor:sdl2"

triangles_to_render: [dynamic]mesh.Triangle = nil

camera_pos: math.Vec3 = { x = 0.0, y = 0.0, z = -5.0}
fov_factor :f32: 640

is_running: bool = false
previous_frame_time: u32 = 0

setup :: proc() -> (success: bool) {
	success = display.init()

	if success {
		mesh.mesh_to_render = mesh.create()
		mesh.load_cube_mesh_data()
	}

	return success
}

cleanup :: proc() {
	mesh.destroy(mesh.mesh_to_render)
	display.deinit()
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

project :: proc (point: ^math.Vec3) -> (projected_point: math.Vec2) {
	 projected_point.x = (fov_factor * point.x) / point.z
	 projected_point.y = (fov_factor * point.y) / point.z
	 return projected_point
}

update :: proc() {
	time_to_wait: u32 = display.FRAME_TARGET_TIME - (sdl.GetTicks() - previous_frame_time)

	if time_to_wait > 0 && time_to_wait <= display.FRAME_TARGET_TIME {
		sdl.Delay(time_to_wait)
	}

	// Initialize the array of triangles to render
	triangles_to_render = make([dynamic]mesh.Triangle)

	mesh.mesh_to_render.rotation.x += 0.1
	mesh.mesh_to_render.rotation.y += 0.1
	mesh.mesh_to_render.rotation.z += 0.1

	w, h := display.get_window_middle()

	// Loop all triangle faces in our mesh
	for &face, i in mesh.mesh_to_render.faces {
		face_vertices: [3]math.Vec3;
		face_vertices[0] = mesh.mesh_to_render.vertices[face.a - 1]
		face_vertices[1] = mesh.mesh_to_render.vertices[face.b - 1]
		face_vertices[2] = mesh.mesh_to_render.vertices[face.c - 1]

		projected_triangle: mesh.Triangle

		// Loop all three vertices of a face and apply transformation
		for &vertex, i in face_vertices {
			transformed_vertex := vertex
			transformed_vertex = math.vec3_rotate_x(&transformed_vertex, mesh.mesh_to_render.rotation.x)
			transformed_vertex = math.vec3_rotate_y(&transformed_vertex, mesh.mesh_to_render.rotation.y)
			transformed_vertex = math.vec3_rotate_z(&transformed_vertex, mesh.mesh_to_render.rotation.z)

			// Translate the vertex from the camera
			transformed_vertex.z -= camera_pos.z

			// Project current vertex
			projected_point: math.Vec2 = project(&transformed_vertex)

			// Scale and translate projected points to the middle of the screen
			projected_point.x += f32(w)
			projected_point.y += f32(h)

			projected_triangle.points[i] = projected_point
		}

		// Save the projected triangle in the array of triangles to render
		append(&triangles_to_render, projected_triangle)
	}
}

render :: proc() {

	// display.draw_rec(200, 600, 200, 300, 0xFFFFFF00)
	display.draw_grid(10, 0xFFFF0000)

	w, h := display.get_window_middle()

	// Loop all projected triangles and render them
	for &triangle in triangles_to_render {
		i := 0

		// Draw vertices
		for i in 0..<3 {
			x: i32 = i32(triangle.points[i].x)
			y: i32 = i32(triangle.points[i].y)
			display.draw_rec(x, y, 3, 3, 0xFFFFFF00)
		}

		// Draw triangle edges
		display.draw_triangle(i32(triangle.points[0].x), i32(triangle.points[0].y),
							  i32(triangle.points[1].x), i32(triangle.points[1].y),
							  i32(triangle.points[2].x), i32(triangle.points[2].y),
							  0xFF00FF00)
	}

	delete(triangles_to_render)
	display.finish_render()
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
