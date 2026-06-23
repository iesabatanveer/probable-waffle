.MODEL SMALL
.STACK 100H

.DATA
    MAX_ROOMS EQU 10
    room_status DB MAX_ROOMS DUP(0)      ; 0=vacant, 1=occupied
    room_types DB MAX_ROOMS DUP(0)       ; 1=Standard, 2=Deluxe, 3=Suite
    room_prices DW 5000, 8000, 12000
    payment_status DB MAX_ROOMS DUP(0)   ; 0=Unpaid, 1=Paid, 2=Pending
    
    customer_names DB 200 DUP(0)
    customer_cnic DB 140 DUP(0)
    customer_phone DB 120 DUP(0)
    stay_duration DB MAX_ROOMS DUP(0)
    payment_method DB MAX_ROOMS DUP(0)   ; Only 1=Cash now
    
    banner DB 13,10,'========================================',13,10
           DB '    HOTEL MANAGEMENT SYSTEM',13,10
           DB '========================================',13,10,'$'
    
    main_portal DB 13,10,'SELECT PORTAL:',13,10
                DB '1. Admin Portal',13,10
                DB '2. Customer Portal',13,10
                DB '3. Exit',13,10
                DB 'Enter choice: $'
    
    admin_menu DB 13,10,'ADMIN PORTAL:',13,10
               DB '1. View All Customer Records',13,10
               DB '2. View Room Status',13,10
               DB '3. View Payment Status',13,10
               DB '4. Update Payment Status',13,10  ; NEW OPTION
               DB '5. Back to Main Menu',13,10
               DB 'Enter choice: $'
    
    customer_menu DB 13,10,'CUSTOMER PORTAL:',13,10
                  DB '1. View Room Availability',13,10
                  DB '2. Room Booking (Check-in)',13,10
                  DB '3. Check-out',13,10
                  DB '4. Make Payment (Cash Only)',13,10  ; UPDATED
                  DB '5. Back to Main Menu',13,10
                  DB 'Enter choice: $'
    
    prompt_room DB 13,10,'Enter room number (1-10): $'
    prompt_name DB 13,10,'Enter customer name: $'
    prompt_cnic DB 13,10,'Enter CNIC (13 digits, must start with 1234): $'
    prompt_phone DB 13,10,'Enter phone (11 digits): $'
    prompt_days DB 13,10,'Enter stay duration (days): $'
    prompt_room_type DB 13,10,'Select Room Type:',13,10
                     DB '1. Standard (Rs.5000/day)',13,10
                     DB '2. Deluxe (Rs.8000/day)',13,10
                     DB '3. Suite (Rs.12000/day)',13,10
                     DB 'Choice: $'
    prompt_payment_amt DB 13,10,'Enter payment amount (Cash only): Rs.$'
    
    msg_occupied DB 13,10,'Room already occupied!$'
    msg_vacant DB 13,10,'Room is vacant!$'
    msg_success DB 13,10,'Operation successful!$'
    msg_invalid DB 13,10,'Invalid input! Please try again.$'
    msg_cnic_error DB 13,10,'Error: CNIC must be 13 digits starting with 1234!$'
    msg_phone_error DB 13,10,'Error: Phone must be exactly 11 digits!$'
    msg_payment_error DB 13,10,'Error: Payment amount must equal room price!$'
    msg_payment_excess DB 13,10,'Error: Amount exceeds room price! Booking denied.$'
    msg_payment_required DB 13,10,'Error: Payment not completed! Please make payment before checkout.$'
    msg_room_status DB 13,10,'Room Status:',13,10,'$'
    msg_payment_stat DB 13,10,'Payment Status Report:',13,10,'$'
    msg_bill DB 13,10,'===== BILL SUMMARY =====',13,10,'$'
    msg_thanks DB 13,10,'Thank you! Visit again.$'
    msg_paid DB ' - PAID$'
    msg_unpaid DB ' - UNPAID$'
    msg_pending DB ' - PENDING$'
    
    type_standard DB 'Standard$'
    type_deluxe DB 'Deluxe$'
    type_suite DB 'Suite$'
    
    temp_room DB 0
    temp_buffer DB 20 DUP(0)
    newline DB 13,10,'$'
    
    ; NEW MESSAGES
    prompt_update_payment DB 13,10,'Update Payment Status for Room $'
    prompt_update_choice DB 13,10,'Set payment status to:',13,10
                         DB '1. Paid',13,10
                         DB '2. Unpaid',13,10
                         DB '3. Pending',13,10
                         DB 'Enter choice: $'
    msg_update_success DB 13,10,'Payment status updated successfully!$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Initialize room types
    MOV room_types[0], 1
    MOV room_types[1], 1
    MOV room_types[2], 2
    MOV room_types[3], 2
    MOV room_types[4], 2
    MOV room_types[5], 3
    MOV room_types[6], 3
    MOV room_types[7], 1
    MOV room_types[8], 2
    MOV room_types[9], 3
    
