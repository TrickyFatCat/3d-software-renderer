package mesh

import rm "../render_math"

@(private)
swap :: proc(a: ^$T, b: ^T) {
	tmp := a^
	a^ = b^
	b^ = tmp
}

///////////////////////////////////////////////////////////////////////////////
// Return the barycentric weights alpha, beta, and gamma for point p
///////////////////////////////////////////////////////////////////////////////
//
//         (B)
//         /|\
//        / | \
//       /  |  \
//      /  (P)  \
//     /  /   \  \
//    / /       \ \
//   //           \\
//  (A)------------(C)
//
///////////////////////////////////////////////////////////////////////////////
@(private)
get_barycentric_weights :: proc(a, b, c, p: rm.Vec2) -> rm.Vec3 {
	// Find the vectors between the vertices ABC and point P
	ac := rm.vec_subtract(c, a)
	ab := rm.vec_subtract(b, a)
	pc := rm.vec_subtract(c, p)
	pb := rm.vec_subtract(b, p)
	ap := rm.vec_subtract(p, a)

	// Area of the full parallelogramm (triangle ABC) using cross product
	area_abc := rm.vec_cross(ab, ac) // || AC x AB ||

	// Alpha = area of parallelogramm PBC over the area of the full parallelogramm ABC
	alpha := rm.vec_cross(pb, pc) / area_abc

	// Beta = area of parallelogramm APC over the area of the full parallelogramm ABC
	beta := rm.vec_cross(ap, ac) / area_abc

	// Gamma can be easily found since barycentric coordinates always add up to 1.0
	gamma := 1.0 - alpha - beta

	return rm.Vec3{alpha, beta, gamma}
}

