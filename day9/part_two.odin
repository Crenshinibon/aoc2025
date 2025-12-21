package main

import "core:encoding/cbor"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

Point :: struct {
	x, y: int,
}

Line :: struct {
	s, e: Point,
}

Field :: struct {
	reds:  []Point,
	lines: []Line,
}

State :: struct {
	fields: [dynamic]Field,
	max_x:  int,
	max_y:  int,
	reds:   [dynamic]Point,
}

save_binary :: proc(state: State, filename: string) {
	binary_data, err := cbor.marshal(state)
	if err != nil {
		fmt.println("Error marshalling state", err)
	}
	defer delete(binary_data)

	success := os.write_entire_file(filename, transmute([]byte)binary_data)
	if !success {
		fmt.println("Failed to write file!")
	}
}

load_binary :: proc(filename: string) -> State {
	state: State

	data := os.read_entire_file(filename) or_else os.exit(1)
	defer delete(data) // Clean up file buffer

	err := cbor.unmarshal(string(data), &state)
	if err != nil {
		fmt.println("Error unmarshal state")
	}
	return state
}

calc_fields :: proc(
	allocator := context.allocator,
) -> (
	fields: [dynamic]Field,
	reds: [dynamic]Point,
	max_x: int,
	max_y: int,
) {
	data := os.read_entire_file("input_small", allocator) or_else os.exit(1)
	defer delete(data)
	s := string(data)

	lines := strings.split_lines(s)
	reds = make([dynamic]Point, len(lines) - 1, allocator)

	for l, i in lines {
		if len(l) == 0 do break
		parts := strings.split(l, ",")
		x := strconv.parse_int(parts[0]) or_else os.exit(1)
		y := strconv.parse_int(parts[1]) or_else os.exit(1)

		reds[i] = {x, y}
	}
	fields = make([dynamic]Field, 0, allocator)

	max_x = 0
	max_y = 0

	for r in reds {
		if r.x > max_x do max_x = r.x
		if r.y > max_y do max_y = r.y
	}

	DIR :: enum {
		UNDEFINED,
		HORIZONTAL,
		VERTICAL,
	}

	//slice.sort_by(reds[:], proc(a, b: Point) -> bool {
	//	return a.x + a.y > b.x + b.y
	//})

	// we have to change dimensions, every encounter
	current_dir: DIR = .UNDEFINED
	UNDEFINED_DIRS :: [4]Point{{0, -1}, {0, 1}, {-1, 0}, {1, 0}}
	HORIZONTAL_DIRS :: [2]Point{{1, 0}, {-1, 0}}
	VERTICAL_DIRS :: [2]Point{{0, 1}, {0, -1}}

	for len(reds) > 0 {

		current_field_reds := make([dynamic]Point, 0, len(reds))
		current_field_lines := make([dynamic]Line, 0, len(reds) / 2)

		first_red := pop(&reds)
		append(&current_field_reds, first_red)

		cr := first_red

		next_red_idx := 0
		for next_red_idx > -1 {
			next_red_idx = -1

			// at the start consider all directions
			if current_dir == .UNDEFINED {
				dir_loop: for d in UNDEFINED_DIRS {
					np := Point {
						x = cr.x + d.x,
						y = cr.y + d.y,
					}
					for np.x >= 0 && np.x <= max_x && np.y >= 0 && np.y <= max_y {
						np.x += d.x
						np.y += d.y

						for nr, i in reds {
							if nr == np {
								//fmt.println("Found next in dir", d, nr, i)
								if cr.x == nr.x {
									current_dir = .VERTICAL
								} else {
									current_dir = .HORIZONTAL
								}

								next_red_idx = i
								break dir_loop
							}
						}
					}
					//fmt.println("Found none in dir:", d)
				}
			} else if current_dir == .VERTICAL {

				dir_loop_horizontal: for d in HORIZONTAL_DIRS {

					np := Point {
						x = cr.x + d.x,
						y = cr.y,
					}

					for np.x <= max_x && np.x >= 0 {
						np.x += d.x

						for nr, i in reds {
							if nr == np {
								current_dir = .HORIZONTAL
								next_red_idx = i
								break dir_loop_horizontal
							}
						}
					}
				}

			} else if current_dir == .HORIZONTAL {
				dir_loop_vertical: for d in VERTICAL_DIRS {

					np := Point {
						x = cr.x,
						y = cr.y + d.y,
					}


					for np.y <= max_y && np.y >= 0 {
						np.y += d.y

						for nr, i in reds {
							if nr == np {
								current_dir = .VERTICAL
								next_red_idx = i
								break dir_loop_vertical
							}
						}
					}
				}
			}

			if (next_red_idx > -1) {
				nr := reds[next_red_idx]
				//append line
				append(&current_field_lines, Line{s = cr, e = nr})

				cr = nr
				append(&current_field_reds, cr)
				unordered_remove(&reds, next_red_idx)
			}
		}

		//add final closing line
		append(&current_field_lines, Line{s = cr, e = first_red})

		current_f := Field {
			reds  = current_field_reds[:],
			lines = current_field_lines[:],
		}
		append(&fields, current_f)
	}


	fmt.println(len(fields))
	for f in fields {
		fmt.println(f.lines)
		fmt.println("---")
		fmt.println(f.reds)
		fmt.println("---")
	}
	return
}

