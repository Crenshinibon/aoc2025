package main

import "core:container/intrusive/list"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"


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

	//fmt.println(reds)

	//finding "greens" => reds that are connected on straight lines
	Field :: struct {
		reds: [][2]int,
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
				cr = reds[next_red_idx]
				append(&current_field_reds, cr)

				unordered_remove(&reds, next_red_idx)
			}
		}

		current_f := Field {
			reds = current_field_reds[:],
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
			for j := i + 1; j < len(f.reds); j += 1 {
				p_2 := f.reds[j]

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

	/*
   * STILL NOT, presumably I also have to check if the resulting rectangle is completely
   * "inside" the field. In my result I have one field, that includes both corners of 
   * the solution from part one.
   */


	fmt.println("Result:", areas[0])
}