MAIN_LOOP:
    CALL CLEAR_SCREEN
    LEA DX, banner
    CALL PRINT_STRING
    LEA DX, main_portal
    CALL PRINT_STRING
    CALL GET_CHAR
    
    CMP AL, '1'
    JE DO_ADMIN
    CMP AL, '2'
    JE DO_CUSTOMER
    CMP AL, '3'
    JE EXIT_PROG
    
    LEA DX, msg_invalid
    CALL PRINT_STRING
    CALL PAUSE
    JMP MAIN_LOOP

DO_ADMIN:
    CALL ADMIN_PORTAL
    JMP MAIN_LOOP
DO_CUSTOMER:
    CALL CUSTOMER_PORTAL
    JMP MAIN_LOOP
EXIT_PROG:
    MOV AH, 4CH
    INT 21H
MAIN ENDP

ADMIN_PORTAL PROC
ADMIN_LOOP:
    CALL CLEAR_SCREEN
    LEA DX, banner
    CALL PRINT_STRING
    LEA DX, admin_menu
    CALL PRINT_STRING
    CALL GET_CHAR
    
    CMP AL, '1'
    JE AD_RECORDS
    CMP AL, '2'
    JE AD_STATUS
    CMP AL, '3'
    JE AD_PAYMENT
    CMP AL, '4'      ; NEW - Update payment status
    JE AD_UPDATE_PAYMENT
    CMP AL, '5'
    JE AD_EXIT
    
    LEA DX, msg_invalid
    CALL PRINT_STRING
    CALL PAUSE
    JMP ADMIN_LOOP
    
AD_RECORDS:
    CALL VIEW_RECORDS
    JMP ADMIN_LOOP
AD_STATUS:
    CALL DISPLAY_STATUS
    JMP ADMIN_LOOP
AD_PAYMENT:
    CALL PAYMENT_STATUS_REPORT
    JMP ADMIN_LOOP
AD_UPDATE_PAYMENT:   ; NEW LABEL
    CALL UPDATE_PAYMENT_STATUS
    JMP ADMIN_LOOP
AD_EXIT:
    RET
ADMIN_PORTAL ENDP

CUSTOMER_PORTAL PROC
CUST_LOOP:
    CALL CLEAR_SCREEN
    LEA DX, banner
    CALL PRINT_STRING
    LEA DX, customer_menu
    CALL PRINT_STRING
    CALL GET_CHAR
    
    CMP AL, '1'
    JE CU_AVAIL
    CMP AL, '2'
    JE CU_CHECKIN
    CMP AL, '3'
    JE CU_CHECKOUT
    CMP AL, '4'
    JE CU_PAYMENT
    CMP AL, '5'
    JE CU_EXIT
    
    LEA DX, msg_invalid
    CALL PRINT_STRING
    CALL PAUSE
    JMP CUST_LOOP
    
CU_AVAIL:
    CALL DISPLAY_STATUS
    JMP CUST_LOOP
CU_CHECKIN:
    CALL CHECKIN_PROCESS
    JMP CUST_LOOP
CU_CHECKOUT:
    CALL CHECKOUT_PROCESS
    JMP CUST_LOOP
CU_PAYMENT:
    CALL MAKE_PAYMENT
    JMP CUST_LOOP
CU_EXIT:
    RET
CUSTOMER_PORTAL ENDP

VALIDATE_CNIC PROC
    PUSH DI
    PUSH CX
    PUSH BX
    
    MOV CX, 0
    MOV BX, DI
COUNT_CNIC:
    MOV AL, [BX]
    CMP AL, 0
    JE CHECK_CNIC_LEN
    CMP AL, '0'
    JB INVALID_CNIC
    CMP AL, '9'
    JA INVALID_CNIC
    INC CX
    INC BX
    JMP COUNT_CNIC
    
CHECK_CNIC_LEN:
    CMP CX, 13
    JNE INVALID_CNIC
    
    MOV AL, [DI]
    CMP AL, '1'
    JNE INVALID_CNIC
    MOV AL, [DI+1]
    CMP AL, '2'
    JNE INVALID_CNIC
    MOV AL, [DI+2]
    CMP AL, '3'
    JNE INVALID_CNIC
    MOV AL, [DI+3]
    CMP AL, '4'
    JNE INVALID_CNIC
    
    MOV AL, 1
    JMP CNIC_DONE
    
INVALID_CNIC:
    MOV AL, 0
    
