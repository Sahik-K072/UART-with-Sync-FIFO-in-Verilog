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

It has an internal baud tick generator whose baud rate can be parameterized.\
It sends the data in this order:

- 1 start bit (a low signal)
- 8 data bits
- 1 even parity parity bit
- 1 stop bit (a high signal)

When the stop bit is sent, it pulls the tx_done line high for 1 system clock to alert the FIFO, which then reads the next data byte, unless it is empty.

<h3>RX module</h3>

<img width="481" height="344" alt="Screenshot 2026-08-05 001326" src="https://github.com/user-attachments/assets/884b1af7-cdec-4b75-a27f-3347426a11cc" />

This module receives the 11 bits from the TX module, checks the parity and stop bits for parity and frame errors respectively, and raises the corresponding flags in case of errors. Then, it takes the received byte and stores it in the FIFO for temporary storage before being read by another block/component. 

It asserts the rts(request to send) line (active-low) when:


- rx_request signal is high (requesting data to be received)
- full signal is high (the FIFO buffer is not full and more data can be stored)
**\*full is active-low signal**

It also has an internal baud tick generator which can be parameterized.\
It uses 16x oversampling to sample at the middle of the symbol duration.

When the stop bit is correctly received, it pulls the rx_done line high for 1 system clock to alert the FIFO, which then writes this byte into its memory.

<h3>Synchronous FIFO module</h3>

<img width="584" height="340" alt="Screenshot 2026-08-05 001333" src="https://github.com/user-attachments/assets/b79d921d-1b97-4882-9176-94360f8da7c7" />

- This module has a synchronous reset, and combinationally produced output and full & empty flags. These flags are active-low.
- It takes one multi-bit data input, a write signal and a read_next signal.
- The write pointer points at the next memory address where data is to be written. When write is high, the data is written into the memory.
- The read pointer points at the memory address currently being read. When read_next signal is high, the read pointer is incremented and the new data is instantly available at the output because of combinationally produced output.
- The full and empty flags are asserted when the write and read pointer point to the same address. To differentiate between full and empty, each pointer has an additional MSB in addition to the address bits. When these bits are equal, the read pointer has caught up with the write pointer, and thus empty is asserted. When unequal, the write pointer has wrapped around the memory and caught up with the read pointer, and thus full is asserted.

<h3>Top module</h3>

<img width="1768" height="439" alt="image" src="https://github.com/user-attachments/assets/b1213d74-3082-495d-8bc5-c915449c9078" />

The TX and FIFO modules are combined to make the tx_with_fifo module.\
The RX and FIFO modules are combined to make the rx_fifo_fifo module.\
These 2 modules are then combined inside the top module, in which these are connected to each other, thus performing both the transmitting and receiving operations simultaneously. The functionalities of all the modules are thus validated and verified in this top module. 
