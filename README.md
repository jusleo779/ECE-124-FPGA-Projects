# ECE 124 Digital Circuits and Systems (Verilog)

**University of Waterloo | Altera MAX10 FPGA | Intel Quartus Prime**

This repo contains all lab projects from ECE 124, an introductory course in digital logic design and implementation using Verilog and the University of Waterloo LogicalStep FPGA development board. Each lab was designed, simulated, and verified in hardware on the Altera MAX10 FPGA.

> Each lab below has its own folder with a full README, including schematics, simulation waveforms, and demo images/videos of the design running on hardware. The summaries here are short on purpose. **Click into a lab folder for the full writeup and media.**

---

## [Lab 1 — Design Entry Methods: Schematic & Verilog](Lab1/README.md)
Implemented XOR, OR, NAND, and AND logic using both schematic entry and Verilog HDL, verified through functional simulation before FPGA programming. Learned FPGA architecture basics (LUTs, configuration memory), why HDL scales better than schematics, active-low vs active-high signal handling, and a polarity-control block using XOR gates as programmable inverters.

**Key takeaway:** simulate before you program, it's the workflow, not an optional step.

## [Lab 2 — Combinational Logic: Simple ALU](Lab2/README.md)
Built a 4-bit ALU (bitwise logic + addition) using dataflow and structural Verilog. Designed a MUX, a hex-to-seven-segment decoder, a ripple-carry adder from individual full adders, and a 4-function logic processor, then integrated them into one system. Learned the difference between module declaration and instantiation, signal concatenation, and how structural Verilog mirrors real engineering practice: build from verified, reusable blocks.

**Key takeaway:** complex systems are composed from smaller verified pieces.

## [Lab 3 — Behavioural Verilog: Home Energy Monitor](Lab3/README.md)
Built a home energy monitor with a magnitude comparator, an up/down counter acting as an HVAC unit, and safety interlocks (no HVAC if a door/window is open). Introduced behavioural Verilog (`always` blocks), the difference between combinational and sequential `always` blocks, blocking vs non-blocking assignments, and how to avoid inferred latches. Spent significant time debugging `ifdef` simulation-only signal wiring and an on-chip self-test block.

**Key takeaway:** simulation infrastructure has its own bugs, separate from the design logic itself.

## [Lab 4 — Sequential Logic & State Machines: Robotic Arm Controller (RAC)](Lab4/README.md)
Built a Robotic Arm Controller with three coordinated finite state machines (XY Motion, Extender, Grappler) controlling 2D position, an extend/retract mechanism, and a grappler, all synchronized to a single global clock with proper input synchronizers. Learned about metastability and why synchronous design with two-stage synchronizers prevents it, the Moore vs Mealy tradeoff, and the three-section (Register / Transition / Decoder) state machine structure. The core challenge was **interlocking between the three state machines** — enforcing that the arm can't move while the extender is out, that the grappler can only operate when fully extended, and that a fault condition has to be checked continuously rather than at a single point in time, since interlock bugs only surfaced when the machines interacted under real timing, not in isolated simulation.

**Key takeaway:** the hardest bugs weren't in individual logic blocks, they were in how independently correct state machines interact with each other in time.

---

## Tools & Environment

| Tool | Purpose |
|---|---|
| Intel Quartus Prime v18.1 | Synthesis, simulation, compilation, FPGA programming |
| University of Waterloo LogicalStep Board | Altera MAX10 FPGA development platform |
| Verilog HDL | Hardware description language for all designs |
| Quartus Waveform Simulator (VWF) | Functional simulation and verification |
| USB Blaster (JTAG) | Programming interface to the FPGA |
