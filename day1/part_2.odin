package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

main :: proc() {
	data := os.read_entire_file("input") or_else os.exit(1)
	defer delete(data)
	s := string(data)

	result := 0
	current_pos := 50

	for line in strings.split_lines_iterator(&s) {

		num_string := line[1:]
		num := strconv.parse_int(num_string) or_else os.exit(1)
		dir := line[0]

		if dir == 'R' {
			sum := current_pos + num

			div := sum / 100
			rem := sum % 100

			fmt.print("overflow adding", div, ": ")
			result += div
			fmt.println(rune(dir), current_pos, num, sum, div, rem)
			current_pos = rem
		} else {
			sum := current_pos - num
			if sum <= 0 {
				if current_pos != 0 {
					result += 1
					fmt.print("underflow not zero adding 1 : ")
				}

				if sum <= -100 {
					div := sum / -100
					fmt.print("underflow adding", div, ": ")
					result += div
				}

				rem := abs(sum % 100)

				if rem == 0 {
					fmt.println(rune(dir), current_pos, num, sum, 0)
					current_pos = 0
				} else {
					fmt.println(rune(dir), current_pos, num, sum, 100 - rem)
					current_pos = 100 - rem
				}

			} else {
				fmt.print("nothing special : ")
				fmt.println(rune(dir), current_pos, num, sum)
				current_pos = sum
			}

		}
	}

	fmt.println(result)
}
