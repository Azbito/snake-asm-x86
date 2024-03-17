org 0x7c00

video = 0x10
set_cursor_pos = 0x02
write_char = 0x0a

system_services = 0x15
wait_service = 0x86

keyboard_int = 0x16 ; keyboard interrupt
keyboard_read = 0x00 ; reads what had been read
keystroke_status = 0x01 ; verify if there's any key pressed. ZF = 1 No code available. ZF = 0 code available

timer_int = 0x1a ; system-timer and real-time clock services
read_time_counter = 0x00 ; read system-timer time counter

left_arrow = 0x4b
right_arrow = 0x4d
down_arrow = 0x50
up_arrow = 0x48

call handle_food

start:

mov ah, wait_service
mov cx, 1 ; time before return to caller, in microseconds. Requires (cx, dx)
mov dx, 0
int system_services

call handle_keyboard

mov ah, write_char ; use ah = 09h for graphics modes
mov bh, 0 ; (ah) = 0bh - set color palette
mov cx, 1 ; count of characters to write
mov al, ' ' ; represents the sssssssnake
int video

; changes food position
mov al, [food_pos]
cmp [pos_row], al
jne regular_flow
cmp [pos_col], al
jne regular_flow
call handle_food

regular_flow:
; this part of the code is for VK_KEY
mov ah, set_cursor_pos
mov dh, [pos_row]
mov dl, [pos_col]
mov bh, 0
int video

; this logic below is to not create so many * in terminal
mov ah, write_char
mov bh, 0
mov cx, 1
mov al, '*'
int video

cmp byte [scan_code], left_arrow
jne check_right_arrow
dec byte [pos_col]

jmp start

check_right_arrow:
cmp byte [scan_code], right_arrow
jne check_up_arrow
inc byte [pos_col]

jmp start

check_up_arrow:
cmp byte [scan_code], up_arrow
jne check_down_arrow
dec byte [pos_row]

jmp start

check_down_arrow:
cmp byte [scan_code], down_arrow
jne failure
inc byte [pos_row]

jmp start

; VK_KEY ends

failure:
jmp $ ; its fine to make a loop like so, since it's not for production, only educational stuffs


handle_keyboard:
mov ah, keystroke_status
int keyboard_int
jz end_of_handle_keyboard

mov ah, keyboard_read
int keyboard_int
; ah - scan code
mov [scan_code], ah

end_of_handle_keyboard:
ret

handle_food:
mov ah, read_time_counter
int timer_int
mov al, 7 ; 111 binary number
and al, dl
mov byte [food_pos], al
add byte [food_pos], 7

mov ah, set_cursor_pos
mov dh, [food_pos]
mov dl, [food_pos]
mov bh, 0
int video

mov ah, write_char ; use ah = 09h for graphics modes
mov bh, 0 ; (ah) = 0bh - set color palette
mov cx, 1 ; count of characters to write
mov al, '&' ; represents the food :3
int video

mov ah, set_cursor_pos
mov dh, 0
mov dl, 0
mov bh, 0
int video
ret

pos_row:
db 10
pos_col:
db 5
scan_code:
db left_arrow
food_pos:
db 15

times 510 - ($ - $$) db 0
dw 0xAA55
