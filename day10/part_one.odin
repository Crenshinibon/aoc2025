package main
import "core:container/queue"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {
	data := os.read_entire_file("input_tiny") or_else os.exit(1)
	defer delete(data)
	s := string(data)

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
			//ignore joltage, for now
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

	result: uint = 0
	//bfs for every machine
	for mac in machines {
		q := make([dynamic]uint, 0, mac.desired_state)
		defer delete(q)
		append(&q, 0)

		m: uint = 1 << mac.bit_width
		min_adds := make([dynamic]uint, m)
		defer delete(min_adds)
		min_adds[0] = 0

		outer: for i := 0; i < len(q); i += 1 {
			fmt.println("q", q)

			current_sum := pop(&q)
			current_add := min_adds[current_sum]

			for w in mac.button_wirings {
				next_sum: uint = (current_sum + w) % m
				if min_adds[next_sum] == 0 || min_adds[next_sum] > (current_sum - 1) {
					min_adds[next_sum] = current_add + 1
				}

				fmt.println(
					"\nnext_sum",
					next_sum,
					"current_sum",
					current_sum,
					"w",
					w,
					"current_add",
					current_add,
					"\nsteps",
					min_adds,
				)
				if next_sum == mac.desired_state {
					// I cannot break for the first, but should, don't I do breath fist search then?
					break outer
				} else {
					append(&q, next_sum)
				}
			}
		}
		result += min_adds[mac.desired_state]
	}
	fmt.println("Result:", result)

}
