# 487Project: Brick Breaker
Authors: William Chimbay and Chris Mancheno

References: Building off the source code from Lab 6 - https://github.com/byett/dsd/tree/CPE487-Fall2024/Nexys-A7/Lab-6


## What to expect?
Our brick breaker game is simple. 5 rows of bricks are in a line and, just like with the visuals in lab 6, the bat and the ball bounce. When pressing the BTNC button on the board the game should start by spawning a blue ball that bounces off the bricks, sides of the screen, and bat.  When a ball hits a brick, the brick should disappear and the ball should bounce off in an exit angle equal to the angle of entry. This is true for the bat and the wall logic. The colors of the game will have green bricks, a blue ball, and a yellow bat. After all the bricks are broken, you can reset the game to its initial state by pressing the BTNC button once again. The 5 switches on the right are programmed to increase the ball speed by 1 for each switch. This is intended to give the player a customizable difficulty gameplay mechanic. 

## How to set up and run our program?
Make sure to have a VGA Connector Cable and a VGA compatible monitor to run the Brick Breaker game. 

1) Download the source files in this git repo.
2) Create a new project and upload the source files when prompted; upload the constraint file when prompted.
3) Click Generate Bitstream and yes until you get to the "bitstream successfully generated" screen.
4) Connect your board to your laptop and open Hardware -> open target -> auto connect (make sure your board is on) -> program device. 
5) Connect your VGA Cable to the Nexus board and a compatible monitor. 

## Inputs and Outputs
- BTCU button will reset the game.
- BTNL will move the bat to the left and BTNR will move the bat to the right.

## _Submission (80% of your project grade):_
- _Your final submission should be a github repository of very similar format to the labs themselves with an opening README document with the expected components as follows:_
  - _A description of the expected behavior of the project, attachments needed (speaker module, VGA connector, etc.), related images/diagrams, etc. (10 points of the Submission category)_
    - _The more detailed the better – you all know how much I love a good finite state machine and Boolean logic, so those could be some good ideas if appropriate for your system. If          not, some kind of high level block diagram showing how different parts of your program connect together and/or showing how what you have created might fit into a more complete          system could be appropriate instead._
  - _A summary of the steps to get the project to work in Vivado and on the Nexys board (5 points of the Submission category)_
  - _Description of inputs from and outputs to the Nexys board from the Vivado project (10 points of the Submission category)_
    - _As part of this category, if using starter code of some kind (discussed below), you should add at least one input and at least one output appropriate to your project to           demonstrate your understanding of modifying the ports of your various architectures and components in VHDL as well as the separate .xdc constraints file._
  - _Images and/or videos of the project in action interspersed throughout to provide context (10 points of the Submission category)_
  - _“Modifications” (15 points of the Submission category)_
    - _If building on an existing lab or expansive starter code of some kind, describe your “modifications” – the changes made to that starter code to improve the code, create entirely new functionalities, etc. Unless you were starting from one of the labs, please share any starter code used as well, including crediting the creator(s) of any code used. It is perfectly ok to start with a lab or other code you find as a baseline, but you will be judged on your contributions on top of that pre-existing code!_
    - _If you truly created your code/project from scratch, summarize that process here in place of the above._
  - _Conclude with a summary of the process itself – who was responsible for what components (preferably also shown by each person contributing to the github repository!), the timeline of work completed, any difficulties encountered and how they were solved, etc. (10 points of the Submission category)_
- _And of course, the code itself separated into appropriate .vhd and .xdc files. (50 points of the Submission category; based on the code working, code complexity, quantity/quality of modifications, etc.)_
- _You are not really expected to be github experts – as long as one of you can confidently create the repository and help others add to it, that should be sufficient. If no group members fall under this criteria, discuss with me as soon as possible._
  - _This is a group assignment, and for the most part you are graded as a group. I reserve the right to modify single student grades for extenuating circumstances, such as a clear lack of participation from a group member. You are allowed to rely on the expertise of your group members in certain aspects of the project, but you should all have at least a cursory understanding of all aspects of your project._
