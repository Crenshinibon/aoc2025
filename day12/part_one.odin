package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

Present :: struct {
	shape: uint,
}

read_presents :: proc(allocator := context.allocator) -> []Present {
	data := os.read_entire_file("input_presents_small", allocator) or_else os.exit(1)
	defer delete(data)

	s := string(data)
	lines := strings.split_lines(s)

	presents := make([]Present, 6, allocator)
	present_index := 0
	in_present_index: uint = 0

	for l in lines {
		if (l != "") {
			for c, j in l {
				if (c == '#') {
					mask := 1 << in_present_index * 3 + uint(j)
					presents[present_index].shape ~= mask
				}
			}
			in_present_index += 1
		} else {
			in_present_index = 0
			present_index += 1
		}
	}
	return presents[:]
}

Container :: struct {
	width:          int,
	height:         int,
	presents_count: [6]int,
}

read_container :: proc(allocator := context.allocator) -> []Container {
	data := os.read_entire_file("input_containers_small", allocator) or_else os.exit(1)
	defer delete(data)

	s := string(data)
	lines := strings.split_lines(s)

	containers := make([dynamic]Container, 0, allocator)

	for l in lines {
		if len(l) == 0 do break

		parts := strings.split(l, ":")
		dims_strings := strings.split(parts[0], "x")

		cont := Container {
			width  = strconv.parse_int(dims_strings[0]) or_else os.exit(1),
			height = strconv.parse_int(dims_strings[1]) or_else os.exit(1),
		}

		presents_count_strings := strings.split(parts[1], " ")
		present_count_index := 0
		for pcs in presents_count_strings {
			if pcs == "" do continue


			fmt.println("parsing", pcs)
			present_count := strconv.parse_int(pcs) or_else os.exit(1)
			cont.presents_count[present_count_index] = present_count
			present_count_index += 1
		}
		append(&containers, cont)
	}

	return containers[:]
}


main :: proc() {
	presents := read_presents(context.allocator)
	fmt.println(presents)

	container := read_container(context.allocator)
	fmt.println(container)

	//
	result := 0
	fmt.println("Result:", result)
}