CNIC_DONE:
    POP BX
    POP CX
    POP DI
    RET
VALIDATE_CNIC ENDP

VALIDATE_PHONE PROC
    PUSH DI
    PUSH CX
    PUSH BX
    
    MOV CX, 0
    MOV BX, DI
COUNT_PHONE:
    MOV AL, [BX]
    CMP AL, 0
    JE CHECK_PHONE_LEN
    CMP AL, '0'
    JB INVALID_PHONE
    CMP AL, '9'
    JA INVALID_PHONE
    INC CX
    INC BX
    JMP COUNT_PHONE
    
CHECK_PHONE_LEN:
    CMP CX, 11
    JNE INVALID_PHONE
    
    MOV AL, 1
    JMP PHONE_DONE
    
INVALID_PHONE:
    MOV AL, 0
    
PHONE_DONE:
    POP BX
    POP CX
    POP DI
    RET
VALIDATE_PHONE ENDP

CHECKIN_PROCESS PROC
    LEA DX, prompt_room
    CALL PRINT_STRING
    CALL GET_NUMBER
    CMP AX, 1
    JB INVALID_CHK
    CMP AX, MAX_ROOMS
    JA INVALID_CHK
    DEC AX
    MOV temp_room, AL
    MOV BL, AL
    XOR BH, BH
    CMP room_status[BX], 1
    JE OCCUPIED_CHK
    
    LEA DX, prompt_room_type
    CALL PRINT_STRING
    CALL GET_CHAR
    SUB AL, '0'
    CMP AL, 1
    JB INVALID_CHK
    CMP AL, 3
    JA INVALID_CHK
    MOV BL, temp_room
    XOR BH, BH
    MOV room_types[BX], AL
    
    LEA DX, prompt_name
    CALL PRINT_STRING
    MOV AL, temp_room
    MOV CL, 20
    MUL CL
    LEA DI, customer_names
    ADD DI, AX
    CALL GET_STRING
    
RETRY_CNIC:
    LEA DX, prompt_cnic
    CALL PRINT_STRING
    MOV AL, temp_room
    MOV CL, 14
    MUL CL
    LEA DI, customer_cnic
    ADD DI, AX
    CALL GET_STRING
    CALL VALIDATE_CNIC
    CMP AL, 1
    JE CNIC_OK
    LEA DX, msg_cnic_error
    CALL PRINT_STRING
    JMP RETRY_CNIC
    
CNIC_OK:
RETRY_PHONE:
    LEA DX, prompt_phone
    CALL PRINT_STRING
    MOV AL, temp_room
    MOV CL, 12
    MUL CL
    LEA DI, customer_phone
    ADD DI, AX
    CALL GET_STRING
    CALL VALIDATE_PHONE
    CMP AL, 1
    JE PHONE_OK
    LEA DX, msg_phone_error
    CALL PRINT_STRING
    JMP RETRY_PHONE
    
PHONE_OK:
    LEA DX, prompt_days
    CALL PRINT_STRING
    CALL GET_NUMBER
    MOV BL, temp_room
    XOR BH, BH
    MOV stay_duration[BX], AL
    
    MOV room_status[BX], 1
    MOV payment_status[BX], 0
    
    LEA DX, newline
    CALL PRINT_STRING
    LEA DX, msg_success
    CALL PRINT_STRING
    CALL PAUSE
    RET
    
INVALID_CHK:
    LEA DX, msg_invalid
    CALL PRINT_STRING
    CALL PAUSE
    RET
OCCUPIED_CHK:
    LEA DX, msg_occupied
    CALL PRINT_STRING
    CALL PAUSE
    RET
CHECKIN_PROCESS ENDP

MAKE_PAYMENT PROC
    LEA DX, prompt_room
    CALL PRINT_STRING
    CALL GET_NUMBER
    CMP AX, 1
    JB INVALID_PAY
    CMP AX, MAX_ROOMS
    JA INVALID_PAY
    DEC AX
    MOV temp_room, AL
    MOV BL, AL
    XOR BH, BH
    CMP room_status[BX], 0
    JE VACANT_PAY
    
    MOV AL, room_types[BX]
    DEC AL
    MOV CL, 2
    MUL CL
    LEA SI, room_prices
    ADD SI, AX
    MOV AX, [SI]
    
    MOV BL, temp_room
    XOR BH, BH
    MOV CL, stay_duration[BX]
    XOR CH, CH
    MUL CX
    PUSH AX
    
    LEA DX, newline
    CALL PRINT_STRING
    CALL PRINT_RATE_LABEL
    CALL PRINT_NUMBER
    LEA DX, newline
    CALL PRINT_STRING
    
