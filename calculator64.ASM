format PE64 console
entry start

include 'win64ax.inc'              ; ??????????? ? ???????

section '.text' code readable executable

start:
    cinvoke printf, <"a/b + c",10,13>
    cinvoke printf, <"a = ">
    cinvoke scanf, <"%llx">, a

    cinvoke printf, <"b = ">
    cinvoke scanf, <"%llx">, b

    cinvoke printf, <"c = ">
    cinvoke scanf, <"%llx">, c

    ; Division using repeated subtraction
    mov rax, [a]  ; Load a into rax
    xor rdx, rdx  ; Clear rdx prior to division
    mov rcx, [b]  ; Load b into rcx

    ; Ensure division by zero is handled
    test rcx, rcx
    jz division_error

division_loop:
    cmp rax, rcx   ; Compare a with b
    jb division_done
    push rcx       ; �������� rcx ����� �������� subtract
    call subtract  ; ��������� ������� subtract ��� ��������� rcx � rax
    pop rcx        ; ³������� rcx ���� ������� subtract
    inc rdx        ; Increment result counter in rdx
    jmp division_loop


division_done:
    mov [q], rdx   ; Store quotient in variable q
    mov [r], rax   ; Store remainder in variable r

    ; Add c to quotient using adc instead of add
    mov rax, [q]   ; Load quotient into rax
    mov rcx, [c]   ; Load c into rcx
    clc            ; Clear carry flag
    adc rax, rcx   ; Add c to quotient using adc

    mov [result], rax
    cinvoke printf, <"wyn = %llx",10,13>, [result]
    jmp end_program

division_error:
    cinvoke printf, <"wyn = ***",10,13>

end_program:
    cinvoke scanf, <"%llx">, result
    invoke ExitProcess,0

subtract:
    push rcx           ; �������� rcx
    not rcx            ; ����������� NOT �� rcx, ��������� ~b
    clc                ; ������� ��������� ��������
    adc rcx, 1         ; ������ 1 �� ~b, �������� -b (���������� �� �����) � ����������� �������� ��������
    clc                ; ����� ������� ��������� �������� ��� �������� �������� adc
    adc rax, rcx       ; ������ -b �� a � ����������� �������� ��������
    pop rcx            ; ³������� rcx
    ret                ; ����������� � �������
section '.data' data readable writeable
    a dq 0
    b dq 0
    c dq 0
    q dq 0
    r dq 0
    result dq 0

section '.idata' import data readable writeable
    library msvcrt,'MSVCRT.DLL',\
            kernel32,'KERNEL32.DLL'

    import msvcrt,\
        printf,'printf',\
        scanf,'scanf',\
        getch,'_getch'

    import kernel32,\
        ExitProcess,'ExitProcess'