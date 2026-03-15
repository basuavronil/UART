# UART (Universal Asynchronous Receiver Transmitter)

This project implements a **UART communication protocol in Verilog**. UART is a widely used **serial communication protocol** that enables data transfer between devices using two wires: **TX (Transmit)** and **RX (Receive)**.

## 📌 Overview
UART converts **parallel data from a processor into serial data** for transmission and converts received **serial data back into parallel form**. It is commonly used in **microcontrollers, FPGAs, and embedded systems** for device communication.

## ⚙️ Features
- Serial communication protocol
- Full duplex communication (simultaneous transmit and receive)
- FSM-based design
- Start bit and stop bit detection
- Parallel-to-Serial and Serial-to-Parallel data conversion

## 🏗️ Architecture
The UART system consists of two main blocks:

- **Transmitter (TX)** → Converts parallel data into serial bits for transmission.
- **Receiver (RX)** → Converts incoming serial data back into parallel format.

Communication occurs through two lines:
- **TX line** → Transmits data
- **RX line** → Receives data

## 🔄 UART Frame Format

| Start Bit | Data Bits | Stop Bit |
|-----------|-----------|----------|
| 1 bit     | 8 bits    | 1 bit    |

Example Transmission:

```
Start → 10100101 → Stop
```

## 📂 Project Structure

```
.
├── dut.v        # UART design module
├── tb.v         # Testbench for simulation
├── README.md    # Project documentation
```

## ▶️ Simulation
The design can be simulated using standard **Verilog simulation tools** such as:

- ModelSim
- Vivado Simulator
- Icarus Verilog

Run the testbench to observe UART transmission and reception.

## 🚀 Applications
UART is widely used in:

- Embedded systems
- FPGA communication
- Debugging interfaces
- Serial communication between devices

## 👨‍💻 Author
Avronil
