' This program will light up one segment on the 7 segment
' and cycle the lit up one
' First clear all of the 7 segment displays
' Load the outermost loop from the switches into R6
mvi R1,#b110000000
ld R6,R1
' Load '1' into seg 3
mvi R0,#b111111001
mvi R1,#b100001000
st R0,R1
' Load '3' into segs 2 and 1
mvi R0,#b110110000
mvi R1,#b100000110
st R0,R1
' Load '7' into seg 0
mvi R0,#b111111000
mvi R1,#b100000001
st R0,R1
' Do delay loop
mv R1,R6
mvi R2,#d0
mvi R3,#d0
mvi R4,#d1
mv R5,PC
add R1,R4
mvnz PC,R5
add R2,R4
mvnz PC,R5
add R3,R4
mvnz PC,R5
' Load '1' into seg 2
mvi R0,#b111111001
mvi R1,#b100000100
st R0,R1
' Load '3' into segs 1 and 0
mvi R0,#b110110000
mvi R1,#b100000011
st R0,R1
' Load '7' into seg 3
mvi R0,#b111111000
mvi R1,#b100001000
st R0,R1
' Do delay loop
mv R1,R6
mvi R2,#d0
mvi R3,#d0
mvi R4,#d1
mv R5,PC
add R1,R4
mvnz PC,R5
add R2,R4
mvnz PC,R5
add R3,R4
mvnz PC,R5
' Load '1' into seg 1
mvi R0,#b111111001
mvi R1,#b100000010
st R0,R1
' Load '3' into segs 0 and 3
mvi R0,#b110110000
mvi R1,#b100001001
st R0,R1
' Load '7' into seg 2
mvi R0,#b111111000
mvi R1,#b100000100
st R0,R1
' Do delay loop
mv R1,R6
mvi R2,#d0
mvi R3,#d0
mvi R4,#d1
mv R5,PC
add R1,R4
mvnz PC,R5
add R2,R4
mvnz PC,R5
add R3,R4
mvnz PC,R5
' Load '1' into seg 0
mvi R0,#b111111001
mvi R1,#b100000001
st R0,R1
' Load '3' into segs 3 and 2
mvi R0,#b110110000
mvi R1,#b100001100
st R0,R1
' Load '7' into seg 1
mvi R0,#b111111000
mvi R1,#b100000010
st R0,R1
' Do delay loop
mv R1,R6
mvi R2,#d0
mvi R3,#d0
mvi R4,#d1
mv R5,PC
add R1,R4
mvnz PC,R5
add R2,R4
mvnz PC,R5
add R3,R4
mvnz PC,R5
' Repeat
mvi PC,#h1ff
