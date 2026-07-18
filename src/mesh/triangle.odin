package mesh

import "../display"
import rm "../render_math"
import "core:math"

Face :: struct {
	a_uv, b_uv, c_uv: Tex2,
	a, b, c:          u32,
	color:            display.Color,
}

Triangle :: struct {
	points:     [3]rm.Vec2,
	normal:     rm.Vec3,
	tex_coords: [3]Tex2,
	color:      u32,
	avg_depth:  f32,
}


draw_triangle :: proc(x0, y0, x1, y1, x2, y2: i32, color: display.Color) {
	display.draw_line(x0, y0, x1, y1, color)
	display.draw_line(x1, y1, x2, y2, color)
	display.draw_line(x2, y2, x0, y0, color)
}

///////////////////////////////////////////////////////////////////////////////
// Draw a filled triangle with the flat-top/flat-bottom method
// We split the original triangle in two, half flat-bottom and half flat-top
///////////////////////////////////////////////////////////////////////////////
//
//          (x0,y0)
//            / \
//           /   \
//          /     \
//         /       \
//        /         \
//   (x1,y1)------(Mx,My)
//       \_           \
//          \_         \
//             \_       \
//                \_     \
//                   \    \
//                     \_  \
//                        \_\
//                           \
//                         (x2,y2)
//
///////////////////////////////////////////////////////////////////////////////
draw_filled_triangle :: proc(x0, y0, x1, y1, x2, y2: i32, color: display.Color) {
	x0 := x0
	x1 := x1
	x2 := x2
	y0 := y0
	y1 := y1
	y2 := y2

	// Sort vertices by y-coordinate ascending (y0 < y1 < y2)
	if y0 > y1 {
		swap(&x0, &x1)
		swap(&y0, &y1)
	}

	if y1 > y2 {
		swap(&x1, &x2)
		swap(&y1, &y2)
	}

	if y0 > y1 {
		swap(&x0, &x1)
		swap(&y0, &y1)
	}

	if y1 == y2 {
		fill_flat_bottom_triangle(x0, y0, x1, y1, x2, y2, color)
	} else if y0 == y1 {
		fill_flat_top_triangle(x0, y0, x1, y1, x2, y2, color)
	} else {
		// Calculate the new vertex (Mx, My) using triangle similarity
		Mx: i32 = (((x2 - x0) * (y1 - y0)) / (y2 - y0)) + x0
		My := y1

		fill_flat_bottom_triangle(x0, y0, x1, y1, Mx, My, color)

		fill_flat_top_triangle(x1, y1, Mx, My, x2, y2, color)
	}
}

///////////////////////////////////////////////////////////////////////////////
// Draw a filled a triangle with a flat bottom
///////////////////////////////////////////////////////////////////////////////
//
//        (x0,y0)
//          / \
//         /   \
//        /     \
//       /       \
//      /         \
//  (x1,y1)------(x2,y2)
//
///////////////////////////////////////////////////////////////////////////////
@(private)
fill_flat_bottom_triangle :: proc(x0, y0, x1, y1, x2, y2: i32, color: display.Color) {
	// Find two slopes
	inv_slope1: f32 = (f32)(x1 - x0) / (f32)(y1 - y0)
	inv_slope2: f32 = (f32)(x2 - x0) / (f32)(y2 - y0)

	// Start x_start and x_end from the top of the vertex (x0, y0)
	x_start: f32 = f32(x0)
	x_end: f32 = f32(x0)

	// Loop all the scanlines from top to bottom
	for y := y0; y <= y2; y += 1 {
		display.draw_line(i32(x_start), y, i32(x_end), y, color)
		x_start += inv_slope1
		x_end += inv_slope2
	}
}

