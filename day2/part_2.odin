package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

check_doubled_p2 :: proc(input: int) -> bool {
	input_string := fmt.aprintf("%v", input)

	length := len(input_string)
	half := length / 2

	length_loup: for gr_length := 1; gr_length <= half; gr_length += 1 {
		//check group modulo to see if a pattern is possible, otherwise skip to next group
		if length % gr_length != 0 {continue}

		first_group := input_string[:gr_length]
		for gr_count := 1; (gr_count + 1) * gr_length <= length; gr_count += 1 {
			offset := gr_length * gr_count
			next_group := input_string[offset:offset + gr_length]
			if first_group != next_group {
				continue length_loup
			}
		}
		return true
	}

	return false
}


main :: proc() {
	data := os.read_entire_file("input") or_else os.exit(1)
	defer delete(data)
	s := string(data)

	result := 0
	for id_pair_string in strings.split_iterator(&s, ",") {

		id_pair := strings.split(id_pair_string, "-")
		start_id := strconv.parse_int(id_pair[0]) or_else os.exit(1)
		end_id := strconv.parse_int(strings.trim_space(id_pair[1])) or_else os.exit(1)
		fmt.println("checking", start_id, "to", end_id)

		current_id := start_id
		for current_id <= end_id {
			if check_doubled_p2(current_id) {
				result = result + current_id
				fmt.println("found one", current_id, "result:", result)
			}
			current_id = current_id + 1
		}
	}

	fmt.println("Result:", result)
}
