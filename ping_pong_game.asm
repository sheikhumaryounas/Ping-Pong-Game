[org 0x0100]  
cmp word[width_shield], 1
jne skip_check
	cmp word[width_of_field], 15
	jge sc1
	mov ax, 0x4c00
	int 0x21
	sc1:
	cmp word[width_of_field], 38
	jle skip_check
	mov ax, 0x4c00
	int 0x21
skip_check:
call clr_scr
mov ax, 0xB800
mov es, ax
mov di, 160
mov ax, 0x0720
mov si, PT1
ply1:
	lodsb
	stosw
	cmp al, 0
	jnz ply1
push di
mov ax, P1
push ax
call string_input
mov ax, 0x0720
mov di, 320
mov si, PT2
ply2:
	lodsb
	stosw
	cmp al, 0
	jnz ply2
push di
mov ax, P2
push ax
call string_input
mov ax, [width_of_field]
shl ax, 1
mov [width_of_field], ax
mov word[BallPos], 2000
mov word[NextPos], 2000
mov word[ball_movement ], -158
mov word[initial_gamepos], 0xFFFF
mov word[ply2pos], 558
mov ax, [width_of_field]
sub word[ply2pos], ax
mov word[ply1pos], 560
add word[ply1pos], ax
mov word[P1score], 0
mov word[P2score], 0
lewp:
	mov ax, 0x0100
	int 0x16
	jz updateBall
	jmp checkInputs
	updateBall:
	cmp word[initial_gamepos], 0
	jnz cont
	mov ax, 0
	int 0x16
	cmp ah, 0x39
	jnz lewp
	call changeinitial_gamepos
	cont:
	call slow_down
	call print_scr
	push ax
	push bx
	push dx
	startIteration:
		mov ax, [ball_movement]
		add [NextPos], ax
		mov ax, [ball_movement]
	checkSides:
		mov ax, 0xB800
		mov es, ax
		mov di, [NextPos]
		cmp word[es:di], 0x0020
		jnz checkWalls
		cmp word[ball_movement], -158
		jnz sk1
		call increment_p1
		sk1:
		cmp word[ball_movement], 162
		jnz sk2
		call increment_p1
		sk2:
		cmp word[ball_movement], 158
		jnz sk3
		call increment_p2
		sk3:
		cmp word[ball_movement], -162
		jnz sk4
		call increment_p2
		sk4:
		mov word[BallPos], 2000
		mov word[NextPos], 2000
		mov ax, [ball_movement]
		not ax
		add ax, 1
		mov word[ball_movement], ax
	checkWalls:
		cmp word[NextPos], 318 
		jge checkLowWall
		jmp up_wall
	checkLowWall:
		cmp word[NextPos], 3680
		jle checkPlayers
		jmp low_wall
	checkPlayers:
		mov ax, 0xB800
		mov es, ax
		mov di, [NextPos]
		cmp word[es:di], 0x0CDB
		jnz R1
		call right_wall
		jmp nextIteration
	R1:
		cmp word[es:di+2], 0x0CDB
		jnz checkLeftPlr
		call right_wall
		jmp nextIteration
	checkLeftPlr:
		mov ax, 0xB800
		mov es, ax
		mov di, [NextPos]
		cmp word[es:di], 0x02DB
		jnz L1
		call left_wall
		jmp nextIteration
	L1:
		cmp word[es:di-2], 0x02DB
		jnz nextIteration
		call left_wall
	nextIteration:
		mov ax, [ball_movement]
		add word[BallPos], ax
		mov ax, [BallPos]
		mov [NextPos], ax
		pop dx
		pop bx
		pop ax
		mov ax, [win_score]
		cmp ax, [P1score]
		je end
		cmp ax, [P2score]
		je end
		jmp lewp
	checkInputs:
	mov ax, 0
	int 0x16
	cmp ah, 0
	jz endIteration
	cmp ah, 0x48
	jne i0
	call P1up
	i0:
	cmp ah, 0x50
	jne i1
	call P1down
	i1:
	cmp ah, 0x11
	jne i2
	call P2up
	i2:
	cmp ah, 0x1F
	jne i3
	call P2down
	i3:
	cmp ah, 0x39
	jne i4
	call changeinitial_gamepos
	i4:
	cmp ah, 0x01
	je end
	endIteration:
	call print_scr
	jmp lewp
end:
mov ax, 0xB800
mov es, ax
mov di, 2140
mov ax, 0x0700
mov bx, [P1score]
mov dx, [P2score]
cmp dx, bx
je w1
	cmp bx, dx
	jl w2
	mov si, P1
	jmp w3
	w2:
	mov si, P2
	w3:
	lodsb
	stosw
	cmp al, 0
	jnz w3
	mov si, WinText
	w4:
	lodsb
	stosw
	cmp al, 0
	jnz w4
	jmp stop
w1:
	mov di, 2140
	mov si, game_tie
	w5:
	lodsb
	stosw
	cmp al, 0
	jnz w5
stop:
mov ax, 0x4c00
int 0x21

increment_p1:
	inc word[P1score]
	ret

increment_p2:
	inc word[P2score]
	ret

P1up:
	cmp word[ply1pos], 640
	jle p1u
	sub word[ply1pos], 160
	p1u:
	ret

