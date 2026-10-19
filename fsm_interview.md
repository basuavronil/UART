# UART Transmitter FSM & Methodology

This repository contains the RTL implementation, finite state machine (FSM) design, and verification framework for a hardware UART Transmitter[cite: 2].

---

## 📋 Proposed Methodology Workflow

The design and verification flow follows a structured modular approach[cite: 2]:

* **Specifications**: Establishing the functional requirements, baud rate generation parameters, and frame formatting[cite: 2].
* **Architecture**: Designing internal submodules including the baud rate generator, counters, and shift registers[cite: 2].
* **FSM Design**: Developing the core state machine governing transmission cycles and control signals[cite: 2].
* **Top Module Instantiation**: Integrating the FSM, datapath, and counters into a top-level entity[cite: 2].
* **Waveform Verification**: Simulating the design via testbenches to validate correct serial bit transitions[cite: 2].

---

## 🔄 UART Transmitter FSM States

The transmitter operates using a 4-state Finite State Machine[cite: 2]:
