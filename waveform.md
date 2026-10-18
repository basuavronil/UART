<img width="1364" height="859" alt="image" src="https://github.com/user-attachments/assets/d032220f-a03a-48eb-8ef1-97acace563d7" />

# UART Timing Diagram: 8N1 Frame (byte `0x41`)

This document explains, cycle by cycle, the UART transmit and receive waveform for a single byte (`0x41`, ASCII `'A'`) sent with the **8N1** format: 8 data bits, no parity, 1 stop bit.

> Add the exported waveform image here:
> `![UART timing diagram](docs/uart_timing.png)`

---

## Table of contents

1. [Protocol background](#protocol-background)
2. [Signal descriptions](#signal-descriptions)
3. [Waveform at a glance](#waveform-at-a-glance)
4. [Byte encoding](#byte-encoding)
5. [Cycle-by-cycle walkthrough](#cycle-by-cycle-walkthrough)
6. [Summary table](#summary-table)
7. [Receiver behaviour](#receiver-behaviour)
8. [Notes and simplifications](#notes-and-simplifications)
9. [Extending the diagram](#extending-the-diagram)

---

## Protocol background

UART is an **asynchronous** serial protocol. There is no shared clock wire between transmitter and receiver. Instead, both sides agree in advance on a **baud rate**, and the receiver re-synchronises on the falling edge of every frame.

Key rules for 8N1:

- The line **idles high** (logic 1).
- A frame begins with one **start bit** (logic 0). The falling edge tells the receiver a frame is starting.
- **8 data bits** follow, **least significant bit (LSB) first**.
- A **stop bit** (logic 1) ends the frame and returns the line to idle.
- One bit lasts one **bit time** = `1 / baud rate`. At 115200 baud, a bit time is about 8.68 µs.
- A full frame is therefore **10 bit times**: 1 start + 8 data + 1 stop.

## Signal descriptions

The diagram uses the same visual style as the AXI read waveform. Each column `T0` to `T11` is **one bit time** (not one system clock cycle). Green signals belong to the host interface and orange signals belong to the serial line.

| Signal | Group | Type | Description |
|---|---|---|---|
| `BIT_CLK` | Clock | 1-bit | Baud-rate tick, one period per bit time. Every column starts on a rising edge. |
| `TX_START` | Host interface | 1-bit | Pulse from the host that asks the transmitter to send the byte on `TX_DATA`. |
| `TX_DATA` | Host interface | 8-bit bus | Byte to transmit (`0x41`). Latched into the transmit shift register when `TX_START` is seen. |
| `TXD` | Serial line | 1-bit | The actual UART output pin. Idle high. |
| `FRAME` | Serial line | annotation | Label row showing which part of the frame is on `TXD`: Start, D0 to D7, Stop. |
| `RX_VALID` | Host interface | 1-bit | Receiver output flag. High for one bit time when a complete byte is available. |
| `RX_DATA` | Host interface | 8-bit bus | Byte recovered by the receiver (`0x41`). Valid while `RX_VALID` is high. |

Legend:

- **Green line**: host interface signals
- **Orange line**: serial line (`TXD` and its frame annotation)
- **Dashed amber line with dot**: a transfer (a handshake point where data is accepted)

## Waveform at a glance

```
            T0   T1   T2   T3   T4   T5   T6   T7   T8   T9   T10  T11
BIT_CLK     ‾‾‾__‾‾‾__‾‾‾__‾‾‾__‾‾‾__‾‾‾__‾‾‾__‾‾‾__‾‾‾__‾‾‾__‾‾‾__‾‾‾__
TX_START    ‾‾‾‾‾_______________________________________________________
TX_DATA     <0x41>
TXD         ‾‾‾‾‾_____‾‾‾‾‾_________________________‾‾‾‾‾_____‾‾‾‾‾‾‾‾‾‾
FRAME             Start D0   D1   D2   D3   D4   D5   D6   D7   Stop
RX_VALID    _______________________________________________________‾‾‾‾‾
RX_DATA                                                            <0x41>
```

## Byte encoding

`0x41` in binary is `0100 0001`. UART sends the **LSB first**, so the bits appear on `TXD` in reverse order of how they are usually written:

| Bit position | D0 | D1 | D2 | D3 | D4 | D5 | D6 | D7 |
|---|---|---|---|---|---|---|---|---|
| Value | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 |
| Time slot | T2 | T3 | T4 | T5 | T6 | T7 | T8 | T9 |

Full serial sequence on `TXD`, in time order:

```
idle(1)  start(0)  D0=1  D1=0  D2=0  D3=0  D4=0  D5=0  D6=1  D7=0  stop(1)  idle(1)
```

## Cycle-by-cycle walkthrough

### T0: Host requests a transmit (idle line)

- `TXD` is **high**. The line is idle, so nothing is being sent.
- The host drives `TX_DATA = 0x41` and pulses `TX_START` **high** for this bit time.
- `BIT_CLK` rises at the start of T0 as in every other column.
- At the **end of T0** (the first dashed line and dot) the transmitter sees `TX_START` high and **latches `0x41`** into its shift register. This is the transfer on the host side: the byte has been accepted.
- `TX_START` goes low after this edge. `TX_DATA` is no longer needed.

### T1: Start bit

- `TXD` is driven **low**. This is the **start bit** (`FRAME` shows *Start*).
- The falling edge on `TXD` is the synchronisation event: the receiver detects it and begins its bit timing.
- The start bit is always 0, so the receiver can always tell a real frame apart from the idle line.

### T2: D0 (least significant bit)

- `TXD` goes **high**, so D0 = **1**.
- The transmitter shifts out the LSB of `0x41` first.

### T3: D1

- `TXD` goes **low**, so D1 = **0**.
- The shift register moves one position, exposing the next bit.

### T4: D2

- `TXD` stays **low**, so D2 = **0**.
- No transition occurs at the T3/T4 boundary because consecutive bits have the same value. The receiver only knows a new bit began because of its own timing.

### T5: D3

- `TXD` stays **low**, so D3 = **0**.

### T6: D4

- `TXD` stays **low**, so D4 = **0**.

### T7: D5

- `TXD` stays **low**, so D5 = **0**.
- At this point `TXD` has been low for six consecutive bit times (T3 to T7, plus the preceding bit-time boundary at T2/T3). This long run of zeros is why accurate baud timing matters: the receiver has no edges to re-align with.

### T8: D6

- `TXD` goes **high**, so D6 = **1**.
- This is the second `1` in `0x41` (bit 6, value `0x40`).

### T9: D7 (most significant bit)

- `TXD` goes **low**, so D7 = **0**.
- All 8 data bits have now been sent.

### T10: Stop bit

- `TXD` goes **high**. This is the **stop bit** (`FRAME` shows *Stop*).
- The stop bit returns the line to its idle level and guarantees a rising edge before the next start bit.
- On the receive side, the receiver samples the stop bit near its middle. If it reads `1`, the frame is valid. If it reads `0`, a **framing error** would be flagged.
- Once the stop bit has been checked, the receiver loads the assembled byte into its output register.

### T11: Receiver output valid (line idle)

- `TXD` remains **high** (idle). The transmitter is ready for another frame.
- `RX_VALID` goes **high** and `RX_DATA` shows **`0x41`**. The byte has been recovered correctly.
- At the **end of T11** (the second dashed line and dot) the host captures `RX_DATA`. This is the transfer on the receive side.
- `RX_VALID` drops after this edge, ready for the next byte.

## Summary table

| Time slot | `TXD` | `FRAME` field | Bit value | Notes |
|---|---|---|---|---|
| T0 | 1 | Idle | n/a | `TX_START` high, `TX_DATA = 0x41`, byte latched at end of slot (transfer 1) |
| T1 | 0 | Start | 0 | Falling edge synchronises the receiver |
| T2 | 1 | D0 | 1 | LSB first |
| T3 | 0 | D1 | 0 | |
| T4 | 0 | D2 | 0 | |
| T5 | 0 | D3 | 0 | |
| T6 | 0 | D4 | 0 | |
| T7 | 0 | D5 | 0 | |
| T8 | 1 | D6 | 1 | |
| T9 | 0 | D7 | 0 | MSB |
| T10 | 1 | Stop | 1 | Receiver checks stop bit, loads output register |
| T11 | 1 | Idle | n/a | `RX_VALID` high, `RX_DATA = 0x41`, captured at end of slot (transfer 2) |

## Receiver behaviour

The receiver runs a small state machine, summarised below.

1. **Wait for start.** Monitor `TXD` (as the receiver's `RXD`) while it is idle high. When it falls to 0, a candidate start bit has begun.
2. **Confirm start.** Wait half a bit time, then sample again. If the line is still low, the start bit is real. This rejects short glitches.
3. **Sample data.** Wait one full bit time between samples so each sample lands at the **middle of a bit**, the point farthest from either edge. Collect 8 samples, shifting each into a register LSB first.
4. **Check stop bit.** Sample one more bit time later. It must be `1`.
5. **Output.** Assert `RX_VALID` with the assembled byte on `RX_DATA`, then return to waiting for the next start bit.

Sampling at mid-bit gives the most tolerance to baud-rate mismatch between the two devices. Over a 10-bit frame, the cumulative timing error must stay under about half a bit time, which in practice allows roughly a 3 to 5 percent combined baud-rate error.

## Notes and simplifications

- **`BIT_CLK` is drawn at 1x.** Real UART receivers usually run an internal clock at **16x the baud rate** and count 16 ticks per bit. That makes the half-bit start check and mid-bit sampling easy. The diagram shows the baud-rate tick only, to keep the picture readable.
- **Latency to `RX_VALID` is simplified.** In real hardware the receiver output register updates a small number of internal clocks after the stop-bit sample. The diagram shows this as the next bit-time column.
- **Transmitter and receiver are shown on the same timeline.** The `TXD` wire is assumed to connect directly to the far-end `RXD` with negligible propagation delay.
- **Transfers.** The dashed lines mark the clock edges where a handshake completes, matching the convention in the AXI read-channel waveform.

## Extending the diagram

Variations that follow the same layout:

- **Parity bit (8E1 / 8O1).** Insert one extra slot between D7 and Stop. For `0x41`, which has two `1` bits, even parity is `0` and odd parity is `1`.
- **Two stop bits (8N2).** Hold `TXD` high for two bit times after D7.
- **Back-to-back frames.** Start the next frame immediately after the stop bit. The idle gap can be zero, but `TXD` must still be high for the stop bit duration.
- **16x oversampling view.** Replace `BIT_CLK` with a 16x clock and add a row marking the sample points at tick 8 of each bit.
- **Hardware flow control.** Add `RTS` and `CTS` rows. The transmitter only starts a frame when `CTS` is asserted, which parallels the `VALID`/`READY` handshake in AXI.
