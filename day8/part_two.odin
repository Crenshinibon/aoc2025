#+feature dynamic-literals

package main

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

main :: proc() {

	//FILE :: "input_small"
	//TARGET :: 11
	//FACTOR :: 100
	//CAM_OFFSET :: 10

	FILE :: "input"
	TARGET :: 1000
	FACTOR :: 1000
	CAM_OFFSET :: 100

	// read points from input
	data := os.read_entire_file(FILE) or_else os.exit(1)
	defer delete(data)
	s := string(data)
	lines := strings.split_lines(s)

	points := make([dynamic]rl.Vector3, 0, len(lines))
	defer delete(points)

	for l in lines {
		if len(l) == 0 do continue
		parts := strings.split(l, ",")
		x := (strconv.parse_f32(parts[0]) or_else os.exit(1)) / FACTOR
		y := (strconv.parse_f32(parts[1]) or_else os.exit(1)) / FACTOR
		z := (strconv.parse_f32(parts[2]) or_else os.exit(1)) / FACTOR
		append(&points, rl.Vector3{x, y, z})
	}

	//setup raylib
	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_RESIZABLE, .MSAA_4X_HINT})
	rl.InitWindow(1600, 1200, "XMAS - Lights")
	defer rl.CloseWindow()

	max_x := f32(0)
	max_y := f32(0)
	max_z := f32(0)

	for p in points {
		if p.x > max_x do max_x = p.x
		if p.y > max_y do max_y = p.y
		if p.z > max_z do max_z = p.z
	}

	camera_pos := rl.Vector3{max_x + CAM_OFFSET, max_y + CAM_OFFSET, max_z + CAM_OFFSET}
	camera := rl.Camera3D {
		position   = camera_pos,
		target     = {0, 0, 0}, //{max_x / 2, max_y / 2, max_z / 2},
		up         = {0, 1, 0},
		fovy       = 45.0,
		projection = .PERSPECTIVE,
	}
	rl.SetTargetFPS(60)

	Dist :: struct {
		p_i:  rl.Vector3,
		p_j:  rl.Vector3,
		dist: f32,
	}

	distances := make([dynamic]Dist, 0, len(points) * len(points))
	for p_i, i in points {
		for j := i + 1; j < len(points); j += 1 {
			p_j := points[j]
			append(&distances, Dist{p_i, p_j, rl.Vector3Distance(p_i, p_j)})
		}
	}

	slice.sort_by(distances[:], proc(a, b: Dist) -> bool {
		return a.dist < b.dist
	})

	/*for d, i in distances {
		fmt.println(i, "->", d)
	}*/


	Circuit :: struct {
		points: [dynamic]rl.Vector3,
		dists:  [dynamic]Dist,
	}

	circuits := make([dynamic]Circuit, 0, TARGET)
	defer delete(circuits)


	keep_going := true
	i := 0

	dist_loop: for keep_going {
		d := distances[i]
		i += 1

		//remember circuits
		circ_i_idx := -1
		circ_j_idx := -1

		for &c, c_idx in circuits {
			//ignore distinances between points already part of a circuit
			if slice.contains(c.points[:], d.p_i) && slice.contains(c.points[:], d.p_j) {
				continue dist_loop
			}

			// we have a circuit, whos points include p_i
			if slice.contains(c.points[:], d.p_i) {
				circ_i_idx = c_idx

			}
			if slice.contains(c.points[:], d.p_j) {
				circ_j_idx = c_idx
			}
		}

		//merge
		if circ_i_idx >= 0 && circ_j_idx >= 0 {
			target := &circuits[circ_i_idx]
			append(&target.dists, d)

			source := &circuits[circ_j_idx]
			for p in source.points {
				if !slice.contains(target.points[:], p) {
					append(&target.points, p)
				}
			}

			for d in source.dists {
				if !slice.contains(target.dists[:], d) {
					append(&target.dists, d)
				}
			}

			unordered_remove(&circuits, circ_j_idx)
		} else if circ_i_idx >= 0 {
			c := &circuits[circ_i_idx]
			append(&c.dists, d)
			append(&c.points, d.p_j)

		} else if circ_j_idx >= 0 {
			c := &circuits[circ_j_idx]
			append(&c.dists, d)
			append(&c.points, d.p_i)

		} else {
			//otherwise add new circuit
			c := Circuit {
				points = [dynamic]rl.Vector3{d.p_i, d.p_j},
				dists  = [dynamic]Dist{d},
			}
			append(&circuits, c)
		}


		if i > TARGET && len(circuits) == 1 {
			//check if all points are contained in the points list of the remaining circuit
			contains_all := true
			for p in points {
				if !slice.contains(circuits[0].points[:], p) {
					contains_all = false
					break
				}
			}

			if contains_all {
				keep_going = false
				fmt.println("Final dist:", distances[i - 1])
			}
		}
	}


	current_dist_index := 0
	timer := f32(0.0)
	duration_per_dist := f32(0.001) // How long to show each dist
	paused := true

	// do game loop
	active_dists := [dynamic]Dist{}
	defer delete(active_dists)

	for !rl.WindowShouldClose() {
		rl.UpdateCamera(&camera, .ORBITAL)
		rl.ClearBackground(rl.RAYWHITE)


		// Accumulate the time passed since the last frame
		timer += rl.GetFrameTime()

		// Check if the duration has passed
		if timer >= duration_per_dist {
			timer = 0.0 // Reset timer

			// Move to next line, if not paused
			if !paused {
				current_dist_index += 1
			}

			if current_dist_index >= len(distances) {
				current_dist_index = 0
			}
		}

		rl.BeginDrawing()
		rl.BeginMode3D(camera)

		if rl.IsKeyDown(rl.KeyboardKey.UP) {
			camera.fovy -= 1
		}
		if rl.IsKeyDown(rl.KeyboardKey.DOWN) {
			camera.fovy += 1
		}
		if rl.IsKeyDown(rl.KeyboardKey.SPACE) {
			paused = !paused
		}

		for p, i in points {
			rl.DrawCube(p, 0.3, 0.2, 0.2, rl.RED)
			rl.DrawCubeWires(p, 0.3, 0.2, 0.2, rl.BLACK)
		}

		line := distances[current_dist_index]
		if !slice.contains(active_dists[:], line) {
			append(&active_dists, line)
		}

		for d in circuits[0].dists {
			if slice.contains(active_dists[:], d) {
				rl.DrawCylinderEx(d.p_i, d.p_j, 0.1, 0.1, 8, rl.GREEN)
			} else {
				rl.DrawCylinderEx(line.p_i, line.p_j, 0.1, 0.1, 8, rl.BLUE)
			}
		}

		rl.DrawCube(
			{max_x / 2, max_y / 2, max_z / 2},
			max_x + 1,
			max_y + 1,
			max_z + 1,
			rl.Fade(rl.GRAY, 0.5),
		)
		rl.DrawCubeWires(
			{max_x / 2, max_y / 2, max_z / 2},
			max_x + 1,
			max_y + 1,
			max_z + 1,
			rl.BLACK,
		)

		rl.EndMode3D()
		rl.EndDrawing()
	}
}
