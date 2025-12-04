package main

import "core:fmt"
import "core:os"
import "core:strings"


GRID_SIZE :: 136
print_grid :: proc(grid: [GRID_SIZE][GRID_SIZE]rune) {
	fmt.println("GRID:")
	for i := 0; i < len(grid); i += 1 {
		for j := 0; j < len(grid); j += 1 {
			fmt.print(grid[i][j])
		}
		fmt.println("")
	}
}

main :: proc() {

	grid := [GRID_SIZE][GRID_SIZE]rune{}

	data := os.read_entire_file("input") or_else os.exit(1)
	defer delete(data)
	s := string(data)

	for line, i in strings.split_lines(s) {
		if len(line) == 0 {continue}
		for c, j in line {
			grid[i][j] = c
		}
	}

	Dir :: struct {
		x, y: int,
	}

	result := 0
	DIRS :: [8]Dir{{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}}

	print_grid(grid)

	keep_running := true
	for keep_running {
		keep_running = false

		for i := 0; i < GRID_SIZE; i += 1 {
			for j := 0; j < GRID_SIZE; j += 1 {
				current := grid[i][j]
				if current == '@' {

					count := 0
					for dir in DIRS {
						x := i + dir.x
						y := j + dir.y

						if (x < GRID_SIZE && x >= 0 && y < GRID_SIZE && y >= 0) {
							sur := grid[x][y]
							if sur == '@' {count += 1}
						}
					}

					if count < 4 {
						grid[i][j] = '.'
						result += 1
						keep_running = true
					}
				}
			}
		}

		print_grid(grid)
	}


	fmt.println("Result:", result)
}
