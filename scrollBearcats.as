' This program will scroll the word BEARCATS across the four 7 segment
' displays on the Altera DE1 board
' Use R0 as the target seg7 register
mvi R0,#b100001000
' Display B on HEX3
mvi R1,#d0
st R1,R0
' Display E on HEX2
mvi R0,#b100000100
mvi R1,#b000011000
st R1,R0
' Display A on HEX1
mvi R0,#b100000010
mvi R1,#b000000100
st R1,R0
' Display r on HEX0
mvi R0,#b100000001
mvi R1,#b000111001
st R1,R0
mvi PC,$-1
