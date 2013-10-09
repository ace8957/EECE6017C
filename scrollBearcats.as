' This program will light up one segment on the 7 segment
' and cycle the lit up one
' First clear all of the 7 segment displays
mvi R0,#b111111111
mvi R1,#b100001000
st R0,R1
mvi R1,#b100000100
st R0,R1
mvi R1,#b100000010
st R0,R1
mvi R1,#b100000001
st R0,R1
' Start with the delays and displays
mvi R0,#d0
mvi R1,#b000000000
mvi R2,#b000000001
' Target 7 segment is seg 3
mvi R4,#b100001000
' Show #b111011111
mvi R5,#b111011111
st R5,R4
' Do delay loop
mv R5,PC
add R0,R2
mvnz PC,R5
add R1,R2
mvnz PC,R5
' Target 7 segment is seg 3
mvi R4,#b100001000
' Show #b111101111
mvi R5,#b111101111
st R5,R4
' Do delay loop
mv R5,PC
add R0,R2
mvnz PC,R5
add R1,R2
mvnz PC,R5
' Target 7 segment is seg 3
mvi R4,#b100001000
' Show #b111110111
mvi R5,#b111110111
st R5,R4
' Do delay loop
mv R5,PC
add R0,R2
mvnz PC,R5
add R1,R2
mvnz PC,R5
' Target 7 segment is seg 3
mvi R4,#b100001000
' Show #b111111011
mvi R5,#b111111011
st R5,R4
' Do delay loop
mv R5,PC
add R0,R2
mvnz PC,R5
add R1,R2
mvnz PC,R5
' Target 7 segment is seg 3
mvi R4,#b100001000
' Show #b111111101
mvi R5,#b111111101
st R5,R4
' Do delay loop
mv R5,PC
add R0,R2
mvnz PC,R5
add R1,R2
mvnz PC,R5
' Target 7 segment is seg 3
mvi R4,#b100001000
' Show #b111111110
mvi R5,#b111111110
st R5,R4
' Do delay loop
mv R5,PC
add R0,R2
mvnz PC,R5
add R1,R2
mvnz PC,R5
mvi PC,#h1ff
