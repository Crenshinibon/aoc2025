package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

main :: proc() {
	data := os.read_entire_file("input_small") or_else os.exit(1)
	defer delete(data)
	s := string(data)

	result := 0
	current_pos := 50

	for line in strings.split_lines_iterator(&s) {
		if len(line) == 0 {continue}

		num_string := line[1:]
		num := strconv.parse_int(num_string) or_else os.exit(1)

		if line[0] == 'R' {
			fmt.println("Right, from: ", current_pos, " add: ", num)
			new_pos := current_pos + num

			for new_pos > 99 {
				result = result + 1
				new_pos = new_pos - 100
				fmt.println("Overflow, adding one", new_pos)
			}

			current_pos = new_pos
		} else {

			starting_at_zero := current_pos == 0

			fmt.println("Left, from: ", current_pos, " rem: ", num)
			new_pos := current_pos - num

			if new_pos == 0 {
				fmt.println("new pos is 0, adding one")
				result = result + 1
			} else {
				for new_pos < 0 {
					new_pos = new_pos + 100

					if !starting_at_zero {
						result = result + 1
						starting_at_zero = false
						fmt.println("Underflow, adding one", new_pos)
					}
				}
			}

			current_pos = new_pos
		}
	}

	fmt.println(result)
}
