package main

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"


main :: proc() {

	/*
   * ALL THIS WON'T WORK, because the grid would be fxxxxxx huge, which would require 38GB of memory
   *
	index :: proc(width, x, y: int) -> int {
		return (width * y) + x
	}

	print_floor :: proc(reds: [][2]int, blues: [][2]int) {

		max_x := 0
		max_y := 0

		for p in reds {
			if p[0] > max_x do max_x = p[0]
			if p[1] > max_y do max_y = p[1]
		}
		width := max_x + 1
		height := max_y + 1
		fmt.println(width, height)


		floor := make([dynamic]rune, width * height)
		defer delete(floor)

		slice.fill(floor[:], '.')

		for p in reds {
			idx := index(width, p[0], p[1])
			fmt.println("putting # at idx:", idx, p)
			floor[idx] = '#'
		}

		fmt.println("---------------")
		for y := 0; y <= max_y; y += 1 {
			for x := 0; x <= max_x; x += 1 {
				idx := index(width, x, y)
				r := floor[idx]
				fmt.print(r)
			}
			fmt.print(".")
			fmt.println("")
		}

		for _ in 0 ..= width {
			fmt.print(".")
		}

		fmt.println("\n---------------")
	}
  */
	save_binary :: proc(state: ^State, filename: string) {
		// 1. Convert struct pointer to a byte slice
		// We create a slice of bytes with length = size_of(State)
		data_bytes := ([^]byte)(state)[:size_of(State)]

		// 2. Write directly to file
		success := os.write_entire_file(filename, data_bytes)
		if !success {
			fmt.println("Failed to write file!")
		}
	}

	load_binary :: proc(filename: string) -> (State, bool) {
		state: State

		// 1. Read entire file
		data, success := os.read_entire_file(filename)
		if !success {return state, false}
		defer delete(data) // Clean up file buffer

		// 2. Safety check: Is the file size correct?
		if len(data) != size_of(State) {
			fmt.println("File size mismatch! Struct definition likely changed.")
			return state, false
		}

		// 3. Copy bytes into the struct
		// We get a pointer to the struct, cast to byte pointer, and copy memory
		mem.copy(&state, raw_data(data), size_of(State))

		return state, true
	}
	intersect :: proc(l1, l2: [2][2]int) -> bool {
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

	count_intersections :: proc(l: [2][2]int, lines: [][2][2]int) -> int {
		count := 0
		for o_l in lines {
			fmt.println("check intersect:", l, o_l)
			if intersect(l, o_l) do count += 1
		}
		return count
	}

	data := os.read_entire_file("input") or_else os.exit(1)
	defer delete(data)
	s := string(data)


	lines := strings.split_lines(s)
	reds := make([dynamic][2]int, len(lines) - 1)
	defer delete(reds)

	for l, i in lines {
		if len(l) == 0 do break
		parts := strings.split(l, ",")
		x := strconv.parse_int(parts[0]) or_else os.exit(1)
		y := strconv.parse_int(parts[1]) or_else os.exit(1)

		reds[i] = {x, y}
	}

	Field :: struct {
		reds:  [][2]int,
		lines: [][2][2]int,
	}

	fields := make([dynamic]Field, 0)
	defer delete(fields)

	max_x := 0
	max_y := 0

	for r in reds {
		if r[0] > max_x do max_x = r[0]
		if r[1] > max_y do max_y = r[1]
	}


	//reds_to_remove := make([dynamic][2]int)
	//defer delete(reds_to_remove)
	dirs := [4][2]int{{-1, 0}, {0, -1}, {1, 0}, {0, 1}}

	for len(reds) > 0 {
		current_field_reds := make([dynamic][2]int, 0, len(reds))
		current_field_lines := make([dynamic][2][2]int, 0, len(reds) / 2)

		first_red := pop(&reds)
		append(&current_field_reds, first_red)

		cr := first_red

		next_red_idx := 0
		for next_red_idx > -1 {
			next_red_idx = -1

			//find arbitrary next red by following in one direction
			//after the other starting at current pos
			dir_loop: for d in dirs {
				np := cr + d
				for np[0] >= 0 && np[0] <= max_x && np[1] >= 0 && np[1] <= max_y {
					np += d

					for nr, i in reds {
						if nr == np {
							//fmt.println("Found next in dir", d, nr, i)
							next_red_idx = i
							break dir_loop
						}
					}
				}
				//fmt.println("Found none in dir:", d)
			}

			if (next_red_idx > -1) {
				nr := reds[next_red_idx]
				//append line
				append(&current_field_lines, [2][2]int{cr, nr})

				cr = nr
				append(&current_field_reds, cr)
				unordered_remove(&reds, next_red_idx)
			}
		}

		//add final closing line
		append(&current_field_lines, [2][2]int{cr, first_red})

		current_f := Field {
			reds  = current_field_reds[:],
			lines = current_field_lines[:],
		}
		append(&fields, current_f)
	}

	fmt.println(fields, len(fields))

	//find the biggest rectangle in all fields
	Area :: struct {
		c_1:    [2]int,
		dist_x: int,
		c_2:    [2]int,
		dist_y: int,
		area:   int,
	}

	areas := make([dynamic]Area, 0, len(reds) * len(reds))

	for f in fields {
		for p_1, i in f.reds {

			inner_reds_loop: for j := i + 1; j < len(f.reds); j += 1 {
				p_2 := f.reds[j]

				//check valid rect
				//no other "red" can be "inside" this rect
				for o_r in f.reds {

					if p_1[1] > p_2[1] {
						if o_r[1] > p_1[1] || o_r[1] < p_2[1] {
							continue inner_reds_loop
						}
					} else if p_1[1] < p_2[1] {
						if o_r[1] < p_1[1] || o_r[1] > p_2[1] {
							continue inner_reds_loop
						}
					} else {
						//same line continue, because resulting rect would have size 0
						continue inner_reds_loop
					}

					if p_1[0] > p_2[0] {
						if o_r[0] > p_1[0] || o_r[0] < p_2[0] {
							continue inner_reds_loop
						}
					} else if p_1[0] < p_2[0] {
						if o_r[0] < p_1[0] || o_r[0] > p_2[0] {
							continue inner_reds_loop
						}
					} else {
						//same line continue, because resulting rect would have size 0
						continue inner_reds_loop
					}
				}

				//the rect actually has to span over the field
				center := [2]int{(p_1[0] + p_2[0]) / 2, (p_1[1] + p_2[1]) / 2}
				left_line := [2][2]int{center, {0, center[1]}}
				right_line := [2][2]int{center, {center[1], max_y}}
				top_line := [2][2]int{center, {center[0], 0}}
				bottom_line := [2][2]int{center, {center[0], max_x}}

				count_left := count_intersections(left_line, f.lines[:])
				fmt.println("count_left", count_left, left_line, p_1, p_2)
				//if count_left % 2 == 0 do continue inner_reds_loop

				count_right := count_intersections(right_line, f.lines[:])
				//if count_right % 2 == 0 do continue inner_reds_loop

				count_top := count_intersections(top_line, f.lines[:])
				//if count_top % 2 == 0 do continue inner_reds_loop

				count_bottom := count_intersections(bottom_line, f.lines[:])
				//if count_bottom % 2 == 0 do continue inner_reds_loop

				dist_x := abs(p_1[0] - p_2[0]) + 1
				dist_y := abs(p_1[1] - p_2[1]) + 1

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


	slice.sort_by(areas[:], proc(a, b: Area) -> bool {
		return a.area > b.area
	})

	current_dist_index := 0
	current_field_index := 0

	timer := f32(0.0)
	duration_per_dist := f32(0.001) // How long to show each dist
	paused := true

	// do game loop
	active_dists := [dynamic][2][2]int{}
	defer delete(active_dists)

	//setup raylib
	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_RESIZABLE, .MSAA_4X_HINT})
	rl.InitWindow(1600, 1200, "XMAS Tiles")
	defer rl.CloseWindow()

	design_width := i32(max_x)
	design_height := i32(max_y)

	camera := rl.Camera2D{}
	// have to visualize this I fear
	for !rl.WindowShouldClose() {
		rl.ClearBackground(rl.RAYWHITE)
		current_field := fields[current_dist_index]

		screen_w := rl.GetScreenWidth()
		screen_h := rl.GetScreenHeight()

		scale := min(screen_w / design_width, screen_h / design_height)
		camera.zoom = f32(scale)
		camera.offset = {
			f32(screen_w - design_width * scale) * 0.5,
			f32(screen_h - design_height * scale) * 0.5,
		}
		timer += rl.GetFrameTime()

		// Check if the duration has passed
		if timer >= duration_per_dist {
			timer = 0.0 // Reset timer

			// Move to next line, if not paused
			if !paused {
				current_dist_index += 1
			}

			if current_dist_index >= len(current_field.lines) {
				current_dist_index = 0

				if (current_field_index >= len(fields)) {
					current_field_index = 0
				} else {
					current_field_index += 1
				}
			}
		}

		rl.BeginDrawing()
		rl.BeginMode2D(camera)

		line := current_field.lines[current_dist_index]
		if !slice.contains(active_dists[:], line) {
			append(&active_dists, line)
		}

		rl.DrawLine(i32(line[0][0]), i32(line[0][1]), i32(line[1][0]), i32(line[1][1]), rl.GREEN)

		rl.EndMode2D()
		rl.EndDrawing()
	}


	//fmt.println("Result:", areas[0])
}
