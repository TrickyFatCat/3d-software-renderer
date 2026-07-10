package render_math

import "core:math"

// Odin has its own matrix type, but this one created for learning experience
Mat4 :: distinct [4][4]f32

get_identity_mat4 :: proc() -> (identity_mat4: Mat4) {
	// | 1 0 0 0 |
	// | 0 1 0 0 |
	// | 0 0 1 0 |
	// | 0 0 0 1 |
	identity_mat4 = {
		{1, 0, 0, 0}, //
		{0, 1, 0, 0},
		{0, 0, 1, 0},
		{0, 0, 0, 1},
	}
	return identity_mat4
}

@(private)
make_scale_mat4_xyz :: proc(sx, sy, sz: f32) -> (scale_mat4: Mat4) {
	// | sx  0  0 0 |
	// |  0 sy  0 0 |
	// |  0  0 sz 0 |
	// |  0  0  0 1 |
	scale_mat4 = get_identity_mat4()
	scale_mat4[0][0] = sx
	scale_mat4[1][1] = sy
	scale_mat4[2][2] = sz
	return scale_mat4
}

@(private)
make_scale_mat4_vec3 :: proc(vec: Vec3) -> (scale_mat4: Mat4) {
	// | sx  0  0 0 |
	// |  0 sy  0 0 |
	// |  0  0 sz 0 |
	// |  0  0  0 1 |
	scale_mat4 = get_identity_mat4()
	scale_mat4[0][0] = vec.x
	scale_mat4[1][1] = vec.y
	scale_mat4[2][2] = vec.z
	return scale_mat4
}

make_scale_mat4 :: proc {
	make_scale_mat4_xyz,
	make_scale_mat4_vec3,
}


@(private)
mat4_mul_vec4 :: proc(m: Mat4, v: Vec4) -> (new_vec: Vec4) {
	new_vec.x = (m[0][0] * v.x) + (m[0][1] * v.y) + (m[0][2] * v.z) + (m[0][3] * v.w)
	new_vec.y = (m[1][0] * v.x) + (m[1][1] * v.y) + (m[1][2] * v.z) + (m[1][3] * v.w)
	new_vec.z = (m[2][0] * v.x) + (m[2][1] * v.y) + (m[2][2] * v.z) + (m[2][3] * v.w)
	new_vec.w = (m[3][0] * v.x) + (m[3][1] * v.y) + (m[3][2] * v.z) + (m[3][3] * v.w)
	return new_vec
}


mat4_multiply :: proc {
	mat4_mul_vec4,
}


@(private)
make_translation_mat4_xyz :: proc(tx, ty, tz: f32) -> (translation_mat4: Mat4) {
	// | 1 0 0 tx |
	// | 0 1 0 ty |
	// | 0 0 1 tz |
	// | 0 0 0 1  |
	translation_mat4 = get_identity_mat4()
	translation_mat4[0][3] = tx
	translation_mat4[1][3] = ty
	translation_mat4[2][3] = tz
	return translation_mat4
}

@(private)
make_translation_mat4_vec3 :: proc(v: Vec3) -> (translation_mat4: Mat4) {
	// | 1 0 0 tx |
	// | 0 1 0 ty |
	// | 0 0 1 tz |
	// | 0 0 0 1  |
	translation_mat4 = get_identity_mat4()
	translation_mat4[0][3] = v.x
	translation_mat4[1][3] = v.y
	translation_mat4[2][3] = v.z
	return translation_mat4
}

make_translation_mat4 :: proc {
	make_translation_mat4_xyz,
	make_translation_mat4_vec3,
}

@(private)
make_rotation_x_mat4_angle :: proc(angle: f32) -> (rot_x_mat4: Mat4) {
	sin := math.sin(angle)
	cos := math.cos(angle)
	// | 1    0    0 0 |
	// | 0  cos  sin 0 |
	// | 0 -sin  cos 0 |
	// | 0    0    0 1 |
	rot_x_mat4 = get_identity_mat4()
	rot_x_mat4[1][1] = cos
	rot_x_mat4[1][2] = sin
	rot_x_mat4[2][1] = -sin
	rot_x_mat4[2][2] = cos
	return rot_x_mat4
}

@(private)
make_rotation_x_mat4_vec3 :: proc(v: Vec3) -> (rot_x_mat4: Mat4) {
	rot_x_mat4 = make_rotation_x_mat4_angle(v.x)
	return rot_x_mat4
}

make_rotation_x_mat4 :: proc {
	make_rotation_x_mat4_angle,
	make_rotation_x_mat4_vec3,
}

@(private)
make_rotation_y_mat4_angle :: proc(angle: f32) -> (rot_y_mat4: Mat4) {
	sin := math.sin(angle)
	cos := math.cos(angle)
	// | cos 0 -sin 0 |
	// |   0 1    0 0 |
	// | sin 0  cos 0 |
	// |   0 0    0 1 |
	rot_y_mat4 = get_identity_mat4()
	rot_y_mat4[0][0] = cos
	rot_y_mat4[0][2] = -sin
	rot_y_mat4[2][0] = sin
	rot_y_mat4[2][2] = cos
	return rot_y_mat4
}

@(private)
make_rotation_y_mat4_vec3 :: proc(v: Vec3) -> (rot_y_mat4: Mat4) {
	rot_y_mat4 = make_rotation_y_mat4_angle(v.y)
	return rot_y_mat4
}

make_rotation_y_mat4 :: proc {
	make_rotation_y_mat4_angle,
	make_rotation_y_mat4_vec3,
}

@(private)
make_rotation_z_mat4_angle :: proc(angle: f32) -> (rot_z_mat4: Mat4) {
	sin := math.sin(angle)
	cos := math.cos(angle)
	// |  cos sin 0 0 |
	// | -sin cos 0 0 |
	// |    0   0 1 0 |
	// |    0   0 0 1 |
	rot_z_mat4 = get_identity_mat4()
	rot_z_mat4[0][0] = cos
	rot_z_mat4[0][1] = sin
	rot_z_mat4[1][0] = -sin
	rot_z_mat4[1][1] = cos
	return rot_z_mat4
}

@(private)
make_rotation_z_mat4_vec3 :: proc(v: Vec3) -> (rot_z_mat4: Mat4) {
	rot_z_mat4 = make_rotation_z_mat4_angle(v.z)
	return rot_z_mat4
}

make_rotation_z_mat4 :: proc {
	make_rotation_z_mat4_angle,
	make_rotation_z_mat4_vec3,
}

