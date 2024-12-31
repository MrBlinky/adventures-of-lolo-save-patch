;-------------------------------------------------------------------------------
;Adventures of Lolo save patch (Gameboy)       by Mr.Blinky Dec.2024

;assemble using RGBASM and with Adventures of Lolo (U) (S) as rom overlay

;- fixes soft reset patch (START+SELECT+B+A buttons)
;- saves and loads unlocked password from (battery backed up) saveram

DEF PASSWORD        EQU $C5ED
DEF PASSWORD_INPUT  EQU $C5E7
DEF PASSWORD_LEN    EQU 6
DEF PASSWORD_CURSOR EQU $C499

DEF rRAMG           EQU $0000
DEF rRAMB           EQU $4000
DEF _SRAM           EQU $A000

    SECTION "header cart type",ROM0[$0147]

    db   $03    ;MBC1 + RAM + BATTERY

    SECTION "header ramsize",ROM0[$0149]

    db   $01    ;2K ramsize

    SECTION "header checksums",ROM0[$014D]

    db   $00    ;header checksum
    dw   $0000  ;global checksum

;---------------------------------------
    SECTION "soft reset fix",ROM0[$0705]

    jr   z,$0710

;---------------------------------------
    SECTION "save patch",ROMX[$7B6B],BANK[$09]

    call save_patch

    ld   hl,$C000   ;original code shifted up by 3 bytes
    ld   de,$7FA1   ;object source data
    ld   c,$02      ;2 objects
    call $06AD      ;copy object data
    ld   l,$08      ;optimized ld hl, $c008 to compensate for path call
    ld   e,$AD      ;optimized ld de, $7FAD to compensate for path call
    ld   c,$02      ;2 objects
    call $06AD      ;copy object data
    ld   l,$10      ;optimized ld hl,$C010 to compensate for path call

;---------------------------------------
    SECTION "load patch",ROMX[$4832],BANK[$02]

    ld   a,$11
    call $1582
    ld   hl, $C58F
    xor  a          ;0
    ldi  [hl],a
    ldi  [hl],a
    ldi  [hl],a
    ldi  [hl],a
    ldi  [hl],a
    inc  a          ;1
    ldi  [hl],a
    xor  a          ;0
    ld   [hl],a
    ld  [PASSWORD_CURSOR],a
    call load_patch             ;returns with A = 0
    jr   nc,no_password_loaded

password_loaded:
    ld   a,5
    ld   [PASSWORD_CURSOR],a
    jp  $4977                   ;update selected char cursor

no_password_loaded:
    ld  hl,PASSWORD_INPUT

;---------------------------------------
    SECTION "loadsave patch",ROM0[$0061]
;---------------------------------------

load_patch:

    call save_init
.check
    ld   a,[de]         ;check game title in save
    cp   [hl]
    inc  de
    inc  hl
    jr   nz,sram_disable
    add  c              ;update checksum
    ld   c,a
    dec  b
    jr   nz,.check

    ld   d,h            ;save pointer to save data in DE
    ld   e,l
    ld   b,PASSWORD_LEN
.checkcum:
    ldi  a,[hl]         ;get checksum over save data
    add  c
    ld   c,a
    dec  b
    jr   nz,.checkcum
    cp   [hl]           ;compare checksums
    jr   nz,sram_disable

    ;checksum ok, load password from save data

    ld   hl,PASSWORD_INPUT
    push hl
    call copy_password
    call sram_disable
    pop  hl

    ;set first 5 password chars object tiles

    ld   bc,$C6DE       ;password chars return position table
    ld   de,$C002       ;1st password char object tile in OAM ram buffer
.set_obj_tile_loop
    push de

    ;set password char object return Y,X

    push bc
    call get_password_char_position
    pop  bc
    ld   a,$30
    add  d
    ld   [bc],a         ;password char obj return Y
    inc  c
    ld   a,$20
    add  e
    ld   [bc],a         ;password char obj return X
    inc  c
    pop  de

    ;set password  char object tile

    ldi   a,[hl]        ;get password char
    add  a,LOW($4B08)
    push bc
    ld   c,a
    ld   b,HIGH($4B08)  ;just use MSB as no carry adjust is needed
    ld   a,[bc]         ;get password char tile
    pop  bc
    add  a,a
    ld   [de],a         ;sewt password char object tile
    inc  e              ;point to next object
    inc  e
    inc  e
    inc  e
    ld   a,e
    cp   5*4+2          ;loop do 5 objects
    jr   nz,.set_obj_tile_loop
    ;fallthrough

    ;move character select cursor to last password char

get_password_char_position:

    ld   a,[hl]         ;get password char
    and  7              ;keep column
    ld   c,a            ;column
    ld   e,a
    swap e              ;cursor object x adjust = column * 16
    xor  [hl]           ;get row by xoring of column
    add  a,a            ;row / 8 * 16
    ld   d,a            ;cursor object y adjust = row * 16
    ld   b,a
    swap b              ;row
    scf                 ;C to signal password loaded
    ret

;--------------------------------------
save_patch:
    call save_init
    call copy_b_bytes
    ld   de,PASSWORD
    call copy_password
    ld   [hl],c         ;store checksum
sram_disable:
    xor  a              ;disable ram, NC for no password loaded
    ld   [rRAMG],a
    ret

;--------------------------------------
save_init:
    ld   a,$0A          ;enable SRAM
    ld   [rRAMG],a
    ld   hl,_SRAM       ;start of save ram
    ld   de,$0134       ;game title in header
    ld   b,15           ;game title length
    ld   c,l            ;clear checksum
    ret

;--------------------------------------
copy_password:
    ld   b,PASSWORD_LEN
    ;fallthrough

copy_b_bytes:
    ld   a,[de]
    inc  de
    ldi  [hl],a
    add  a,c
    ld   c,a
    dec  b
    jr   nz,copy_b_bytes
    ret

;--------------------------------------



