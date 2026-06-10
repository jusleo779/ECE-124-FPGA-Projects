# ECE 124 Digital Circuits and Systems (Verilog)
**University of Waterloo | Altera MAX10 FPGA | Intel Quartus Prime**

This repo contains all lab projects from ECE 124, an introductory course in digital logic design and implementation using Verilog and the University of Waterloo LogicalStep FPGA development board. Each lab was designed, simulated, and verified in hardware on the Altera MAX10 FPGA.

---

## Lab 1 Design Entry Methods: Schematic & Verilog

### What I Built
A gate-level logic circuit implementing XOR, OR, NAND, and AND functions, entered in two ways: schematic and Verilog, and verified through functional simulation before being flashed onto the FPGA.

### What I Learned

**FPGA Architecture**
Understood how FPGAs differ from microprocessors at a fundamental level. An FPGA's logic is defined by configuration memory cells that control lookup tables (LUTs) and interconnects. A download file reconfigures the hardware itself, not just the software running on fixed hardware. This distinction shaped how I think about hardware design as a discipline separate from software.

**Two Design Entry Methods**
Worked with both schematic-based block diagram entry and Verilog HDL entry to implement the same gate functions. Seeing the same logic expressed in two completely different ways one visual, one textual, made it clear why HDL is the industry standard: it scales, schematics don't.

**Functional Simulation**
Before touching the hardware, I used Quartus Prime's simulation waveform tool to apply stimulus signals and verify gate truth tables visually. This was my first real introduction to the test-before-deploy discipline: catch logic errors in simulation, not after you've programmed the chip.

**Active-High vs Active-Low Signals**
The push-button inputs on the LogicalStep board are active-low, meaning a pressed button reads as logic 0. I had to insert inverters between the physical pins and the logic block to convert the signal polarity. This was a practical lesson that hardware signals don't always match the logical convention you design around, and that interface awareness is part of hardware engineering.

**Signal Polarity Control**
Extended the design with a polarity control block that lets a switch flip all output active states between active-high and active-low with a single input. This reinforced how XOR gates can be used as programmable inverters, a pattern that appears constantly in real digital design.

**Key Takeaway**
Simulation is not optional; it's the workflow. Design, synthesize, simulate, verify against truth tables, then program. Skipping simulation means debugging in hardware, which is significantly harder.

---

## Lab 2 Combinational Logic: Simple ALU (Dataflow & Structural Verilog)

### What I Built
A simple Arithmetic Logic Unit (ALU) that performs bitwise logic operations and 4-bit addition on two hex operands entered via switches. Results are displayed on the dual seven-segment displays and LED outputs, with push buttons used to select the operation.

### What I Learned

**Structural vs Dataflow Verilog**
Lab 1 used dataflow Verilog logic expressed as equations with operators. Lab 2 introduced structural Verilog, where you instantiate previously built modules as components inside a higher-level design. The top-level file became a wiring diagram in code: no logic operators, just module instantiations connected by named signals. This mirrors how real engineering teams build complex systems from verified, reusable blocks.

**Module Declaration vs Module Instantiation**
Understood the difference between declaring a module (defining what it does and what its ports are) and instantiating it (using it inside another design). Port names in instantiations must match the declaration exactly, case-sensitively. Getting this wrong is one of the most common Verilog bugs, and catching it taught me to read port lists carefully.

**Multiplexers**
Designed a 4-bit 2-to-1 multiplexer from scratch using the conditional operator. A MUX is a fundamental routing block; it selects which of two inputs reaches an output based on a select signal. In the final ALU, MUXes were used to switch the seven-segment displays between showing raw operands and showing the computed sum.

**Hex-to-Seven-Segment Decoder**
Built a decoder that takes a 4-bit hex value (0–F) and outputs a 7-bit pattern to drive the correct LED segments on a physical display. Used Verilog's conditional (ternary) operator chained sequentially for all 16 hex values. Writing this in schematic form would have required dozens of logic gates in Verilog; it was 16 lines. This was a concrete demonstration of why HDL exists.