greedy_intersect_lines :: proc(line1, line2: Line) -> bool {
	l1 := [2][2]int{{line1.s.x, line1.s.y}, {line1.e.x, line1.e.y}}
	l2 := [2][2]int{{line2.s.x, line2.s.y}, {line2.e.x, line2.e.y}}

	l1_horizontal := l1[0][0] == l1[1][0]
	l2_horizontal := l2[0][0] == l2[1][0]
	if l1_horizontal == l2_horizontal do return false

	if l1_horizontal {

		min_x_l1 := min(l1[0][0], l1[1][0])
		max_x_l1 := max(l1[0][0], l1[1][0])

		min_y_l2 := min(l2[0][1], l2[1][1])
		max_y_l2 := max(l2[0][1], l2[1][1])

		return(
			l2[0][0] >= min_x_l1 &&
			l2[0][0] <= max_x_l1 &&
			l1[0][1] >= min_y_l2 &&
			l1[0][1] <= max_y_l2 \
		)
	} else {
		min_x_l2 := min(l2[0][0], l2[1][0])
		max_x_l2 := max(l2[0][0], l2[1][0])

		min_y_l1 := min(l1[0][1], l1[1][1])
		max_y_l2 := max(l1[0][1], l1[1][1])

		return(
			l1[0][0] >= min_x_l2 &&
			l1[0][0] <= max_x_l2 &&
			l2[0][1] >= min_y_l1 &&
			l2[0][1] <= max_y_l2 \
		)
	}
}


intersect :: proc(l1: [2][2]int, line: Line) -> bool {
	l2 := [2][2]int{{line.s.x, line.s.y}, {line.e.x, line.e.y}}

	l1_horizontal := l1[0][0] == l1[1][0]
	l2_horizontal := l2[0][0] == l2[1][0]
	if l1_horizontal == l2_horizontal do return false

	if l1_horizontal {
		x1 := min(l1[0][0], l1[1][0])
		x2 := max(l1[0][0], l1[1][0])

		y1 := min(l2[0][1], l2[1][1])
		y2 := max(l2[0][1], l2[1][1])

		return l2[0][0] > x1 && l2[0][0] < x2 && l1[0][1] > y1 && l1[0][1] < y2
	} else {
		x1 := min(l2[0][0], l2[1][0])
		x2 := max(l2[0][0], l2[1][0])

		y1 := min(l1[0][1], l1[1][1])
		y2 := max(l1[0][1], l1[1][1])

		return l1[0][0] > x1 && l1[0][0] < x2 && l2[0][1] > y1 && l2[0][1] < y2
	}
}