RETRY_PAYMENT:
    LEA DX, prompt_payment_amt
    CALL PRINT_STRING
    CALL GET_NUMBER
    
    POP BX
    PUSH BX
    CMP AX, BX
    JA EXCESS_PAY
    JE EXACT_PAY
    
    LEA DX, msg_payment_error
    CALL PRINT_STRING
    LEA DX, newline
    CALL PRINT_STRING
    JMP RETRY_PAYMENT
    
EXCESS_PAY:
    POP BX
    LEA DX, msg_payment_excess
    CALL PRINT_STRING
    CALL PAUSE
    RET
    
EXACT_PAY:
    POP BX
    
    LEA DX, newline
    CALL PRINT_STRING
    ; Payment method is always Cash (1)
    MOV BL, temp_room
    XOR BH, BH
    MOV payment_method[BX], 1  ; Always Cash = 1
    MOV payment_status[BX], 1  ; Mark as Paid
    
    LEA DX, msg_success
    CALL PRINT_STRING
    LEA DX, newline
    CALL PRINT_STRING
    MOV AH, 02H
    MOV DL, 'P'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'y'
    INT 21H
    MOV DL, 'm'
    INT 21H
    MOV DL, 'e'
    INT 21H
    MOV DL, 'n'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'm'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'd'
    INT 21H
    MOV DL, 'e'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'i'
    INT 21H
    MOV DL, 'n'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'C'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 's'
    INT 21H
    MOV DL, 'h'
    INT 21H
    LEA DX, newline
    CALL PRINT_STRING
    
    CALL PAUSE
    RET
    
INVALID_PAY:
    LEA DX, msg_invalid
    CALL PRINT_STRING
    CALL PAUSE
    RET
VACANT_PAY:
    LEA DX, msg_vacant
    CALL PRINT_STRING
    CALL PAUSE
    RET
MAKE_PAYMENT ENDP

; NEW PROCEDURE: UPDATE_PAYMENT_STATUS
UPDATE_PAYMENT_STATUS PROC
    LEA DX, prompt_room
    CALL PRINT_STRING
    CALL GET_NUMBER
    CMP AX, 1
    JB INVALID_UPDATE
    CMP AX, MAX_ROOMS
    JA INVALID_UPDATE
    DEC AX
    MOV temp_room, AL
    MOV BL, AL
    XOR BH, BH
    CMP room_status[BX], 0
    JE VACANT_UPDATE
    
    LEA DX, prompt_update_choice
    CALL PRINT_STRING
    CALL GET_CHAR
    
    CMP AL, '1'
    JE SET_PAID
    CMP AL, '2'
    JE SET_UNPAID
    CMP AL, '3'
    JE SET_PENDING
    
    LEA DX, msg_invalid
    CALL PRINT_STRING
    CALL PAUSE
    RET
    
SET_PAID:
    MOV BL, temp_room
    XOR BH, BH
    MOV payment_status[BX], 1
    JMP UPDATE_SUCCESS
    
SET_UNPAID:
    MOV BL, temp_room
    XOR BH, BH
    MOV payment_status[BX], 0
    JMP UPDATE_SUCCESS
    
SET_PENDING:
    MOV BL, temp_room
    XOR BH, BH
    MOV payment_status[BX], 2
    JMP UPDATE_SUCCESS
    
UPDATE_SUCCESS:
    LEA DX, msg_update_success
    CALL PRINT_STRING
    CALL PAUSE
    RET
    
INVALID_UPDATE:
    LEA DX, msg_invalid
    CALL PRINT_STRING
    CALL PAUSE
    RET
    
VACANT_UPDATE:
    LEA DX, msg_vacant
    CALL PRINT_STRING
    CALL PAUSE
    RET
UPDATE_PAYMENT_STATUS ENDP

PAYMENT_STATUS_REPORT PROC
    CALL CLEAR_SCREEN
    LEA DX, msg_payment_stat
    CALL PRINT_STRING
    
    MOV SI, 0
    MOV CX, MAX_ROOMS
PSR_LOOP:
    PUSH CX
    PUSH SI
    
    MOV BX, SI
    CMP room_status[BX], 0
    JE PSR_SKIP
    
    LEA DX, newline
    CALL PRINT_STRING
    CALL PRINT_ROOM_LABEL
    POP SI
    PUSH SI
    MOV AX, SI
    INC AX
    CALL PRINT_NUMBER
    MOV AH, 02H
    MOV DL, ' '
    INT 21H
    MOV DL, '-'
    INT 21H
    MOV DL, ' '
    INT 21H
    
    POP SI
    PUSH SI
    MOV AX, SI
    MOV BL, 20
    MUL BL
    LEA DI, customer_names
    ADD DI, AX
    CALL PRINT_STR_DI
    
    POP SI
    PUSH SI
    MOV BX, SI
    MOV AL, payment_status[BX]
    CMP AL, 0
    JE PSR_UNPAID
    CMP AL, 1
    JE PSR_PAID
    LEA DX, msg_pending
    JMP PSR_PRINT_STAT
