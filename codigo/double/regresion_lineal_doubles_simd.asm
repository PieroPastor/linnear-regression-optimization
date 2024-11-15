section .text
    global regresion_lineal_doubles_simd

;rdi <- pointer to x
;rsi <- pointer to y
;rdx <- number of data "n"
;rcx <- pointer to b

regresion_lineal_doubles_simd:
    xorpd xmm0, xmm0 ;Sumará los x*y
    xorpd xmm1, xmm1 ;Sumará los x
    xorpd xmm2, xmm2 ;Sumará los y
    xorpd xmm3, xmm3 ;Sumará los x^2
    xorpd xmm4, xmm4 ;Servirá de auxiliar 1
    xorpd xmm5, xmm5 ;Servirá de auxiliar 2
    cvtsi2sd xmm6, rdx ;Guardará n para operar
    mov r9, 0
    cmp r9, rdx
    jl sumadores_x_y
ret

sumadores_x_y:
    mov r10, rdx
    sub r10, r9
    cmp r10, 1
    jle bucle_sobrantes ;Como para que el SIMD funcione se necesita en caso de floats un n que sea múltiplo de 4, se tomará el caso para los que puedan sobrar
    movapd xmm4, [rdi + r9*8] ;Se multiplica por 8, ya que son doubles de 8 bytes
    movapd xmm5, xmm4
    haddpd xmm5, xmm5
    addsd xmm1, xmm5 ;Se le suma al sumador de x, 2 valores de x

    movapd xmm5, xmm4
    mulpd xmm5, xmm5
    haddpd xmm5, xmm5
    addsd xmm3, xmm5 ;Se le suma al sumador de x^2, 2 valores de x^2

    movapd xmm5, [rsi + r9*8]
    mulpd xmm4, xmm5
    haddpd xmm4, xmm4
    addsd xmm0, xmm4 ;Se le suma al sumador de x*y, 2 valores de x*y

    haddpd xmm5, xmm5
    addsd xmm2, xmm5 ;Se le suma al sumador de y, 2 valores de y

    add r9, 2 ;Avanza de 2 en 2 porque en cada xmmx entran 2 doubles y debe saltarse los siguientes 2
    cmp r9, rdx
    jl sumadores_x_y
    jmp fin_algoritmo

bucle_sobrantes:
    movsd xmm4, [rdi + r9*8] ;x
    movsd xmm5, [rsi + r9*8] ;y
    addsd xmm1, xmm4
    addsd xmm2, xmm5
    mulsd xmm5, xmm4
    addsd xmm0, xmm5
    mulsd xmm4, xmm4
    addsd xmm3, xmm4
    inc r9
    cmp r9, rdx
    jl bucle_sobrantes
    jmp fin_algoritmo

fin_algoritmo:
    ;B1
    xorpd xmm5, xmm5
    mulsd xmm0, xmm6
    mulsd xmm3, xmm6
    addsd xmm5, xmm0
    movsd xmm4, xmm1
    mulsd xmm4, xmm2
    subsd xmm5, xmm4
    movsd xmm4, xmm1
    mulsd xmm4, xmm4
    subsd xmm3, xmm4
    divsd xmm5, xmm3
    ;B0
    mulsd xmm1, xmm5
    subsd xmm2, xmm1
    divsd xmm2, xmm6
    ;Guardar en memoria
    movsd [rcx], xmm2
    movsd [rcx+8], xmm5
ret