**4-Bit Ripple Carry Adder**
Designed a full adder for a single bit, then instantiated four of them in a chain to build a 4-bit adder. Each full adder takes two input bits and a carry-in, and produces a sum bit and a carry-out. The carry-out of each bit feeds into the carry-in of the next. This chain is called a ripple carry adder. Building it from first principles made the binary addition algorithm tangible rather than abstract.

**Signal Concatenation**
Used Verilog's concatenation operator `{, }` to combine the 1-bit carry-out from the adder with three padding zeros to form a 4-bit value that could be fed into the seven-segment decoder. Small technique, but it comes up constantly when connecting signals of different widths.

**Logic Processor**
Built a 4-bit logic processor using a chained conditional structure to select between AND, OR, XOR, and XNOR operations based on a 2-bit select input from the push buttons. This directly mirrors what the ALU function unit inside a CPU does: select an operation and execute it on operands.

**System Integration**
The final ALU brought together every sub-component built in the lab into one verified, working system: operand input via switches, operation selection via push buttons, arithmetic via the adder, logic operations via the logic processor, result routing via multiplexers, and output via seven-segment displays and LEDs. Debugging integration, finding where signals were misconnected across module boundaries, was as valuable as building each component.

**Key Takeaway**
Complex digital systems are built by composing verified smaller blocks. Structural Verilog enforces this discipline by making the hierarchy explicit in code. Writing a working ALU from individual full adders and multiplexers made the internals of computer arithmetic concrete in a way that reading about it never could.

---

## Lab 3 — Behavioural Verilog: Home Energy Monitor

### What I Built
A complete home energy monitoring system running on the FPGA. The system takes a desired temperature and a vacation temperature as switch inputs, uses a 4-bit magnitude comparator to decide whether the home needs heating or cooling, drives an HVAC unit (an up/down counter) to converge on the target temperature, and outputs status indicators across 8 LEDs and the dual seven-segment displays. An on-chip tester block verifies the comparator is working correctly without needing an external simulation environment.

### What I Learned

**Behavioural Verilog — the third coding style**
Labs 1 and 2 covered dataflow (logic equations) and structural (module instantiation). Lab 3 introduced behavioural Verilog, where logic is described algorithmically inside `always` procedural blocks using `if-else`, `case`, and other sequential constructs. The compiler synthesizes all possible outcomes of those statements into hardware — the code reads like software but compiles into logic gates.

**Concurrent vs Sequential Statement Domains**
There are two domains Verilog operates in, and keeping them straight is critical. Concurrent statements (`assign`) evaluates all simultaneously. Sequential statements inside an `always` block execute in order, and the compiler resolves them into synthesized logic. Knowing which domain a statement lives in is fundamental to writing Verilog that synthesizes into what you actually intend.

**The `always` Block and Sensitivity Lists**
The `always @(sensitivity list)` construct defines what triggers a block to re-evaluate. For combinational logic, every input signal the block depends on must appear in the sensitivity list, missing one creates a latch. For sequential logic (flip-flops), the clock edge goes in the list using `posedge`. Getting the sensitivity list wrong is one of the most common and subtle Verilog bugs.

**Inferred Latches and How to Avoid Them**
When an `if` statement inside an `always` block doesn't cover all possible input conditions, specifically when there's no `else` clause, the compiler infers a latch to hold the output value for uncovered cases. This is almost always unintentional and creates timing problems in hardware. The fix is to ensure every signal driven by the block is assigned a value in every branch of every conditional.

**Blocking vs Non-Blocking Assignments**
Combinational logic inside `always` blocks uses blocking assignments (`=`), which execute sequentially and update immediately. Sequential logic uses non-blocking assignments (`<=`), which all evaluate using the current signal values and update simultaneously at the end of the clock edge. Mixing these up produces hardware that behaves differently from what the code implies.

