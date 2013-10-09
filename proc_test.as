' Create mif for proc test
mvi     R0,#d100
mvi     R1,#d101
mvi     R2,#d1
' R0 <- 100 - 101
sub     R0,R1
' Non zero, so move -1 into R1
mvnz    R1,R0
' R0 <- -1 + 1
add     R0,R2
' R3 = 0, R1 = -1 (or 100)
add     R3,R1
' Store -1 to address 0
st      R3,R0
' Load -1 from addr 0
ld      R5,R0
