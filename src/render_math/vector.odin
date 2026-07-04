package render_math

import "core:math"

Vec2 :: struct {
	x, y: f32,
}

Vec3 :: struct {
	x, y, z: f32,
}

vec3_rotate_x :: proc(v: Vec3, angle: f32) -> (rotated_vector: Vec3) {
	angle := math.to_radians(angle)
	rotated_vector.x = v.x
	rotated_vector.y = v.y * math.cos(angle) - v.z * math.sin(angle)
	rotated_vector.z = v.y * math.sin(angle) + v.z * math.cos(angle)
	return rotated_vector
}

vec3_rotate_y :: proc(v: Vec3, angle: f32) -> (rotated_vector: Vec3) {
	angle := math.to_radians(angle)
	rotated_vector.x = v.x * math.cos(angle) - v.z * math.sin(angle)
	rotated_vector.y = v.y
	rotated_vector.z = v.x * math.sin(angle) + v.z * math.cos(angle)
	return rotated_vector
}

vec3_rotate_z :: proc(v: Vec3, angle: f32) -> (rotated_vector: Vec3) {
	angle := math.to_radians(angle)
	rotated_vector.x = v.x * math.cos(angle) - v.y * math.sin(angle)
	rotated_vector.y = v.x * math.sin(angle) + v.y * math.cos(angle)
	rotated_vector.z = v.z
	return rotated_vector
}

@(private)
vec2_length :: proc(v: Vec2) -> (length: f32) {
	length = math.sqrt(v.x * v.x + v.y * v.y)
	return length
}

@(private)
vec3_length :: proc(v: Vec3) -> (length: f32) {
	length = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
	return length
}

vec_length :: proc {
	vec2_length,
	vec3_length,
}

@(private)
vec2_add :: proc(a: Vec2, b: Vec2) -> (new_vec: Vec2) {
	new_vec = Vec2 {
		x = a.x + b.x,
		y = a.y + b.y,
	}
	return new_vec
}

@(private)
vec3_add :: proc(a: Vec3, b: Vec3) -> (new_vec: Vec3) {
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

@(private)
vec2_subtract :: proc(a: Vec2, b: Vec2) -> (new_vec: Vec2) {
	new_vec = Vec2 {
		x = a.x - b.x,
		y = a.y - b.y,
	}
	return new_vec
}

@(private)
vec3_subtract :: proc(a: Vec3, b: Vec3) -> (new_vec: Vec3) {
	new_vec = Vec3 {
		x = a.x - b.x,
		y = a.y - b.y,
		z = a.z - b.z,
	}
	return new_vec
}

vec_subtract :: proc {
	vec2_subtract,
	vec3_subtract,
}

@(private)
vec2_multiply :: proc(v: Vec2, factor: f32) -> (new_vec: Vec2) {
	new_vec = Vec2{v.x * factor, v.y * factor}
	return new_vec
}

@(private)
vec3_multiply :: proc(v: Vec3, factor: f32) -> (new_vec: Vec3) {
	new_vec = Vec3{v.x * factor, v.y * factor, v.z * factor}
	return new_vec
}

vec_multiply :: proc {
	vec2_multiply,
	vec3_multiply,
}

@(private)
vec2_divide :: proc(v: Vec2, factor: f32) -> (new_vec: Vec2) {
	new_vec = Vec2{v.x / factor, v.y / factor}
	return new_vec
}

@(private)
vec3_divide :: proc(v: Vec3, factor: f32) -> (new_vec: Vec3) {
	new_vec = Vec3{v.x / factor, v.y / factor, v.z / factor}
	return new_vec
}

vec_divide :: proc {
	vec2_divide,
	vec3_divide,
}


vec3_cross :: proc(a: Vec3, b: Vec3) -> (cross_product: Vec3) {
	cross_product = Vec3 {
		x = a.y * b.z - a.z * b.y,
		y = a.z * b.x - a.x * b.z,
		z = a.x * b.y - a.y * b.x,
	}
	return cross_product
}

@(private)
vec2_dot :: proc(a: Vec2, b: Vec2) -> (dot_product: f32) {
	dot_product = (a.x * b.x) + (a.y * b.y)
	return dot_product
}


@(private)
vec3_dot :: proc(a: Vec3, b: Vec3) -> (dot_product: f32) {
	dot_product = (a.x * b.x) + (a.y * b.y) + (a.z * b.z)
	return dot_product
}

vec_dot :: proc {
	vec2_dot,
	vec3_dot,
}

