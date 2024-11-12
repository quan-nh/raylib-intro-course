/*******************************************************************************************
*
*   PROJECT:        BLOCKS GAME
*   LESSON 03:      inputs management
*   DESCRIPTION:    Read user inputs (keyboard, mouse)
*
*   COMPILATION (Windows - MinGW):
*       gcc -o $(NAME_PART).exe $(FILE_NAME) -lraylib -lopengl32 -lgdi32 -lwinmm -Wall -std=c99
*
*   COMPILATION (Linux - GCC):
*       gcc -o $(NAME_PART).exe $(FILE_NAME) -lraylib -lGL -lm -lpthread -ldl -lrt -lX11
*
*   Example originally created with raylib 2.0, last time updated with raylib 4.2

*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2017-2022 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

package main

import rl "vendor:raylib"

//----------------------------------------------------------------------------------
// Useful values definitions
//----------------------------------------------------------------------------------
PLAYER_LIFES :: 5
BRICKS_LINES :: 5
BRICKS_PER_LINE :: 20

BRICKS_POSITION_Y :: 50

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------

// LESSON 01: Window initialization and screens management
GameScreen :: enum {
	LOGO,
	TITLE,
	GAMEPLAY,
	ENDING,
}

// Player structure
Player :: struct {
	position: rl.Vector2,
	speed:    rl.Vector2,
	size:     rl.Vector2,
	bounds:   rl.Rectangle,
	lifes:    int,
}

// Ball structure
Ball :: struct {
	position: rl.Vector2,
	speed:    rl.Vector2,
	radius:   f32,
	active:   bool,
}

// Bricks structure
Brick :: struct {
	position:   rl.Vector2,
	size:       rl.Vector2,
	bounds:     rl.Rectangle,
	resistance: int,
	active:     bool,
}

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: proc() {
	// Initialization
	//--------------------------------------------------------------------------------------
	screenWidth :: 800
	screenHeight :: 450

	// LESSON 01: Window initialization and screens management
	rl.InitWindow(screenWidth, screenHeight, "PROJECT: BLOCKS GAME")

	// NOTE: Load resources (textures, fonts, audio) after Window initialization

	// Game required variables
	screen := GameScreen.LOGO // Current game screen state

	framesCounter := 0 // General pourpose frames counter
	gameResult := -1 // Game result: 0 - Loose, 1 - Win, -1 - Not defined
	gamePaused := false // Game paused state toggle

	// NOTE: Check defined structs on top
	player: Player
	ball: Ball
	bricks: [BRICKS_LINES][BRICKS_PER_LINE]Brick

	// Initialize player
	player.position = {screenWidth / 2, screenHeight * 7 / 8}
	player.speed = {8.0, 0.0}
	player.size = {100, 24}
	player.lifes = PLAYER_LIFES

	// Initialize ball
	ball.radius = 10.0
	ball.active = false
	ball.position = {player.position.x + player.size.x / 2, player.position.y - ball.radius * 2}
	ball.speed = {4.0, 4.0}

	// Initialize bricks
	for j := 0; j < BRICKS_LINES; j += 1 {
		for i := 0; i < BRICKS_PER_LINE; i += 1 {
			bricks[j][i].size = {screenWidth / BRICKS_PER_LINE, 20}
			bricks[j][i].position = {
				f32(i) * bricks[j][i].size.x,
				f32(j) * bricks[j][i].size.y + BRICKS_POSITION_Y,
			}
			bricks[j][i].bounds = {
				bricks[j][i].position.x,
				bricks[j][i].position.y,
				bricks[j][i].size.x,
				bricks[j][i].size.y,
			}
			bricks[j][i].active = true
		}
	}

	rl.SetTargetFPS(60) // Set desired framerate (frames per second)
	//--------------------------------------------------------------------------------------

	// Main game loop
	for !rl.WindowShouldClose() // Detect window close button or ESC key
	{
		// Update
		//----------------------------------------------------------------------------------
		switch (screen) 
		{
		case .LOGO:
			{
				// Update LOGO screen data here!

				framesCounter += 1

				if framesCounter > 180 {
					screen = .TITLE // Change to TITLE screen after 3 seconds
					framesCounter = 0
				}

			}
		case .TITLE:
			{
				// Update TITLE screen data here!

				framesCounter += 1

				// LESSON 03: Inputs management (keyboard, mouse)
				if rl.IsKeyPressed(.ENTER) do screen = .GAMEPLAY

			}
		case .GAMEPLAY:
			{
				// Update GAMEPLAY screen data here!

				// LESSON 03: Inputs management (keyboard, mouse)
				if rl.IsKeyPressed(.P) do gamePaused = !gamePaused // Pause button logic

				if !gamePaused {
					// LESSON 03: Inputs management (keyboard, mouse)

					// Player movement logic
					if rl.IsKeyDown(.LEFT) do player.position.x -= player.speed.x
					if rl.IsKeyDown(.RIGHT) do player.position.x += player.speed.x

					if player.position.x <= 0 do player.position.x = 0
					if (player.position.x + player.size.x) >= screenWidth do player.position.x = screenWidth - player.size.x

					player.bounds = {
						player.position.x,
						player.position.y,
						player.size.x,
						player.size.y,
					}

					if ball.active {
						// Ball movement logic
						ball.position.x += ball.speed.x
						ball.position.y += ball.speed.y

						// Collision logic: ball vs screen-limits
						if ((ball.position.x + ball.radius) >= screenWidth) || ((ball.position.x - ball.radius) <= 0) do ball.speed.x *= -1
						if (ball.position.y - ball.radius) <= 0 do ball.speed.y *= -1

						// Collision logic: ball vs player
						if rl.CheckCollisionCircleRec(ball.position, ball.radius, player.bounds) {
							ball.speed.y *= -1
							ball.speed.x =
								(ball.position.x - (player.position.x + player.size.x / 2)) /
								player.size.x *
								5.0
						}

						// Collision logic: ball vs bricks
						for j := 0; j < BRICKS_LINES; j += 1 {
							for i := 0; i < BRICKS_PER_LINE; i += 1 {
								if bricks[j][i].active &&
								   (rl.CheckCollisionCircleRec(
											   ball.position,
											   ball.radius,
											   bricks[j][i].bounds,
										   )) {
									bricks[j][i].active = false
									ball.speed.y *= -1

									break
								}
							}
						}

						// Game ending logic
						if (ball.position.y + ball.radius) >= screenHeight {
							ball.position.x = player.position.x + player.size.x / 2
							ball.position.y = player.position.y - ball.radius - 1.0
							ball.speed = {0, 0}
							ball.active = false

							player.lifes -= 1
						}

						if player.lifes < 0 {
							screen = .ENDING
							player.lifes = 5
							framesCounter = 0
						}
					} else {
						// Reset ball position
						ball.position.x = player.position.x + player.size.x / 2

						// LESSON 03: Inputs management (keyboard, mouse)
						if rl.IsKeyPressed(.SPACE) {
							// Activate ball logic
							ball.active = true
							ball.speed = {0, -5.0}
						}
					}
				}

			}
		case .ENDING:
			{
				// Update END screen data here!

				framesCounter += 1

				// LESSON 03: Inputs management (keyboard, mouse)
				if rl.IsKeyPressed(.ENTER) {
					// Replay / Exit game logic
					screen = .TITLE
				}

			}
		}
		//----------------------------------------------------------------------------------

		// Draw
		//----------------------------------------------------------------------------------
		rl.BeginDrawing()

		rl.ClearBackground(rl.RAYWHITE)

		switch (screen) 
		{
		case .LOGO:
			{
				// Draw LOGO screen here!

				rl.DrawText("LOGO SCREEN", 20, 20, 40, rl.LIGHTGRAY)

			}
		case .TITLE:
			{
				// Draw TITLE screen here!

				rl.DrawText("TITLE SCREEN", 20, 20, 40, rl.DARKGREEN)

				if (framesCounter / 30) % 2 == 0 do rl.DrawText("PRESS [ENTER] to START", rl.GetScreenWidth() / 2 - rl.MeasureText("PRESS [ENTER] to START", 20) / 2, rl.GetScreenHeight() / 2 + 60, 20, rl.DARKGRAY)

			}
		case .GAMEPLAY:
			{
				// Draw GAMEPLAY screen here!

				// LESSON 02: Draw basic shapes (circle, rectangle)
				rl.DrawRectangle(
					i32(player.position.x),
					i32(player.position.y),
					i32(player.size.x),
					i32(player.size.y),
					rl.BLACK,
				) // Draw player bar
				rl.DrawCircleV(ball.position, ball.radius, rl.MAROON) // Draw ball

				// Draw bricks
				for j := 0; j < BRICKS_LINES; j += 1 {
					for i := 0; i < BRICKS_PER_LINE; i += 1 {
						if bricks[j][i].active {
							if (i + j) % 2 ==
							   0 {rl.DrawRectangle(i32(bricks[j][i].position.x), i32(bricks[j][i].position.y), i32(bricks[j][i].size.x), i32(bricks[j][i].size.y), rl.GRAY)
							} else {rl.DrawRectangle(
									i32(bricks[j][i].position.x),
									i32(bricks[j][i].position.y),
									i32(bricks[j][i].size.x),
									i32(bricks[j][i].size.y),
									rl.DARKGRAY,
								)}
						}
					}
				}

				// Draw GUI: player lives
				for i := 0; i < player.lifes; i += 1 do rl.DrawRectangle(i32(20 + 40 * i), screenHeight - 30, 35, 10, rl.LIGHTGRAY)

				// Draw pause message when required
				if gamePaused do rl.DrawText("GAME PAUSED", screenWidth / 2 - rl.MeasureText("GAME PAUSED", 40) / 2, screenHeight / 2 + 60, 40, rl.GRAY)

			}
		case .ENDING:
			{
				// Draw END screen here!

				rl.DrawText("ENDING SCREEN", 20, 20, 40, rl.DARKBLUE)

				if (framesCounter / 30) % 2 == 0 do rl.DrawText("PRESS [ENTER] TO PLAY AGAIN", rl.GetScreenWidth() / 2 - rl.MeasureText("PRESS [ENTER] TO PLAY AGAIN", 20) / 2, rl.GetScreenHeight() / 2 + 80, 20, rl.GRAY)

			}
		}

		rl.EndDrawing()
		//----------------------------------------------------------------------------------
	}

	// De-Initialization
	//--------------------------------------------------------------------------------------

	// NOTE: Unload any loaded resources (texture, fonts, audio)

	rl.CloseWindow() // Close window and OpenGL context
	//--------------------------------------------------------------------------------------
}
