🏓 x86 Assembly Ping Pong Game
A classic 2-player Ping Pong (Pong) game built entirely in x86 Assembly Language (16-bit real mode), designed to run in DOSBox or any DOS-compatible environment. The game uses BIOS interrupts and direct video memory manipulation to render visuals in text mode and handle real-time user input.

🎮 Features
Two-player gameplay with paddle control

Real-time ball physics and collision handling

Player name input and dynamic score tracking

Game end conditions: win or tie

Simple UI rendered using ASCII characters

Adjustable field width and paddle settings

🛠️ Technical Details
Written in pure x86 assembly (NASM syntax)

Uses int 0x10, int 0x16, and int 0x21 for screen and input

Video output via direct access to segment 0xB800

No external libraries — fully handcrafted logic

Runs best in DOSBox

🚀 How to Run
Assemble with NASM:
nasm -f bin pong.asm -o pong.com

Open with DOSBox:
dosbox pong.com

👨‍💻 Authors
Umar Younas
