## Lab 3 — Behavioural Verilog: Home Energy Monitor

### What I Built
A complete home energy monitoring system running on the FPGA. The system takes a desired temperature and a vacation temperature as switch inputs, uses a 4-bit magnitude comparator to decide whether the home needs heating or cooling, drives an HVAC unit (an up/down counter) to converge on the target temperature, and outputs status indicators across 8 LEDs and the dual seven-segment displays. An on-chip tester block verifies the comparator is working correctly without needing an external simulation environment.

### What I Learned

**Behavioural Verilog — the third coding style**
Labs 1 and 2 covered dataflow (logic equations) and structural (module instantiation). Lab 3 introduced behavioural Verilog, where logic is described algorithmically inside `always` procedural blocks using `if-else`, `case`, and other sequential constructs. The compiler synthesizes all possible outcomes of those statements into hardware; the code reads like software but compiles into logic gates.

**Concurrent vs Sequential Statement Domains**
There are two domains in which Verilog operates, and keeping them straight is crucial. Concurrent statements (`assign`) evaluate all simultaneously. Sequential statements inside an `always` block execute in order, and the compiler resolves them into synthesized logic. Knowing which domain a statement lives in is fundamental to writing Verilog that synthesizes into what you actually intend.

**The `always` Block and Sensitivity Lists**
The `always @(sensitivity list)` construct defines what triggers a block to re-evaluate. For combinational logic, every input signal the block depends on must appear in the sensitivity list; missing one creates a latch. For sequential logic (flip-flops), the clock edge is specified using `posedge`. Getting the sensitivity list wrong is one of the most common and subtle Verilog bugs.

**Inferred Latches and How to Avoid Them**
When an `if` statement inside an `always` block doesn't cover all possible input conditions, specifically when there's no `else` clause, the compiler infers a latch to hold the output value for uncovered cases. This is almost always unintentional and creates timing problems in hardware. The fix is to ensure every signal driven by the block is assigned a value in every branch of every conditional.

**Blocking vs Non-Blocking Assignments**
Combinational logic inside `always` blocks uses blocking assignments (`=`), which execute sequentially and update immediately. Sequential logic uses non-blocking assignments (`<=`), which all evaluate using the current signal values and update simultaneously at the end of the clock edge. Mixing these up produces hardware that behaves differently from what the code implies.

**4-Bit Magnitude Comparator — Built from First Principles**
Designed a comparator from a single-bit building block (`Compx1`) that produces three mutually exclusive outputs: A>B, A=B, A<B. Then instantiated four of them structurally in `Compx4` and combined their results using Boolean logic that checks bits from most significant to least significant, if the top bits differ, the lower bits don't matter. This is the same priority-based comparison logic used in real ALU designs.

**Sequential Logic — Up/Down Counter as HVAC Emulator**
Built the HVAC block as a clocked up/down counter using behavioural Verilog. On each rising clock edge, it increments or decrements a temperature register based on `increase` and `decrease` inputs, subject to boundary conditions (can't go below 0 or above F). I designed logic where the state persists across clock cycles, the key conceptual shift from combinational to sequential design.

**Clock Divider and Parameter Passing**
The HVAC counter runs off a 2 Hz divided clock for hardware testing (so the temperature changes are visible to the eye) and a 50 MHz clock for simulation (so simulations run in a reasonable time). The clock selection is controlled by a parameter (`hvac_sim`) passed down from the top level. This is a real technique used in hardware designs to make the same block testable at different speeds without changing its logic.

**`ifdef` Compiler Directives — Debugging the Hard Way**
This was the most time-consuming part of the lab. The FPGA has no spare pins, so simulation-only ports that expose internal signals for waveform visibility have to be wrapped in `ifdef`/`ifndef`/`endif` directives and excluded from the hardware compile. The lab manual description of where exactly to place these directives was vague enough that I initially commented out the wrong sections, which caused a chain of compile errors that weren't immediately obvious in origin. Once I learned what needed to be inside the `ifdef` block versus what had to stay commented, the errors cleared. After that, the simulation was still missing expected waveforms, which turned out to be signals I hadn't yet wired into the simulation ports. Adding those signals and reconnecting them correctly got the waveforms showing as expected. The debugging sequence I used was: compile error, fix placement, re-simulate, find missing waveforms, add signals, re-simulate. It was more iterative than any previous lab and taught me that simulation infrastructure has its own bugs separate from the design logic.

**On-Chip Tester — Testing Without External Equipment**
The on-chip tester block runs autonomously in hardware, driving known inputs to the comparator, checking outputs against expected results, and lighting an LED on pass or fail. Getting the tester to pass required fixing a subtle issue: I had initially commented out part of the simulation-related code, thinking it was only needed for the waveform simulation, but it was also feeding signals that the tester depended on. Once I understood the boundary between what was simulation-only and what was shared logic, the tester passed cleanly. This is a pattern used in real production environments where functional testing needs to be fast and self-contained.

**System-Level Design**
The final Energy Monitor pulls every component together: the comparator decides heating vs cooling direction, the HVAC counter converges on the target temperature, the MUX switches between desired and vacation temperature setpoints, the tester validates the comparator in the background, and the Energy Monitor Control block orchestrates all the control signals with safety interlocks (no HVAC if a door or window is open). Designing the control logic to handle all these interacting conditions without conflicts was the most demanding integration challenge of the course so far.

**Key Takeaway**
Behavioural Verilog unlocks more ways to describe hardware, but it comes with more ways to write code that looks correct and synthesizes into something wrong. The biggest lesson from this lab wasn't from the design itself; it was from the simulation infrastructure around it. `ifdef` directives, simulation-only ports, and the boundary between hardware and testbench code are not intuitive, and the only way to really learn them is to break them and trace back through the errors. Simulation setup is part of the engineering work, not a formality you do after the design is done.


---

## Tools & Environment

| Tool | Purpose |
|---|---|
| Intel Quartus Prime v18.1 | Synthesis, simulation, compilation, FPGA programming |
| University of Waterloo LogicalStep Board | Altera MAX10 FPGA development platform |
| Verilog HDL | Hardware description language for all designs |
| Quartus Waveform Simulator (VWF) | Functional simulation and verification |
| USB Blaster (JTAG) | Programming interface to the FPGA |
