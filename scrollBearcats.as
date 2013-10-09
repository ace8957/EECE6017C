' This program will light up one segment on the 7 segment
' and cycle the lit up one
mvi R0,#b000000000
mvi R1,#b000000000
mvi R2,#b000000001
' Target 7 segment is seg 3
mvi R4,#b100001000
' Show #b000100000
mvi R5,#b000100000
st R5,R4
' Do delay loop
mv R5,PC
add R0,R2
add R1,R2
mvnz PC,R5
mvnz PC,R5
' Target 7 segment is seg 3
mvi R4,#b100001000
' Show #b000010000
mvi R5,#b000010000
st R5,R4
' Do delay loop
mv R5,PC
add R0,R2
add R1,R2
mvnz PC,R5
mvnz PC,R5
' Target 7 segment is seg 3
mvi R4,#b100001000
' Show #b000001000
mvi R5,#b000001000
st R5,R4
' Do delay loop
mv R5,PC
add R0,R2
add R1,R2
mvnz PC,R5
mvnz PC,R5
' Target 7 segment is seg 3
mvi R4,#b100001000
' Show #b000000100
mvi R5,#b000000100
st R5,R4
' Do delay loop
mv R5,PC
add R0,R2
add R1,R2
mvnz PC,R5
mvnz PC,R5
' Target 7 segment is seg 3
mvi R4,#b100001000
' Show #b000000010
mvi R5,#b000000010
st R5,R4
' Do delay loop
mv R5,PC
add R0,R2
add R1,R2
mvnz PC,R5
mvnz PC,R5
' Target 7 segment is seg 3
mvi R4,#b100001000
' Show #b000000001
mvi R5,#b000000001
st R5,R4
' Do delay loop
mv R5,PC
add R0,R2
add R1,R2
mvnz PC,R5
mvnz PC,R5
mvi PC,#h1ff