PSR_UNPAID:
    LEA DX, msg_unpaid
    JMP PSR_PRINT_STAT
PSR_PAID:
    LEA DX, msg_paid
PSR_PRINT_STAT:
    CALL PRINT_STRING
    
PSR_SKIP:
    POP SI
    POP CX
    INC SI
    DEC CX
    JNZ PSR_LOOP
    
    LEA DX, newline
    CALL PRINT_STRING
    CALL PAUSE
    RET
PAYMENT_STATUS_REPORT ENDP

VIEW_RECORDS PROC
    CALL CLEAR_SCREEN
    LEA DX, banner
    CALL PRINT_STRING
    MOV SI, 0
    MOV CX, MAX_ROOMS
VR_LOOP:
    PUSH CX
    PUSH SI
    MOV BX, SI
    CMP room_status[BX], 0
    JE VR_SKIP
    
    LEA DX, newline
    CALL PRINT_STRING
    CALL PRINT_ROOM_LABEL
    POP SI
    PUSH SI
    MOV AX, SI
    INC AX
    CALL PRINT_NUMBER
    LEA DX, newline
    CALL PRINT_STRING
    
    CALL PRINT_CUSTOMER_LABEL
    POP SI
    PUSH SI
    MOV AX, SI
    MOV BL, 20
    MUL BL
    LEA DI, customer_names
    ADD DI, AX
    CALL PRINT_STR_DI
    LEA DX, newline
    CALL PRINT_STRING
    
    CALL PRINT_CNIC_LABEL
    POP SI
    PUSH SI
    MOV AX, SI
    MOV BL, 14
    MUL BL
    LEA DI, customer_cnic
    ADD DI, AX
    CALL PRINT_STR_DI
    LEA DX, newline
    CALL PRINT_STRING
    
    CALL PRINT_PHONE_LABEL
    POP SI
    PUSH SI
    MOV AX, SI
    MOV BL, 12
    MUL BL
    LEA DI, customer_phone
    ADD DI, AX
    CALL PRINT_STR_DI
    LEA DX, newline
    CALL PRINT_STRING
    
    MOV AH, 02H
    MOV DL, 'P'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'y'
    INT 21H
    MOV DL, 'm'
    INT 21H
    MOV DL, 'e'
    INT 21H
    MOV DL, 'n'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, ':'
    INT 21H
    MOV DL, ' '
    INT 21H
    
    POP SI
    PUSH SI
    MOV BX, SI
    MOV AL, payment_status[BX]
    CMP AL, 0
    JE VR_UNPAID
    CMP AL, 1
    JE VR_PAID
    LEA DX, msg_pending
    JMP VR_PRINT_PAY
VR_UNPAID:
    LEA DX, msg_unpaid
    JMP VR_PRINT_PAY
VR_PAID:
    LEA DX, msg_paid
VR_PRINT_PAY:
    CALL PRINT_STRING
    LEA DX, newline
    CALL PRINT_STRING
    LEA DX, newline
    CALL PRINT_STRING
    
VR_SKIP:
    POP SI
    POP CX
    INC SI
    DEC CX
    JNZ VR_LOOP
    CALL PAUSE
    RET
VIEW_RECORDS ENDP

DISPLAY_STATUS PROC
    CALL CLEAR_SCREEN
    LEA DX, msg_room_status
    CALL PRINT_STRING
    MOV SI, 0
    MOV CX, MAX_ROOMS
DS_LOOP:
    PUSH CX
    PUSH SI
    LEA DX, newline
    CALL PRINT_STRING
    CALL PRINT_ROOM_LABEL
    POP SI
    PUSH SI
    MOV AX, SI
    INC AX
    CALL PRINT_NUMBER
    MOV AH, 02H
    MOV DL, ':'
    INT 21H
    MOV DL, ' '
    INT 21H
    
    MOV BX, SI
    CMP room_status[BX], 0
    JE DS_VACANT
    CALL PRINT_OCCUPIED
    JMP DS_SHOW_TYPE
DS_VACANT:
    CALL PRINT_VACANT
DS_SHOW_TYPE:
    MOV BX, SI
    MOV AL, room_types[BX]
    CMP AL, 1
    JE DS_STD
    CMP AL, 2
    JE DS_DLX
    CALL PRINT_SUITE
    JMP DS_NEXT
DS_STD:
    CALL PRINT_STANDARD
    JMP DS_NEXT
DS_DLX:
    CALL PRINT_DELUXE
