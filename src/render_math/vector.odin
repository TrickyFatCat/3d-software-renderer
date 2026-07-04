package render_math

import "core:math"

Vec2 :: struct {
	x, y: f32,
}

Vec3 :: struct {
	x, y, z: f32,
}

vec3_rotate_x :: proc(v: ^Vec3, angle: f32) -> (rotated_vector: Vec3) {
	angle := math.to_radians(angle)
	rotated_vector.x = v.x
	rotated_vector.y = v.y * math.cos(angle) - v.z * math.sin(angle)
	rotated_vector.z = v.y * math.sin(angle) + v.z * math.cos(angle)
	return rotated_vector
}

vec3_rotate_y :: proc(v: ^Vec3, angle: f32) -> (rotated_vector: Vec3) {
	angle := math.to_radians(angle)
	rotated_vector.x = v.x * math.cos(angle) - v.z * math.sin(angle)
	rotated_vector.y = v.y
	rotated_vector.z = v.x * math.sin(angle) + v.z * math.cos(angle)
	return rotated_vector
}

vec3_rotate_z :: proc(v: ^Vec3, angle: f32) -> (rotated_vector: Vec3) {
	angle := math.to_radians(angle)
	rotated_vector.x = v.x * math.cos(angle) - v.y * math.sin(angle)
	rotated_vector.y = v.x * math.sin(angle) + v.y * math.cos(angle)
	rotated_vector.z = v.z
	return rotated_vector
}

@(private)
vec2_length :: proc(v: ^Vec2) -> (length: f32) {
	if v == nil {
		return -1.0
	}

	length = math.sqrt(v.x * v.x + v.y * v.y)
	return length
}

@(private)
vec3_length :: proc(v: ^Vec3) -> (length: f32) {
	if v == nil {
		return -1.0
	}

	length = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
	return length
}

vec_length :: proc {
	vec2_length,
	vec3_length,
}

@(private)
vec2_add :: proc(a: ^Vec2, b: ^Vec2) -> (new_vec: Vec2) {
	if a == nil || b == nil {
		return Vec2{}
	}

	new_vec = Vec2 {
		x = a.x + b.x,
		y = a.y + b.y,
	}
	return new_vec
}

@(private)
vec3_add :: proc(a: ^Vec3, b: ^Vec3) -> (new_vec: Vec3) {
	if a == nil || b == nil {
		return Vec3{}
	}

	new_vec = Vec3 {
		x = a.x + b.x,
		y = a.y + b.y,
		z = a.z + b.z,
	}
	return new_vec
}

vec_add :: proc {
	vec2_add,
	vec3_add,
}