**4-Bit Magnitude Comparator - Built from First Principles**
Designed a comparator from a single-bit building block (`Compx1`) that produces three mutually exclusive outputs: A>B, A=B, A<B. Then instantiated four of them structurally in `Compx4` and combined their results using Boolean logic that checks bits from most significant to least significant, if the top bits differ, the lower bits don't matter. This is the same priority-based comparison logic used in real ALU designs.

**Sequential Logic - Up/Down Counter as HVAC Emulator**
Built the HVAC block as a clocked up/down counter using behavioural Verilog. On each rising clock edge it increments or decrements a temperature register based on `increase` and `decrease` inputs, subject to boundary conditions (can't go below 0 or above F). I designed logic where state persists across clock cycles, the key conceptual shift from combinational to sequential design.

**Clock Divider and Parameter Passing**
The HVAC counter runs off a 2 Hz divided clock for hardware testing (so the temperature changes are visible to the eye) and a 50 MHz clock for simulation (so simulations run in a reasonable time). The clock selection is controlled by a parameter (`hvac_sim`) passed down from the top level. This is a real technique used in hardware designs to make the same block testable at different speeds without changing its logic.

**`ifdef` Compiler Directives - Debugging the Hard Way**
This was the most time-consuming part of the lab. The FPGA has no spare pins, so simulation-only ports that expose internal signals for waveform visibility have to be wrapped in `ifdef`/`ifndef`/`endif` directives and excluded from the hardware compile. The lab manual description of where exactly to place these directives was vague enough that I initially commented out the wrong sections, which caused a chain of compile errors that weren't immediately obvious in origin. Once I learned what needed to be inside the `ifdef` block versus what had to stay commented, the errors cleared. After that, the simulation was still missing expected waveforms, which turned out to be signals I hadn't yet wired into the simulation ports. Adding those signals and reconnecting them correctly got the waveforms showing as expected. The debugging sequence I used was compile error, fix placement, re-simulate, find missing waveforms, add signals, re-simulate. It was more iterative than any previous lab and taught me that simulation infrastructure has its own bugs separate from the design logic.

**On-Chip Tester - Testing Without External Equipment**
The on-chip tester block runs autonomously in hardware, driving known inputs to the comparator, checking outputs against expected results, and lighting an LED on pass or fail. Getting the tester to pass required fixing a subtle issue: I had initially commented out part of the simulation-related code thinking it was only needed for the waveform simulation, but it was also feeding signals that the tester depended on. Once I understood the boundary between what was simulation-only and what was shared logic, the tester passed cleanly. This is a pattern used in real production environments where functional testing needs to be fast and self-contained.

**System-Level Design**
The final Energy Monitor pulls every component together: the comparator decides heating vs cooling direction, the HVAC counter converges on the target temperature, the MUX switches between desired and vacation temperature setpoints, the tester validates the comparator in the background, and the Energy Monitor Control block orchestrates all the control signals with safety interlocks (no HVAC if a door or window is open). Designing the control logic to handle all these interacting conditions without conflicts was the most demanding integration challenge of the course so far.

**Key Takeaway**
Behavioural Verilog unlocks more ways to describe hardware, but it comes with more ways to write code that looks correct and synthesizes into something wrong. The biggest lesson from this lab wasn't from the design itself, it was from the simulation infrastructure around it. `ifdef` directives, simulation-only ports, and the boundary between hardware and testbench code are not intuitive, and the only way to really learn them is to break them and trace back through the errors. Simulation setup is part of the engineering work, not a formality you do after the design is done.

---

## Tools & Environment

| Tool | Purpose |
|---|---|
| Intel Quartus Prime v18.1 | Synthesis, simulation, compilation, FPGA programming |
| University of Waterloo LogicalStep Board | Altera MAX10 FPGA development platform |
| Verilog HDL | Hardware description language for all designs |
| Quartus Waveform Simulator (VWF) | Functional simulation and verification |
| USB Blaster (JTAG) | Programming interface to the FPGA |