DS_NEXT:
    POP SI
    POP CX
    INC SI
    DEC CX
    JNZ DS_LOOP
    LEA DX, newline
    CALL PRINT_STRING
    CALL PAUSE
    RET
DISPLAY_STATUS ENDP

CHECKOUT_PROCESS PROC
    LEA DX, prompt_room
    CALL PRINT_STRING
    CALL GET_NUMBER
    CMP AX, 1
    JB INVALID_CO
    CMP AX, MAX_ROOMS
    JA INVALID_CO
    DEC AX
    MOV temp_room, AL
    MOV BL, AL
    XOR BH, BH
    CMP room_status[BX], 0
    JE VACANT_CO
    
    MOV AL, payment_status[BX]
    CMP AL, 1
    JNE PAYMENT_NOT_MADE
    
    CALL CLEAR_SCREEN
    LEA DX, msg_bill
    CALL PRINT_STRING
    CALL PRINT_CUSTOMER_LABEL
    MOV AL, temp_room
    MOV CL, 20
    MUL CL
    LEA DI, customer_names
    ADD DI, AX
    CALL PRINT_STR_DI
    LEA DX, newline
    CALL PRINT_STRING
    
    CALL PRINT_ROOMTYPE_LABEL
    MOV BL, temp_room
    XOR BH, BH
    MOV AL, room_types[BX]
    CMP AL, 1
    JE CO_STD
    CMP AL, 2
    JE CO_DLX
    LEA DX, type_suite
    JMP CO_PTYPE
CO_STD:
    LEA DX, type_standard
    JMP CO_PTYPE
CO_DLX:
    LEA DX, type_deluxe
CO_PTYPE:
    CALL PRINT_STRING
    LEA DX, newline
    CALL PRINT_STRING
    
    CALL PRINT_DAYS_LABEL
    MOV BL, temp_room
    XOR BH, BH
    MOV AL, stay_duration[BX]
    XOR AH, AH
    CALL PRINT_NUMBER
    LEA DX, newline
    CALL PRINT_STRING
    
    CALL PRINT_RATE_LABEL
    MOV AL, room_types[BX]
    DEC AL
    MOV CL, 2
    MUL CL
    LEA SI, room_prices
    ADD SI, AX
    MOV AX, [SI]
    CALL PRINT_NUMBER
    LEA DX, newline
    CALL PRINT_STRING
    
    CALL PRINT_TOTAL_LABEL
    MOV AL, stay_duration[BX]
    XOR AH, AH
    MUL WORD PTR [SI]
    CALL PRINT_NUMBER
    LEA DX, newline
    CALL PRINT_STRING
    
    MOV AH, 02H
    MOV DL, 'P'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'y'
    INT 21H
    MOV DL, 'm'
    INT 21H
    MOV DL, 'e'
    INT 21H
    MOV DL, 'n'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'S'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, 'u'
    INT 21H
    MOV DL, 's'
    INT 21H
    MOV DL, ':'
    INT 21H
    MOV DL, ' '
    INT 21H
    
    LEA DX, msg_paid
    CALL PRINT_STRING
    
    ; Show payment method (always Cash)
    LEA DX, newline
    CALL PRINT_STRING
    MOV AH, 02H
    MOV DL, 'P'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'y'
    INT 21H
    MOV DL, 'm'
    INT 21H
    MOV DL, 'e'
    INT 21H
    MOV DL, 'n'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'M'
    INT 21H
    MOV DL, 'e'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, 'h'
    INT 21H
    MOV DL, 'o'
    INT 21H
    MOV DL, 'd'
    INT 21H
    MOV DL, ':'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'C'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 's'
    INT 21H
    MOV DL, 'h'
    INT 21H
    LEA DX, newline
    CALL PRINT_STRING
    
    LEA DX, msg_thanks
    CALL PRINT_STRING
    MOV BL, temp_room
    XOR BH, BH
    MOV room_status[BX], 0
    MOV stay_duration[BX], 0
    MOV payment_method[BX], 0
    MOV payment_status[BX], 0
    CALL PAUSE
    RET
    
PAYMENT_NOT_MADE:
    LEA DX, msg_payment_required
    CALL PRINT_STRING
    CALL PAUSE
    RET
INVALID_CO:
    LEA DX, msg_invalid
    CALL PRINT_STRING
    CALL PAUSE
    RET
VACANT_CO:
    LEA DX, msg_vacant
    CALL PRINT_STRING
    CALL PAUSE
    RET
CHECKOUT_PROCESS ENDP

PRINT_STRING PROC
    MOV AH, 09H
    INT 21H
    RET
PRINT_STRING ENDP

PRINT_STR_DI PROC
    PUSH DI
    PUSH AX
    PUSH DX
