package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"


main :: proc() {

	NUMBERS :: "987654321"

	data := os.read_entire_file("input") or_else os.exit(1)
	defer delete(data)
	s := string(data)

	result := 0
	for line in strings.split_lines_iterator(&s) {
		if len(line) == 0 {continue}

		//find position of heighest number
		first_num := '0'
		highest_index := 0
		numbers_loop: for n in NUMBERS {
			for c, i in line[:len(line) - 1] {
				if c == n {
					highest_index = i
					first_num = n

					break numbers_loop
				}
			}
		}

		second_num := '0'
		//start from index and look for highest number
		numbers_loop_2: for n in NUMBERS {
			for c, i in line[highest_index + 1:] {
				if c == n {
					second_num = n
					break numbers_loop_2
				}
			}
		}

		fmt.println("Found Numbers:", first_num, second_num)

		jolt_string := fmt.aprintf("%v%v", first_num, second_num)
		fmt.println("Found Numbers:", jolt_string)
		jolt := strconv.parse_int(jolt_string) or_else os.exit(1)

		result += jolt
	}

	fmt.println("Result:", result)
}