count_intersections :: proc(l: [2][2]int, lines: []Line) -> int {
	count := 0
	for o_l in lines {
		//fmt.println("check intersect:", l, o_l)
		if intersect(l, o_l) do count += 1
	}
	return count
}

check_point_in_bounds :: proc(
	p: Point,
	lines: []Line,
	max_x: int,
	max_y: int,
) -> (
	inside: bool,
	count_left: int,
	count_right: int,
	count_bottom: int,
	count_top: int,
) {
	inside = false

	left_line := [2][2]int{{0, p.y}, {p.x, p.y}}
	right_line := [2][2]int{{p.x, p.y}, {max_x, p.y}}
	top_line := [2][2]int{{p.x, 0}, {p.x, p.y}}
	bottom_line := [2][2]int{{p.x, p.y}, {p.x, max_y}}

	count_left = count_intersections(left_line, lines[:])
	//fmt.println("count_left", p, count_left)
	if count_left % 2 == 0 do inside = true

	count_right = count_intersections(right_line, lines[:])
	//fmt.println("count_right", p, count_right)
	if count_right % 2 == 0 do inside = true

	count_top = count_intersections(top_line, lines[:])
	//fmt.println("count_top", p, count_top)
	if count_top % 2 == 0 do inside = true

	count_bottom = count_intersections(bottom_line, lines[:])
	//fmt.println("count_bottom", p, count_bottom)
	if count_bottom % 2 == 0 do inside = true

	return
}


