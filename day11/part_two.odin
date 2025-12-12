package main

import "core:container/queue"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"

main :: proc() {
	START :: "svr"
	TARGET :: "out"

	data := os.read_entire_file("input") or_else os.exit(1)
	defer delete(data)

	s := string(data)
	lines := strings.split_lines(s)

	Path :: struct {
		steps: [dynamic]string,
	}
	q: queue.Queue(Path)
	queue.init(&q, len(lines))
	defer queue.destroy(&q)

	first_path := Path {
		steps = make([dynamic]string, 1),
	}
	first_path.steps[0] = START

	queue.push_back(&q, first_path)

	keep_going := true
	outer: for keep_going {
		keep_going = false

		current_path := queue.pop_front(&q)
		last_element := current_path.steps[len(current_path.steps) - 1]
		fmt.println("\ncurrent path:", current_path.steps, "last_element:", last_element)

		for l in lines {
			if strings.starts_with(l, last_element) {
				parts := strings.split(l, " ")
				for i := 1; i < len(parts); i += 1 {
					new_step := parts[i]
					//fmt.println("from", last_element, "to", new_step)

					if new_step != TARGET {
						//been here
						if slice.contains(current_path.steps[:], new_step) {
							fmt.println("LOOP detected")
							continue outer
						}

						new_steps := make(
							[dynamic]string,
							len(current_path.steps),
							len(current_path.steps) + 1,
						)
						for s, i in current_path.steps {
							new_steps[i] = s
						}
						append(&new_steps, parts[i])

						queue.push_back(&q, Path{steps = new_steps})
						keep_going = true
					} else {
						append(&current_path.steps, TARGET)
						queue.push_back(&q, current_path)
					}
				}
			}
		}
	}

	result := 0
	for queue.len(q) > 0 {
		path := queue.pop_front(&q)
		fmt.println(path)

		found_dac := false
		found_fft := false

		for s in path.steps {
			if s == "dac" {
				found_dac = true
			}
			if s == "fft" {
				found_fft = true
			}
		}

		if found_dac && found_fft {
			result += 1
		}
	}

	fmt.println("Result:", result)
}