///////////////////////////////////////////////////////////////////////////////
// Draw a filled a triangle with a flat top
///////////////////////////////////////////////////////////////////////////////
//
//  (x0,y0)------(x1,y1)
//      \         /
//       \       /
//        \     /
//         \   /
//          \ /
//        (x2,y2)
//
///////////////////////////////////////////////////////////////////////////////
@(private)
fill_flat_top_triangle :: proc(x0, y0, x1, y1, x2, y2: i32, color: display.Color) {
	// Find two slopes
	inv_slope1: f32 = (f32)(x2 - x0) / (f32)(y2 - y0)
	inv_slope2: f32 = (f32)(x2 - x1) / (f32)(y2 - y1)

	// Start x_start and x_end from the top of the vertex (x0, y0)
	x_start: f32 = f32(x2)
	x_end: f32 = f32(x2)

	// Loop all the scanlines from bottom to top
	for y := y2; y >= y0; y -= 1 {
		display.draw_line(i32(x_start), y, i32(x_end), y, color)
		x_start -= inv_slope1
		x_end -= inv_slope2
	}
}

draw_textured_triangle :: proc(
	x0, y0, x1, y1, x2, y2: i32,
	u0, v0, u1, v1, u2, v2: f32,
	tex: [dynamic]display.Color,
) {
	// Shadow x
	x0 := x0
	x1 := x1
	x2 := x2

	// Shadow y
	y0 := y0
	y1 := y1
	y2 := y2

	// Shadow u
	u0 := u0
	u1 := u1
	u2 := u2

	// Shadow v
	v0 := v0
	v1 := v1
	v2 := v2

	// Sort vertices by y-coordinate ascending (y0 < y1 < y2)
	if y0 > y1 {
		swap(&x0, &x1)
		swap(&y0, &y1)
		swap(&u0, &u1)
		swap(&v0, &v1)
	}

	if y1 > y2 {
		swap(&x1, &x2)
		swap(&y1, &y2)
		swap(&u1, &u2)
		swap(&v1, &v2)
	}

	if y0 > y1 {
		swap(&x0, &x1)
		swap(&y0, &y1)
		swap(&u0, &u1)
		swap(&v0, &v1)
	}

	////////////////////////////////////////////////////////
	// Render the upper part of the triangle (flat-bottom)//
	////////////////////////////////////////////////////////
	inv_slope_1: f32 = 0.0
	inv_slope_2: f32 = 0.0

	if y1 - y0 != 0 {
		inv_slope_1 = f32(x1 - x0) / math.abs(f32(y1 - y0))
	}

	if y2 - y0 != 0 {
		inv_slope_2 = f32(x2 - x0) / math.abs(f32(y2 - y0))
	}

	if y1 - y0 != 0 {
		// Loop all the scanlines from top to bottom
		for y := y0; y <= y1; y += 1 {
			x_start: i32 = x1 + i32((f32(y - y1)) * inv_slope_1)
			x_end: i32 = x0 + i32((f32(y - y0)) * inv_slope_2)

			// Swaw if x_start is to the right of x_end
			if x_end < x_start {
				swap(&x_start, &x_end)
			}

			for x := x_start; x < x_end; x += 1 {
				display.draw_pixel(int(x), int(y), display.MAGENTA)
			}
		}
	}

	//////////////////////////////////////////////////////
	// Render the bottom part of the triangle (flat-top)//
	//////////////////////////////////////////////////////
	inv_slope_1 = 0.0
	inv_slope_2 = 0.0

	if y2 - y1 != 0 {
		inv_slope_1 = f32(x2 - x1) / math.abs(f32(y2 - y1))
	}

	if y2 - y0 != 0 {
		inv_slope_2 = f32(x2 - x0) / math.abs(f32(y2 - y0))
	}

	if y2 - y1 != 0 {
		// Loop all the scanlines from top to bottom
		for y := y1; y <= y2; y += 1 {
			x_start: i32 = x1 + i32((f32(y - y1)) * inv_slope_1)
			x_end: i32 = x0 + i32((f32(y - y0)) * inv_slope_2)

			// Swaw if x_start is to the right of x_end
			if x_end < x_start {
				swap(&x_start, &x_end)
			}

			for x := x_start; x < x_end; x += 1 {
				display.draw_pixel(int(x), int(y), display.MAGENTA)
			}
		}
	}
}

