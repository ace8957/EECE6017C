' Simple program to exhibit the capabilities of the processor designed
' in lab 4
mvi R0,#d44
mvi R1,#d55
' 44 + 55 = 99 in R0
add R0,R1
mvi R2,#d98
sub R0,R2
' if result of last subtraction is non-zero (yes) then move 99 into R3
mvnz R3,R2
mvi R4,#d127
' Store either 0 (no) or 99 (yes) into the last memory location
st R3,R4
' Read the switch values into R6
mvi R5,#b110000000
ld R6,R5
sub R6,R3
mvi PC,$
