<div>
Implementation of a simple ALU supporting 4 instructions( Srl , Sll, Xor , And) considering that the ALU can only read
the data from the buffer(The <i>FIFO queue</i> designed in <i>Problem 5</i> could be used), the input data is 1
byte for each input. 
Since the buffer is in use in every clock(ALU is reading from buffer), it is needed to
handle writing and reading of buffer so that it doesn’t make errors(not needed to make it efficient)
</div>
