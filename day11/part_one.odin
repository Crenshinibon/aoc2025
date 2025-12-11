package main

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"


main :: proc() {
	data := os.read_entire_file("input_small") or_else os.exit(1)
	defer delete(data)
	s := string(data)

	result := 0

	Machine :: struct {
		state:          []bool,
		desired_state:  []bool,
		button_wirings: [][dynamic]int,
	}

	lines := strings.split_lines(s)
	machines := make([dynamic]Machine, 0, len(lines))

	for l in lines {
		if len(l) == 0 do break

		parts := strings.split(l, " ")
		d_state := make([dynamic]bool)
		for c in parts[0] {
			if c == '[' || c == ']' do continue

			if c == '.' {
				append(&d_state, false)
			} else if c == '#' {
				append(&d_state, true)
			}
		}
		c_state := make([dynamic]bool, len(d_state))

		wirings := make([dynamic][dynamic]int, 0)

		//read the wirings
		for w, i in parts[1:] {
			//ignore joltage
			if w[0] == '{' do break

			numbers, _ := strings.substring(w, 1, len(w) - 1)
			numbers_array := strings.split(numbers, ",")

			append(&wirings, make([dynamic]int, len(numbers_array)))
			for num_str, j in numbers_array {
				num := strconv.parse_int(num_str) or_else os.exit(1)
				wirings[i][j] = num
			}
		}
		fmt.println(wirings)


		m := Machine {
			state          = c_state[:],
			desired_state  = d_state[:],
			button_wirings = wirings[:],
		}

		append(&machines, m)
	}

	fmt.println("Machines", machines)


	fmt.println("Result:", result)
}
