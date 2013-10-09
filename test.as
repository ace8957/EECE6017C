'test mif'
'load 5 into the leds'
mvi r0,#b000000101
mvi r1,#b010000000
st r0,r1
'load 0101010 into 7 seg 0'
mvi r2,#b001111111
mvi r3,#b100000001
st r2,r3
mvi r3,#b100000010
st r2,r3
mvi r3,#b100000100
st r2,r3
mvi r3,#b100001000
st r2,r3
'add'
mvi r4,#b000000011
add r0,r4
st r0,r1
'stop'
mvi pc,$