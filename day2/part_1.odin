package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

check_doubled :: proc(input: int) -> bool {
	input_string := fmt.aprintf("%v", input)

	length := len(input_string)
	//odd length to so no doubling possible
	if length % 2 != 0 {return false}


	part_length := length / 2
	first_part := input_string[0:part_length]

	second_part := input_string[part_length:]

	fmt.printfln(
		"input: %v => parts: %v - %v - partlength: %v",
		input_string,
		first_part,
		second_part,
		part_length,
	)

	if first_part == second_part {
		fmt.println("Found One", input_string)
		return true
	}

	return false
}


main :: proc() {
	data := os.read_entire_file("input_small") or_else os.exit(1)
	defer delete(data)
	s := string(data)

	result := 0
	for id_pair_string in strings.split_iterator(&s, ",") {

		id_pair := strings.split(id_pair_string, "-")
		start_id := strconv.parse_int(id_pair[0]) or_else os.exit(1)
		end_id := strconv.parse_int(id_pair[1]) or_else os.exit(1)

		current_id := start_id
		for current_id <= end_id {
			if check_doubled(current_id) {
				result = result + current_id
				fmt.println("found one", current_id, "result:", result)
			}
			current_id = current_id + 1
		}
	}

	fmt.println("Result:", result)
}
