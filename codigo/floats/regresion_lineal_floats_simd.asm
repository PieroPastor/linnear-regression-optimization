section .text
    global regresion_lineal_floats_simd

;rdi <- pointer to x
;rsi <- pointer to y
;rdx <- number of data "n"
;rcx <- pointer to b

regresion_lineal_floats_simd:
    xorps xmm0, xmm0 ;Sumará los x*y
    xorps xmm1, xmm1 ;Sumará los x
    xorps xmm2, xmm2 ;Sumará los y
    xorps xmm3, xmm3 ;Sumará los x^2
    xorps xmm4, xmm4 ;Servirá de auxiliar 1
    xorps xmm5, xmm5 ;Servirá de auxiliar 2
    cvtsi2ss xmm6, rdx ;Guardará n para operar
    mov r9, 0
    cmp r9, rdx
    jl sumadores_x_y
ret

sumadores_x_y:
    mov r10, rdx
    sub r10, r9
    cmp r10, 3
    jle bucle_sobrantes ;Como para que el SIMD funcione se necesita en caso de floats un n que sea múltiplo de 4, se tomará el caso para los que puedan sobrar
    movaps xmm4, [rdi + r9*4] ;Se multiplica por 4, ya que son floats de 4 bytes
    movaps xmm5, xmm4
    haddps xmm5, xmm5
    haddps xmm5, xmm5
    addss xmm1, xmm5 ;Se le suma al sumador de x, 4 valores de x

    movaps xmm5, xmm4
    mulps xmm5, xmm5
    haddps xmm5, xmm5
    haddps xmm5, xmm5
    addss xmm3, xmm5 ;Se le suma al sumador de x^2, 4 valores de x^2

    movaps xmm5, [rsi + r9*4]
    mulps xmm4, xmm5
    haddps xmm4, xmm4
    haddps xmm4, xmm4
    addss xmm0, xmm4 ;Se le suma al sumador de x*y, 4 valores de x*y

    haddps xmm5, xmm5
    haddps xmm5, xmm5
    addss xmm2, xmm5 ;Se le suma al sumador de y, 4 valores de y

    add r9, 4 ;Se le suma 4 porque en cada xmmx entran 4 floats y debe saltarse los siguientes 4
    cmp r9, rdx
    jl sumadores_x_y
    jmp fin_algoritmo

bucle_sobrantes:
    movss xmm4, [rdi + r9*4] ;x
    movss xmm5, [rsi + r9*4] ;y
    addss xmm1, xmm4
    addss xmm2, xmm5
    mulss xmm5, xmm4
    addss xmm0, xmm5
    mulss xmm4, xmm4
    addss xmm3, xmm4
    inc r9
    cmp r9, rdx
    jl bucle_sobrantes
    jmp fin_algoritmo

fin_algoritmo:
    ;B1
    xorps xmm5, xmm5
    mulss xmm0, xmm6
    mulss xmm3, xmm6
    addss xmm5, xmm0
    movss xmm4, xmm1
    mulss xmm4, xmm2
    subss xmm5, xmm4
    movss xmm4, xmm1
    mulss xmm4, xmm4
    subss xmm3, xmm4
    divss xmm5, xmm3
    ;B0
    mulss xmm1, xmm5
    subss xmm2, xmm1
    divss xmm2, xmm6
    ;Guardar en memoria
    movss [rcx], xmm2
    movss [rcx+4], xmm5
ret
