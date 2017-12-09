;
;   Author: Arjan
;
;   Description:
;   Wannabe GRUB-like menu
;
bits 16                             ; Configure NASM for Real Mode.
org 0x7C00                          ; Set program offset at 0x7C00.

boot:
    call clear_screen               ; Call the clear screen routine
    call show_menu                  ; Show the menu on the screen
    jmp loop                        ; Jump to the main loop

loop:
    call read_keys                  ; We shall read keys until we drop dead
    jmp loop                        ; Jump back to the loop so we're... looping

read_keys:
    mov ah, 0x0                     ; Get keystroke
    int 0x16                        ; Call the keyboard interrupt

    cmp al, 27                      ; Check if the pressed key is the escape
    je .escape                      ; If so we act accordingly
    cmp al, 0x0D                    ; Check if the pressed key is the enter
    je .enter                       ; If so we act accordingly
    cmp ah, 0x48                    ; Check if the pressed key is the up arrow
    je .up                          ; If so we act accordingly
    cmp ah, 0x50                    ; Check if the pressed key is the down arrow
    je .down                        ; If so we act accordingly

    ret                             ; Return to the previous routine

    .up:
        mov al, [MENU_INDEX]        ; Lets move the menu index into AL so we can actually work with it
        cmp al, 0                   ; Check to see if the index is zero because we don't want to go into negative indexes
        je .return                  ; If it's zero we return and do nothing
        dec al                      ; If it's more than zero we decrement the value
        mov [MENU_INDEX], al        ; Move the decremented value back in its original memory address
        call show_menu              ; Show the menu on the screen (update)
        ret                         ; Return  to the previous routine
    .down:
        mov al, [MENU_INDEX]        ; Lets move the menu index into AL so we can actually work with it
        cmp al, [MENU_INDEX_MAX]    ; Check to see if the index is the max index because we don't want to exceed the maximum
        je .return                  ; If it's zero we return and do nothing
        inc al                      ; If it's less than the maximum we increment the value
        mov [MENU_INDEX], al        ; Move the decremented value back in its original memory address
        call show_menu              ; Show the menu on the screen (update)
        ret                         ; Return to the previous routine
    .enter:
        mov al, [MENU_INDEX]        ; Lets move the menu index into AL so we can actually work with it
        cmp al, 0                   ; Check to see if the index is zero
        je .menu_item_1             ; If so we jump to the first menu item
        cmp al, 1                   ; Check to see if the index is one
        je .menu_item_2             ; If so we jump to the second menu item
        cmp al, 2                   ; Check to see if the index is two
        je .menu_item_3             ; If so we jump to the third menu item
        ret                         ; Return to the previous routine

        .menu_item_1:
            mov si, MENU_ITEM_1_TEXT; Move the 'follow-up' text of menu item 1 into the SI register
            call clear_screen       ; Clear the screen to prepare for text printing
            call print_string       ; Print the text to the screen
            ret                     ; Return to the previous routine
        .menu_item_2:
            mov si, MENU_ITEM_2_TEXT; Move the 'follow-up' text of menu item 2 into the SI register
            call clear_screen       ; Clear the screen to prepare for text printing
            call print_string       ; Print the text to the screen
            ret                     ; Return to the previous routine
        .menu_item_3:
            mov si, MENU_ITEM_3_TEXT; Move the 'follow-up' text of menu item 3 into the SI register
            call clear_screen       ; Clear the screen to prepare for text printing
            call print_string       ; Print the text to the screen
            ret                     ; Return to the previous routine

    .escape:
        call reset_menu             ; Reset the menu
        ret                         ; Return to the previous routine

    .return:
        ret                         ; Return to the previous routine

reset_menu:
    call clear_screen               ; Start by clearing the screen
    mov al, [MENU_INDEX]            ; Lets move the menu index into AL so we can actually work with it
    mov al, 0                       ; Lets reset the menu index to zero
    mov [MENU_INDEX], al            ; Move the decremented value back in its original memory address
    call show_menu                  ; Show the menu on the screen
    ret                             ; Return to the previous routine

show_menu:
    call clear_screen               ; Call the clear screen routine

    mov ah, 0x6                     ; Scroll up function
    mov al, 0x0                     ; Clear entire screen
    mov ch, [MENU_INDEX]            ; Set the start row to the current menu item's index
    mov cl, 0x0                     ; Set the start column to zero
    mov dh, [MENU_INDEX]            ; Set the end row to the current menu item's index
    ;mov dl, 0x184f                  ; Set the end column to the end of the screen TODO: Bedoel je hier niet dx ?
    mov dx, 0x184f                  ; Set the end column to the end of the screen
    mov bh, 0xf0                    ; Set white on black
    int 0x10                        ; Call video interrupt

    mov ax, 0x100                   ; Hide the cursor
    mov cx, 0x2000                  ; Hide the cursor
    int 0x10                        ; Call video interrupt

    mov si, MENU_ITEM_1             ; Move the menu item text into the si register
    call print_string               ; Print the text onto the screen
    mov si, MENU_ITEM_2             ; Move the menu item text into the si register
    call print_string               ; Print the text onto the screen
    mov si, MENU_ITEM_3             ; Move the menu item text into the si register
    call print_string               ; Print the text onto the screen

    ret                             ; Return to the previous routine

clear_screen:
    mov ah, 0x6                     ; Scroll up function
    mov al, 0x0                     ; Clear entire screen
    mov cx, 0x0                     ; Upper left corner CH=row, CL=column
    mov dx, 0x184f                  ; lower right corner DH=row, DL=column
    mov bh, 0x0f                    ; Set white on black
    int 0x10                        ; Call video interrupt

    mov ah, 0x2                     ; Set cursor function
    mov bh, 0x0                     ; Page number is zero
    mov dh, 0x0                     ; Top row (00h is top, 18h is bottom)
    mov dl, 0x0                     ; Left column (00h is left)
    int 0x10                        ; Call video interrupt

    ret                             ; Return to the previous routine

print_string:                       ; Routine to print a string
    lodsb                           ; Read a byte from si into al
    cmp al, 0                       ; Check if the byte equals zero
    jz .return                      ; If the byte equals zero we return
    mov ah, 0x0e                    ; Set video mode to teletext
    int 0x10                        ; Call the video service interrupt
    jmp print_string                ; Continue with the next byte

    .return:
        ret                         ; Return to the previous routine

                                    ; Menu items
MENU_ITEM_1 db "Ubuntu, with Linux 2.6.32-22-generic",0x0d,0x0a,0
MENU_ITEM_2 db "Windows 10",0x0d,0x0a,0
MENU_ITEM_3 db "Memory test",0x0d,0x0a,0

MENU_ITEM_1_TEXT db "Booting Ubuntu...",0x0d,0x0a,0
MENU_ITEM_2_TEXT db "Booting Windows...",0x0d,0x0a,0
MENU_ITEM_3_TEXT db "Running memory tests...",0x0d,0x0a,0

MENU_INDEX db 0
MENU_INDEX_MAX db 2

times 510-($-$$) db 0               ; fill the rest of the sector with the amount of money on my bank account.
dw 0xAA55                           ; Mark this sector (the 512 bytes used in the bootloader) as bootable with black magic.