P1down:
	cmp word[ply1pos], 3360
	jge p1d
	add word[ply1pos], 160
	p1d:
	ret

P2up:
	cmp word[ply2pos], 640
	jle p2u
	sub word[ply2pos], 160
	p2u:
	ret

P2down:
	cmp word[ply2pos], 3360
	jge p2d
	add word[ply2pos], 160
	p2d:
	ret

up_wall:
	add word[ball_movement], 320
	jmp nextIteration

low_wall:
	add word[ball_movement], -320
	jmp nextIteration

right_wall:
	add word[ball_movement], -4
	ret

left_wall:
	add word[ball_movement], 4
	ret

changeinitial_gamepos:
	not word[initial_gamepos]
	ret

clr_scr:
	push ax
	push cx
	push es
	push di
	mov ax, 0xB800
	mov es, ax
	mov di, 0
	mov cx, 2000
	mov ax, 0x0720
	cld
	rep stosw
	pop di
	pop es
	pop cx
	pop ax
	ret

slow_down:
	push ax
	push cx
	mov ax, 0x8600
	mov cx, [slow_ball]
	int 0x15
	pop cx
	pop ax
	ret

print_scr:
	call clr_scr
	push ax
	push bx
	push cx
	push dx
	push es
	push di
	push si
	mov ax, 0xB800
	mov es, ax
	mov di, 238
	sub di, [width_of_field]
	mov ax, 242
	add ax, [width_of_field]
top_bottom_walls:
	mov word[es:di], 0x01CD
	add di, 3520
	mov word[es:di], 0x01CD
	sub di, 3520
	add di, 2
	cmp di, ax
	jnz top_bottom_walls
	mov word[es:80],0x01BA
	mov word[es:240],0x01CA
	mov di, 398
	sub di, [width_of_field]
	mov ax, [width_of_field]
	shl ax, 1
	add ax, 2
Leftright_walls:
	mov word[es:di], 0x0020
	add di, ax
	mov word[es:di], 0x0020
	sub di, ax
	add di, 160
	cmp di, 3600
	jl Leftright_walls
	mov di, [BallPos]
	mov ax, [Ball]
	mov word[es:di], ax
	mov di, 646
	mov ax, 0x0720
	mov di, [ply1pos]
	mov word[es:di], 0x0CDB
	mov word[es:di+160], 0x0CDB
	mov word[es:di-160], 0x0CDB
	mov di, [ply2pos]
	mov word[es:di], 0x02DB
	mov word[es:di+160], 0x02DB
	mov word[es:di-160], 0x02DB
	mov di, 3852
	mov si, msg
	cld
	mov ax, 0x0700

	pr1:
		lodsb
		stosw
		cmp al, 0
		jnz pr1
		mov di, 0
		mov si, P1
	pr2:
		lodsb
		stosw
		cmp al, 0
		jnz pr2
		mov si, P2
	pr3:
		lodsb
		cmp al, 0
		jnz pr3
		sub si, P2
		shl si, 1
		mov di, 158
		sub di, si
		mov si, P2
	pr4:
		lodsb
		stosw
		cmp al, 0
		jnz pr4
		mov ax, [P1score]
		mov bx, 10
		mov di, 78
	pr5:
		mov dx, 0
		div bx
		add dx, 0x0030
		mov dh, 0x07
		mov word[es:di], dx
		sub di, 2
		cmp ax, 0
		jnz pr5
		mov ax, [P2score]
		mov di, 88
	pr6:
		mov dx, 0
		div bx
		add dx, 0x0030
		mov dh, 0x07
		mov word[es:di], dx
		sub di, 2
		cmp ax, 0
		jnz pr6
		pop si
		pop di
		pop es
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	string_input:
		push bp
		mov bp, sp
		push ax
		push bx
		push es
		push di
		push si
		mov ax, 0xB800
		mov es, ax
		mov si, [bp+4]
		mov di, [bp+6]
		mov bx, 0
	input:
		mov ax, 0
		int 0x16
		cmp ax, 0x1C0D
		jz input_end
		cmp ax, 0x0E08
		jnz si1
			cmp bx, 0
			jz si2
			dec bx
			sub di, 2
			mov byte[si+bx], 0x20
			mov word[es:di], 0x0720
			jmp si2
		si1:
		mov byte[si+bx], al
		mov ah, 0x07
		mov word[es:di], ax
		add di, 2
		inc bx
		si2:
		cmp bx, 15
		jnz input
	input_end:
		mov byte[si+bx], 0
		pop si
		pop di
		pop es
		pop bx
		pop ax
		pop bp
		ret 2

initial_gamepos: dw 0
BallPos: dw 0
NextPos: dw 0
ball_movement : dw 0
ply1pos: dw 06
ply2pos: dw 0
P1score: dw 0
P2score: dw 0
WinText: db 'won the game', 0
game_tie: db 'The match has been tied', 0
msg: db 'Haisam Lodhi & Umar Younas', 0
P1: db '               ', 0
P2: db '               ', 0
PT1: db 'Enter the name of player1:', 0
PT2: db 'Enter the name of player2:', 0

slow_ball: dw 2
width_of_field: dw 38
width_shield: dw 1
Ball: dw 0x0601
win_score: dw 3