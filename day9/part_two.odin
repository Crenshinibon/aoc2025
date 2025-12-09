package main

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

	fmt.println(reds)

	//finding "greens" => reds that are connected on straight lines
	Field :: struct {
		reds: [][2]int,
	}

	fields := make([dynamic]Field, 0)
	defer delete(fields)

	//reds_to_remove := make([dynamic][2]int)
	//defer delete(reds_to_remove)
	max_x := 0
	max_y := 0

	for p in reds {
		if p[0] > max_x do max_x = p[0]
		if p[1] > max_y do max_y = p[1]
	}

	//for len(reds) > 0 {
	for r in reds {
		count_x := 0
		count_y := 0
		//	current_f := new(Field)
		//	current_red := pop(&reds)

		//find next red by following in all directions (same row / column)
		//look in same row
		for i in 0 ..= max_x {
			for p in reds {
				if p[0] == r[0] && p[1] != r[1] {
					count_x += 1
					fmt.println("Found another", p, r, count_x)
				}
			}
		}
		for i in 0 ..= max_y {
			for p in reds {
				if p[1] == r[1] && p[0] != r[0] {
					count_y += 1
					fmt.println("Found another", p, r, count_y)
				}
			}
		}
	}


	/*
	Area :: struct {
		c_1:    [2]int,
		dist_x: int,
		c_2:    [2]int,
		dist_y: int,
		area:   int,
	}

	areas := make([dynamic]Area, 0, len(reds) * len(reds))

	for p_1, i in reds {
		for j := i + 1; j < len(reds); j += 1 {
			p_2 := reds[j]

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

	slice.sort_by(areas[:], proc(a, b: Area) -> bool {
		return a.area > b.area
	})

  */

	fmt.println("Result:")
}
