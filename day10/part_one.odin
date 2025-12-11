package main

import "core:container/queue"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {
	data := os.read_entire_file("input_small") or_else os.exit(1)
	defer delete(data)
	s := string(data)

	result := 0

	/*
   * This is actually just numbers
   */
	Machine :: struct {
		bit_width:      uint,
		desired_state:  uint,
		button_wirings: []uint,
	}

	lines := strings.split_lines(s)
	machines := make([dynamic]Machine, 0, len(lines))
	defer for m in machines {
		delete(m.button_wirings)
	}
	defer delete(machines)

	for l in lines {
		if len(l) == 0 do break

		parts := strings.split(l, " ")
		d_state: uint = 0

		ind_ligths_string, _ := strings.substring(parts[0], 1, len(parts[0]) - 1)
		for c, i in ind_ligths_string {
			to_add: uint = 0
			if c == '#' {
				to_add = 1 << uint(i)
			}
			d_state |= to_add
		}

		wirings := make([dynamic]uint, 0)

		//read the wirings
		for w, i in parts[1:] {
			//ignore joltage
			if w[0] == '{' do break

			numbers, _ := strings.substring(w, 1, len(w) - 1)
			numbers_array := strings.split(numbers, ",")

			wiring: uint = 0
			for num_str, j in numbers_array {
				num := strconv.parse_uint(num_str) or_else os.exit(1)
				to_add: uint = 1 << num
				wiring |= to_add
			}

			append(&wirings, wiring)
		}

		m := Machine {
			bit_width      = len(ind_ligths_string),
			desired_state  = d_state,
			button_wirings = wirings[:],
		}

		append(&machines, m)
	}
	fmt.println("Machines read:", machines)


	//bfs for every machine
	for mac in machines {
		m := 1 << mac.bit_width
		fmt.println(m)

		min_additions := make([dynamic]uint, m)
		min_additions[0] = 0


	}
	fmt.println("Result:", result)
}
