This is my Verilog project in which I implemented the UART protocol in Verilog, with synchronous buffers on both transmitting and receiving ends for temporary data storage.

<h4> Implemented features: </h4>

1. Data width=8, stop bits=1
2. Even parity for error detection
3. Parameterizable clock frequency, baud rate, FIFO depth and FIFO width
4. Oversampling rate=16x at receiving end
5. RTS-CTS request line
6. Frame error and parity error flags

