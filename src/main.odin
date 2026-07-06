package main

import "core:fmt"
import "core:log"
import "core:mem"
import "display"
import "mesh"
import rm "render_math"
import sdl "vendor:sdl2"

triangles_to_render: [dynamic]mesh.Triangle = nil

camera_pos: rm.Vec3 = {
	x = 0.0,
	y = 0.0,
	z = 0.0,
}
fov_factor: f32 : 640

is_running: bool = false
previous_frame_time: u32 = 0

setup :: proc() -> (success: bool) {
	success = display.init()

	if success {
		f22_mesh_obj := #load("../assets/f22/f22.obj")
		cube_mesh_obj := #load("../assets/cube/cube.obj")
		mesh.mesh_to_render, _ = mesh.load_mesh_from_obj(cube_mesh_obj)
	}

	return success
}

cleanup :: proc() {
	mesh.destroy(mesh.mesh_to_render)
	display.deinit()
}

process_input :: proc() {
	event: sdl.Event
	sdl.PollEvent(&event)

	#partial switch event.type {
	case sdl.EventType.QUIT:
		is_running = false
		break

	case sdl.EventType.KEYDOWN:
		#partial switch event.key.keysym.sym {
		case sdl.Keycode.ESCAPE:
			when ODIN_DEBUG {
				log.info("ESC key was pressed. Start program termination.")
			}

			is_running = false
			break

		case sdl.Keycode.c:
			display.change_culling_method(.CullBackface)
			break

		case sdl.Keycode.d:
			display.change_culling_method(.CullNone)
			break

		case sdl.Keycode.NUM1:
			display.toggle_render_option(.Vertex)
			break

		case sdl.Keycode.NUM2:
			display.toggle_render_option(.Edge)
			break

		case sdl.Keycode.NUM3:
			display.toggle_render_option(.Triangle)
			break
		}
		break
	}
}

project :: proc(point: rm.Vec3) -> (projected_point: rm.Vec2) {
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
		face_vertices: [3]rm.Vec3
		face_vertices[0] = mesh.mesh_to_render.vertices[face.a - 1]
		face_vertices[1] = mesh.mesh_to_render.vertices[face.b - 1]
		face_vertices[2] = mesh.mesh_to_render.vertices[face.c - 1]

		transformed_vertices: [3]rm.Vec3

		// Loop all three vertices of a face and apply transformation
		for &vertex, i in face_vertices {
			transformed_vertex := vertex
			transformed_vertex = rm.vec3_rotate_x(
				transformed_vertex,
				mesh.mesh_to_render.rotation.x,
			)
			transformed_vertex = rm.vec3_rotate_y(
				transformed_vertex,
				mesh.mesh_to_render.rotation.y,
			)
			transformed_vertex = rm.vec3_rotate_z(
				transformed_vertex,
				mesh.mesh_to_render.rotation.z,
			)

			// Translate the vertex from the camera
			transformed_vertex.z += 5
			transformed_vertices[i] = transformed_vertex
		}

		if display.is_culling_method(.CullBackface) {
			// Perform backface culling
			vec_a := transformed_vertices[0]
			vec_b := transformed_vertices[1]
			vec_c := transformed_vertices[2]

			// Get vector subtraction B - A and C - A
			vec_ab := rm.vec_subtract(vec_b, vec_a)
			vec_ab = rm.vec_normalize(vec_ab)
			vec_ac := rm.vec_subtract(vec_c, vec_a)
			vec_ac = rm.vec_normalize(vec_ac)

			// Compute the face normal by using cross product
			normal := rm.vec3_cross(vec_ab, vec_ac)
			normal = rm.vec_normalize(normal)

			// Find the vector a point in the triangle and the camera origin
			camera_ray := rm.vec_subtract(camera_pos, vec_a)

			// Calculate how aligned the camera ray with the face normal
			// Using dot product
			dot_product := rm.vec_dot(camera_ray, normal)

			// Bypass the triangles that are looking away from the camera
			if dot_product < 0.0 {
				continue
			}
		}

		projected_triangle: mesh.Triangle

		// Loop all three vertices to perform projection
		for &vertex, i in transformed_vertices {
			// Project current vertex
			projected_point: rm.Vec2 = project(vertex)

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
	// display.draw_grid(10, 0xFFFF0000)

	w, h := display.get_window_middle()

	// Loop all projected triangles and render them
	for &triangle in triangles_to_render {
		if display.is_debug_option_enabled(.Vertex) {
			// Draw vertices
			for i in 0 ..< 3 {
				x: i32 = i32(triangle.points[i].x)
				y: i32 = i32(triangle.points[i].y)
				display.draw_rec(x, y, 3, 3, .Red)
			}
		}

		if display.is_debug_option_enabled(.Triangle) {
			// Draw filled triangle
			mesh.draw_filled_triangle(
				i32(triangle.points[0].x),
				i32(triangle.points[0].y),
				i32(triangle.points[1].x),
				i32(triangle.points[1].y),
				i32(triangle.points[2].x),
				i32(triangle.points[2].y),
				.White,
			)
		}

		if display.is_debug_option_enabled(.Edge) {
			// Draw triangle edges
			mesh.draw_triangle(
				i32(triangle.points[0].x),
				i32(triangle.points[0].y),
				i32(triangle.points[1].x),
				i32(triangle.points[1].y),
				i32(triangle.points[2].x),
				i32(triangle.points[2].y),
				.Blue,
			)
		}
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

