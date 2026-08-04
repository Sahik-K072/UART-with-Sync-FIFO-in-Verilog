This is my Verilog project in which I implemented the UART protocol in Verilog, with synchronous buffers on both transmitting and receiving ends for temporary data storage.

I have implemented the UART modules using FSMs.

<h4> Implemented features: </h4>

1. Data width=8, stop bits=1
2. Even parity for error detection
3. Parameterizable clock frequency, baud rate, FIFO depth and FIFO width
4. Oversampling rate=16x at receiving end
5. RTS-CTS request line
6. Frame error and parity error flags

<h3>TX module</h3>

<img width="433" height="333" alt="Screenshot 2026-08-05 001258" src="https://github.com/user-attachments/assets/67844be6-5189-40fd-b3f5-0a94c90fcf5d" />

This module takes the 1 byte data to be sent, and sends it when:

- cts(clear to send) line is low
- tx_request singal is high (requesting data to be sent)
- empty signal is high (the FIFO buffer is not empty and there is data present)\
**\*empty and cts are active-low signals**

It has an internal baud tick generator whose baud rate can be parameterized.
It sends the data in this order:

- 1 start bit (a low signal)
- 8 data bits
- 1 even parity parity bit
- 1 stop bit (a high signal)

When the stop bit is sent, it pulls the tx_done line high for 1 system clock to alert the FIFO, which then reads the next data byte, unless it is empty.