PLOOP:
    MOV DL, [DI]
    CMP DL, 0
    JE PEND
    MOV AH, 02H
    INT 21H
    INC DI
    JMP PLOOP
PEND:
    POP DX
    POP AX
    POP DI
    RET
PRINT_STR_DI ENDP

GET_CHAR PROC
    MOV AH, 01H
    INT 21H
    RET
GET_CHAR ENDP

GET_STRING PROC
    PUSH DI
    PUSH AX
    PUSH CX
    MOV SI, DI
    MOV CX, 20
CLRBUF:
    MOV BYTE PTR [DI], 0
    INC DI
    LOOP CLRBUF
    MOV DI, SI
GSLOOP:
    MOV AH, 01H
    INT 21H
    CMP AL, 13
    JE GSEND
    CMP AL, 8
    JE GSLOOP
    MOV [DI], AL
    INC DI
    JMP GSLOOP
GSEND:
    MOV BYTE PTR [DI], 0
    POP CX
    POP AX
    POP DI
    RET
GET_STRING ENDP

GET_NUMBER PROC
    PUSH BX
    PUSH CX
    PUSH DX
    XOR BX, BX
    MOV CX, 10
GNLOOP:
    MOV AH, 01H
    INT 21H
    CMP AL, 13
    JE GNEND
    CMP AL, '0'
    JB GNLOOP
    CMP AL, '9'
    JA GNLOOP
    SUB AL, '0'
    PUSH AX
    MOV AX, BX
    MUL CX
    MOV BX, AX
    POP AX
    XOR AH, AH
    ADD BX, AX
    JMP GNLOOP
GNEND:
    MOV AX, BX
    POP DX
    POP CX
    POP BX
    RET
GET_NUMBER ENDP

PRINT_NUMBER PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    XOR CX, CX
    MOV BX, 10
PNLOOP:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    TEST AX, AX
    JNZ PNLOOP
PDIGIT:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PDIGIT
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUMBER ENDP

CLEAR_SCREEN PROC
    MOV AH, 00H
    MOV AL, 03H
    INT 10H
    RET
CLEAR_SCREEN ENDP

PAUSE PROC
    PUSH AX
    PUSH DX
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    MOV AH, 02H
    MOV DL, 'P'
    INT 21H
    MOV DL, 'r'
    INT 21H
    MOV DL, 'e'
    INT 21H
    MOV DL, 's'
    INT 21H
    MOV DL, 's'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'n'
    INT 21H
    MOV DL, 'y'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'k'
    INT 21H
    MOV DL, 'e'
    INT 21H
    MOV DL, 'y'
    INT 21H
    MOV DL, '.'
    INT 21H
    MOV DL, '.'
    INT 21H
    MOV DL, '.'
    INT 21H
    MOV AH, 01H
    INT 21H
    POP DX
    POP AX
    RET
PAUSE ENDP

PRINT_ROOM_LABEL PROC
    PUSH AX
    PUSH DX
    MOV AH, 02H
    MOV DL, 'R'
    INT 21H
    MOV DL, 'o'
    INT 21H
    MOV DL, 'o'
    INT 21H
    MOV DL, 'm'
    INT 21H
    MOV DL, ' '
    INT 21H
    POP DX
    POP AX
    RET
PRINT_ROOM_LABEL ENDP

PRINT_CUSTOMER_LABEL PROC
    PUSH AX
    PUSH DX
    MOV AH, 02H
    MOV DL, 'C'
    INT 21H
    MOV DL, 'u'
    INT 21H
    MOV DL, 's'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, 'o'
    INT 21H
    MOV DL, 'm'
    INT 21H
    MOV DL, 'e'
    INT 21H
    MOV DL, 'r'
    INT 21H
    MOV DL, ':'
    INT 21H
    MOV DL, ' '
    INT 21H
    POP DX
    POP AX
    RET
PRINT_CUSTOMER_LABEL ENDP

PRINT_CNIC_LABEL PROC
    PUSH AX
    PUSH DX
    MOV AH, 02H
    MOV DL, 'C'
    INT 21H
    MOV DL, 'N'
    INT 21H
    MOV DL, 'I'
    INT 21H
    MOV DL, 'C'
    INT 21H
    MOV DL, ':'
    INT 21H
    MOV DL, ' '
    INT 21H
    POP DX
    POP AX
    RET
PRINT_CNIC_LABEL ENDP

PRINT_PHONE_LABEL PROC
    PUSH AX
    PUSH DX
    MOV AH, 02H
    MOV DL, 'P'
    INT 21H
    MOV DL, 'h'
    INT 21H
    MOV DL, 'o'
    INT 21H
    MOV DL, 'n'
    INT 21H
    MOV DL, 'e'
    INT 21H
    MOV DL, ':'
    INT 21H
    MOV DL, ' '
    INT 21H
    POP DX
    POP AX
    RET
