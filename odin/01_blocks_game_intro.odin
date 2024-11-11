package main

import rl "vendor:raylib"

Game_Screen :: enum {
	LOGO,
	TITLE,
	GAMEPLAY,
	ENDING,
}

main :: proc() {
	SCREEN_WIDTH :: 800
	SCREEN_HEIGHT :: 450

	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "PROJECT: BLOCKS GAME")

	// Game required variables
	screen := Game_Screen.LOGO // Current game screen state
	frames_counter := 0 // General pourpose frames counter
	game_result := -1 // Game result: 0 - Loose, 1 - Win, -1 - Not defined
	game_paused := false // Game paused state toggle

	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		// Update
		//----------------------------------------------------------------------------------
		switch screen {
		case .LOGO:
			{
				frames_counter += 1
				if frames_counter > 180 {
					screen = .TITLE // Change to TITLE screen after 3 seconds
					frames_counter = 0
				}
			}
		case .TITLE:
			{
				frames_counter += 1
				if rl.IsKeyPressed(.ENTER) do screen = .GAMEPLAY
			}
		case .GAMEPLAY:
			{
				if !game_paused {}
				if rl.IsKeyPressed(.ENTER) do screen = .ENDING
			}
		case .ENDING:
			{
				frames_counter += 1
				if rl.IsKeyPressed(.ENTER) do screen = .TITLE
			}
		}
		//----------------------------------------------------------------------------------

		// Draw
		//----------------------------------------------------------------------------------
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		switch screen {
		case .LOGO:
			{
				rl.DrawText("LOGO SCREEN", 20, 20, 40, rl.LIGHTGRAY)
				rl.DrawText("WAIT for 3 SECONDS...", 290, 220, 20, rl.GRAY)
			}
		case .TITLE:
			{
				rl.DrawRectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, rl.GREEN)
				rl.DrawText("TITLE SCREEN", 20, 20, 40, rl.DARKGREEN)
				rl.DrawText(
					"PRESS ENTER or TAP to JUMP to GAMEPLAY SCREEN",
					120,
					220,
					20,
					rl.DARKGREEN,
				)
			}
		case .GAMEPLAY:
			{
				rl.DrawRectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, rl.PURPLE)
				rl.DrawText("GAMEPLAY SCREEN", 20, 20, 40, rl.MAROON)
				rl.DrawText("PRESS ENTER or TAP to JUMP to ENDING SCREEN", 130, 220, 20, rl.MAROON)
			}
		case .ENDING:
			{
				rl.DrawRectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, rl.BLUE)
				rl.DrawText("ENDING SCREEN", 20, 20, 40, rl.DARKBLUE)
				rl.DrawText(
					"PRESS ENTER or TAP to RETURN to TITLE SCREEN",
					120,
					220,
					20,
					rl.DARKBLUE,
				)
			}
		}

		rl.EndDrawing()
	}

	// De-Initialization
	//--------------------------------------------------------------------------------------
	rl.CloseWindow()
}
