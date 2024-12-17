# 487 Project: Pong
Authors: William Chimbay and Chris Mancheno

References: Building off the source code from Lab 6 per Professor Yett - https://github.com/byett/dsd/tree/CPE487-Fall2024/Nexys-A7/Lab-6
Modules modified: pong.vhd, bat_n_ball.vhd, pong.xdc

## What to expect?
The Pong game is a two-player competitive arcade game designed to run on the Nexys FPGA board. Each player controls a paddle that can move vertically along their side of the screen using dedicated buttons on the board. The game begins when the ball is served from the center of the screen, moving diagonally toward one of the paddles. Players must bounce the ball back toward their opponent by intercepting it with their paddle. The ball bounces off walls and paddles, with its speed increasing slightly after every successful paddle hit. If the ball passes a paddle, the opposing player earns a point, and the ball resets to the center. The scores for both players are displayed on the VGA screen in real-time. Players can reset the game, including scores and ball position, by pressing the reset button.

## How to set up and run our program?
Make sure to have a VGA Connector Cable and a VGA compatible monitor to run the Brick Breaker game. 

1) Download the source files in this git repo.
2) Create a new project and upload the source files when prompted; upload the constraint file when prompted.
3) Click Generate Bitstream and yes until you get to the "bitstream successfully generated" screen.
4) Connect your board to your laptop and open Hardware -> open target -> auto connect (make sure your board is on) -> program device. 
5) Connect your VGA Cable to the Nexus board and a compatible monitor. 

## Inputs and Outputs
- BTNL/BTNU: Player 1 paddle up and down.
- BTNR/BTND: Player 2 paddle up and down.
- BTCU button will reset the game.
- Full usage of the 7 Segment display to display scores.
- VGA functionality to connect to a monitor.
![Block Diagram](https://github.com/cmanche/487Project/blob/main/pong.png)

Above is a block diagram showing basic interactions between our modules and the inputs from the players.

## Images
![PONG](https://github.com/cmanche/487Project/blob/main/20241216_164622403_iOS.jpg)
Our pong instance! You can see we kept it simple and made an RGB color format. The paddles are red and blue, background is green with a white stripe, and the pong bal would be black in color. 

## Division of Labor
Chris:
- Developed the logic for the second paddle and integrated wall physics for horizontal gameplay.
- Implemented axis rotation to transition gameplay from vertical to horizontal.
- Balanced paddle speeds for smoother and more competitive gameplay.
- Implemented switch-based speeds for dynamic gameplay customization.

Will:
- Mapped button functionality for two players on a single board.
- Designed and implemented the points system for real-time scoring.
- Added color changes to differentiate paddles, ball, and background.
- Implemented randomess from bat impacts and serve as opposed to continuous tragectory.

## Overview of Changes Made in pong.vhd and bat_n_ball.vhd
### Key Modifications in **pong.vhd**

### Two-Paddle Gameplay Logic:
- Added support for two players with separate controls:
- Player 1: btnl (up) and btnd (down).
- Player 2: btnu (up) and btnr (down).
- Replaced single paddle position (batpos) with separate signals for each paddle (bat1pos for Player 1 and bat2pos for Player 2).

### Score System:
- Introduced two separate score registers (score1 and score2) to track points for each player.
- Updated the seven-segment display logic to display both players' scores.
- Integration of Modified bat_n_ball:

### Replaced the original bat_x signal with bat1_y and bat2_y for the two paddles.
- Passed scores (score1 and score2) to and from the bat_n_ball component.
  
### Enhanced Paddle Movement:
- Adjusted movement boundaries for vertical gameplay (paddles restricted between bat_h and 600 - bat_h).
- Synchronized paddle movement with clock signal to ensure smooth gameplay.

### Updated Visual Rendering:
- Instantiated bat_n_ball with signals for two paddles and ball trajectory.
- Adjusted color assignments for better visual clarity:
- Red: Represents active paddles and the ball.

### Key Modifications in bat_n_ball.vhd
  
### Two-Paddle Logic:
- Replaced the single bat_x signal with fixed paddle positions:
- bat1_x (left paddle) and bat2_x (right paddle).
- Added signals for the vertical positions of both paddles (bat1_y and bat2_y).

### Ball Collision Detection:
- Added separate collision detection for each paddle:
- Left paddle (bat1): Reflects the ball when it reaches the left boundary.
- Right paddle (bat2): Reflects the ball when it reaches the right boundary.
- Ensured proper ball reflection based on paddle position and size.
  
### Score Tracking:
- Introduced registers for Player 1 (score1_reg) and Player 2 (score2_reg) scores.
- Meant for change to be displayed with player1 populating left four LED's, but ran into complications
  
### Updated scores when the ball passes either paddle:
- Left paddle miss: Increment Player 2's score.
- Right paddle miss: Increment Player 1's score.

### Improved Ball Physics:
- Ball movement now accounts for top and bottom wall collisions.
- Trajectory of the ball dynamically adjusted after paddle collisions.
  - Randomness with paddle impact controlled by switch 14 (3rd from leftmost)
- Randomized initial serve direction upon game start.
- Ball speed controlled by switches 1, 2, and 3 (assuming counting from right to left)
  - Switch 1: Normal speed
  - Switch 2: Faster speed
  - Switch 3: Fastest speed

### Visual Adjustments:
- Rendered both paddles and the ball using separate signals (bat1_on, bat2_on, ball_on).
- Enhanced visuals with distinct colors for paddles, ball, and background.
  - Switch 16: Flip ball and court colors
  - Switch 15: Flip paddle colors

Thank you