PRINT_PHONE_LABEL ENDP

PRINT_OCCUPIED PROC
    PUSH AX
    PUSH DX
    MOV AH, 02H
    MOV DL, 'O'
    INT 21H
    MOV DL, 'c'
    INT 21H
    MOV DL, 'c'
    INT 21H
    MOV DL, 'u'
    INT 21H
    MOV DL, 'p'
    INT 21H
    MOV DL, 'i'
    INT 21H
    MOV DL, 'e'
    INT 21H
    MOV DL, 'd'
    INT 21H
    POP DX
    POP AX
    RET
PRINT_OCCUPIED ENDP

PRINT_VACANT PROC
    PUSH AX
    PUSH DX
    MOV AH, 02H
    MOV DL, 'V'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'c'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'n'
    INT 21H
    MOV DL, 't'
    INT 21H
    POP DX
    POP AX
    RET
PRINT_VACANT ENDP

PRINT_STANDARD PROC
    PUSH AX
    PUSH DX
    MOV AH, 02H
    MOV DL, ' '
    INT 21H
    MOV DL, '-'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'S'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'n'
    INT 21H
    MOV DL, 'd'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'r'
    INT 21H
    MOV DL, 'd'
    INT 21H
    POP DX
    POP AX
    RET
PRINT_STANDARD ENDP

PRINT_DELUXE PROC
    PUSH AX
    PUSH DX
    MOV AH, 02H
    MOV DL, ' '
    INT 21H
    MOV DL, '-'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'D'
    INT 21H
    MOV DL, 'e'
    INT 21H
    MOV DL, 'l'
    INT 21H
    MOV DL, 'u'
    INT 21H
    MOV DL, 'x'
    INT 21H
    MOV DL, 'e'
    INT 21H
    POP DX
    POP AX
    RET
PRINT_DELUXE ENDP

PRINT_SUITE PROC
    PUSH AX
    PUSH DX
    MOV AH, 02H
    MOV DL, ' '
    INT 21H
    MOV DL, '-'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'S'
    INT 21H
    MOV DL, 'u'
    INT 21H
    MOV DL, 'i'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, 'e'
    INT 21H
    POP DX
    POP AX
    RET
PRINT_SUITE ENDP

PRINT_ROOMTYPE_LABEL PROC
    PUSH AX
    PUSH DX
    MOV AH, 02H
    MOV DL, 'R'
    INT 21H
    MOV DL, 'o'
    INT 21H
    MOV DL, 'o'
    INT 21H
    MOV DL, 'm'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'T'
    INT 21H
    MOV DL, 'y'
    INT 21H
    MOV DL, 'p'
    INT 21H
    MOV DL, 'e'
    INT 21H
    MOV DL, ':'
    INT 21H
    MOV DL, ' '
    INT 21H
    POP DX
    POP AX
    RET
PRINT_ROOMTYPE_LABEL ENDP

PRINT_DAYS_LABEL PROC
    PUSH AX
    PUSH DX
    MOV AH, 02H
    MOV DL, 'D'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'y'
    INT 21H
    MOV DL, 's'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'S'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'y'
    INT 21H
    MOV DL, 'e'
    INT 21H
    MOV DL, 'd'
    INT 21H
    MOV DL, ':'
    INT 21H
    MOV DL, ' '
    INT 21H
    POP DX
    POP AX
    RET
PRINT_DAYS_LABEL ENDP

PRINT_RATE_LABEL PROC
    PUSH AX
    PUSH DX
    MOV AH, 02H
    MOV DL, 'R'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, 'e'
    INT 21H
    MOV DL, '/'
    INT 21H
    MOV DL, 'D'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'y'
    INT 21H
    MOV DL, ':'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'R'
    INT 21H
    MOV DL, 's'
    INT 21H
    MOV DL, '.'
    INT 21H
    POP DX
    POP AX
    RET
PRINT_RATE_LABEL ENDP

PRINT_TOTAL_LABEL PROC
    PUSH AX
    PUSH DX
    MOV AH, 02H
    MOV DL, 'T'
    INT 21H
    MOV DL, 'o'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'l'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'A'
    INT 21H
    MOV DL, 'm'
    INT 21H
    MOV DL, 'o'
    INT 21H
    MOV DL, 'u'
    INT 21H
    MOV DL, 'n'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, ':'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'R'
    INT 21H
    MOV DL, 's'
    INT 21H
    MOV DL, '.'
    INT 21H
    POP DX
    POP AX
    RET
PRINT_TOTAL_LABEL ENDP

END MAIN