main :: proc() {

	path := "state.bin"

	fields: [dynamic]Field
	reds: [dynamic]Point
	max_x: int
	max_y: int

	if os.is_file(path) {
		state := load_binary(path)
		fields = state.fields
		reds = state.reds
		max_x = state.max_x
		max_y = state.max_y
	} else {
		fields, reds, max_x, max_y = calc_fields(context.allocator)
		state := State {
			fields = fields,
			reds   = reds,
			max_x  = max_x,
			max_y  = max_y,
		}
		save_binary(state, path)
	}

	//find the biggest rectangle in all fields
	Area :: struct {
		c_1:    Point,
		dist_x: int,
		c_2:    Point,
		dist_y: int,
		area:   int,
	}

	areas := make([dynamic]Area, 0, len(reds) * len(reds))

	for f in fields {
		for p_1, i in f.reds {

			inner_reds_loop: for j := i + 1; j < len(f.reds); j += 1 {
				p_2 := f.reds[j]

				fmt.println("Checking rect:", p_1, p_2)

				//check valid rect
				//no other "red" can be "inside" this rect
				low_x := p_1.x
				if p_2.x < p_1.x do low_x = p_2.x
				high_x := p_1.x
				if p_2.x > p_1.x do high_x = p_2.x
				if high_x == low_x do continue inner_reds_loop


				low_y := p_1.y
				if p_2.y < p_1.y do low_y = p_2.y
				high_y := p_1.y
				if p_2.y > p_1.y do high_y = p_2.y
				if high_y == low_y do continue inner_reds_loop

				for o_r in f.reds {
					if o_r.y < high_y && o_r.y > low_y && o_r.x < high_x && o_r.x > low_x {
						fmt.println("found red inside, not valid")
						continue inner_reds_loop
					}
				}
				// check for both other corners if they are inside the polygon
				other_corner_1: Point = {
					x = p_1.x,
					y = p_2.y,
				}
				other_corner_2: Point = {
					x = p_2.x,
					y = p_1.y,
				}
				/*
				res_1, c_1_l, c_1_r, c_1_b, c_1_t := check_point_in_bounds(
					other_corner_1,
					f.lines,
					max_x,
					max_y,
				)
				res_2, c_2_l, c_2_r, c_2_b, c_2_t := check_point_in_bounds(
					other_corner_2,
					f.lines,
					max_x,
					max_y,
				)
				fmt.println("check other result 1: ", res_1, c_1_l, c_1_r, c_1_b, c_1_t)
				fmt.println("check other result 2: ", res_2, c_2_l, c_2_r, c_2_b, c_2_t)
*/
				// check if the rectangle lines area intersecting any polygon lines
				l1 := Line{p_1, other_corner_1}
				l2 := Line{other_corner_1, p_2}
				l3 := Line{p_2, other_corner_2}
				l4 := Line{other_corner_2, p_1}
				for l in f.lines {
					if greedy_intersect_lines(l, l1) {
						fmt.println("found intersection l1", l1, l)
						continue inner_reds_loop
					}
					if greedy_intersect_lines(l, l2) {
						fmt.println("found intersection l2", l2, l)
						continue inner_reds_loop
					}
					if greedy_intersect_lines(l, l3) {
						fmt.println("found intersection l3", l3, l)
						continue inner_reds_loop
					}
					if greedy_intersect_lines(l, l4) {
						fmt.println("found intersection l4", l4, l)
						continue inner_reds_loop
					}
				}


				dist_x := abs(p_1.x - p_2.x)
				dist_y := abs(p_1.y - p_2.y)

				append(
					&areas,
					Area {
						c_1 = p_1,
						c_2 = p_2,
						dist_x = dist_x,
						dist_y = dist_y,
						area = dist_x * dist_y,
					},
				)
			}
		}
	}

	fmt.println("----")
	for a in areas {
		fmt.println(a)
		fmt.println("----")
	}


	slice.sort_by(areas[:], proc(a, b: Area) -> bool {
		return a.area > b.area
	})

	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_RESIZABLE, .MSAA_4X_HINT})
	rl.InitWindow(1600, 1200, "XMAS Tiles")
	defer rl.CloseWindow()

	design_width := f32(max_x)
	design_height := f32(max_y)

	current_area_index := 0

	timer := f32(0.0)
	camera := rl.Camera2D{}
	// have to visualize this I fear
	for !rl.WindowShouldClose() {
		rl.ClearBackground(rl.RAYWHITE)

		// Accumulate the time passed since the last frame
		timer += rl.GetFrameTime()

		if rl.IsMouseButtonPressed(.LEFT) {
			current_area_index += 1

			if current_area_index >= len(areas) {
				current_area_index = 0
			}
		}


		screen_w := f32(rl.GetScreenWidth())
		screen_h := f32(rl.GetScreenHeight())
		scale := min(f32(screen_w) / f32(design_width), f32(screen_h) / f32(design_height))
		camera.zoom = scale

		rl.BeginDrawing()
		rl.BeginMode2D(camera)

		for field in fields {

			for line in field.lines {

				start := rl.Vector2{f32(line.s.x), f32(line.s.y)}
				end := rl.Vector2{f32(line.e.x), f32(line.e.y)}

				rl.DrawLineEx(start, end, 6.0 / scale, rl.GREEN)
			}
		}

		a := areas[current_area_index]
		rec := rl.Rectangle {
			x      = f32(min(a.c_1.x, a.c_2.x)),
			y      = f32(min(a.c_1.y, a.c_2.y)),
			width  = f32(abs(a.c_1.x - a.c_2.x)),
			height = f32(abs(a.c_1.y - a.c_2.y)),
		}
		rl.DrawRectangleLinesEx(rec, 3.0 / scale, rl.BLUE)
		rl.EndMode2D()


		rl.DrawText(
			fmt.ctprintf("p_1: %v -- p_2: %v", a.c_1, a.c_2),
			5, //i32(rec.x * scale),
			5, //i32(rec.y * scale),
			20,
			rl.BLACK,
		)
		rl.EndDrawing()
	}
}
