package shading

import d "../display"
import rm "../render_math"
import "core:log"
import "core:math"

GlobalLight :: struct {
	dir: rm.Vec3,
}

// Angles in degrees
create_global_light :: proc(angle_x, angle_y, angle_z: f32) -> (new_light: ^GlobalLight) {
	angle_x := math.to_radians(angle_x)
	angle_y := math.to_radians(angle_y)

	dir := rm.vec4_fwd

	rot_x_matrix := rm.make_rotation_x_mat4(angle_x)
	rot_y_matrix := rm.make_rotation_y_mat4(angle_y)
	rot_z_matrix := rm.make_rotation_z_mat4(angle_z)

	dir = rm.mat4_multiply(rot_x_matrix, dir)
	dir = rm.mat4_multiply(rot_y_matrix, dir)
	dir = rm.mat4_multiply(rot_z_matrix, dir)

	new_light = new(GlobalLight)
	new_light.dir = rm.vec3(dir)

	when ODIN_DEBUG {
		log.infof("New global light was created with direction %v", new_light.dir)
	}
	return new_light
}


light_apply_intensity :: proc(
	orig_color: d.Color,
	percentage_factor: f32,
) -> (
	new_color: d.Color,
) {
	percentage_factor := percentage_factor

	if percentage_factor < 0 {
		percentage_factor = 0
	}

	if percentage_factor > 1 {
		percentage_factor = 1
	}

	a := orig_color & 0xFF000000
	r := u32(f32(orig_color & 0x00FF0000) * percentage_factor)
	g := u32(f32(orig_color & 0x0000FF00) * percentage_factor)
	b := u32(f32(orig_color & 0x000000FF) * percentage_factor)

	new_color = a | (r & 0x00FF0000) | (g & 0x0000FF00) | (b & 0x000000FF)
	return new_color
}

