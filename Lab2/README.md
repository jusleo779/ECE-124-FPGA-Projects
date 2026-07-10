# Lab 2: Combinational Logic — Simple ALU (Dataflow & Structural Verilog)

## What I Built
A simple Arithmetic Logic Unit (ALU) that performs bitwise logic operations and 4-bit addition on two hex operands entered via switches. Results are displayed on the dual seven-segment displays and LED outputs, with push buttons used to select the operation.

## What I Learned

### Structural vs Dataflow Verilog
Lab 1 used dataflow Verilog logic expressed as equations with operators. Lab 2 introduced structural Verilog, where you instantiate previously built modules as components inside a higher-level design. The top-level file became a wiring diagram in code: no logic operators, just module instantiations connected by named signals. This mirrors how real engineering teams build complex systems from verified, reusable blocks.

### Module Declaration vs Module Instantiation
Understood the difference between declaring a module (defining what it does and what its ports are) and instantiating it (using it inside another design). Port names in instantiations must match the declaration exactly, case-sensitively. Getting this wrong is one of the most common Verilog bugs, and catching it taught me to read port lists carefully.

### Multiplexers
Designed a 4-bit 2-to-1 multiplexer from scratch using the conditional operator. A MUX is a fundamental routing block; it selects which of two inputs reaches an output based on a select signal. In the final ALU, MUXes were used to switch the seven-segment displays between showing raw operands and showing the computed sum.

### Hex-to-Seven-Segment Decoder
Built a decoder that takes a 4-bit hex value (0–F) and outputs a 7-bit pattern to drive the correct LED segments on a physical display. Used Verilog's conditional (ternary) operator chained sequentially for all 16 hex values. Writing this in schematic form would have required dozens of logic gates in Verilog; it was 16 lines. This was a concrete demonstration of why HDL exists.

### 4-Bit Ripple Carry Adder
Designed a full adder for a single bit, then instantiated four of them in a chain to build a 4-bit adder. Each full adder takes two input bits and a carry-in, and produces a sum bit and a carry-out. The carry-out of each bit feeds into the carry-in of the next. This chain is called a ripple carry adder. Building it from first principles made the binary addition algorithm tangible rather than abstract.

### Signal Concatenation
Used Verilog's concatenation operator `{, }` to combine the 1-bit carry-out from the adder with three padding zeros to form a 4-bit value that could be fed into the seven-segment decoder. Small technique, but it comes up constantly when connecting signals of different widths.

### Logic Processor
Built a 4-bit logic processor using a chained conditional structure to select between AND, OR, XOR, and XNOR operations based on a 2-bit select input from the push buttons. This directly mirrors what the ALU function unit inside a CPU does: select an operation and execute it on operands.

![Functional simulation waveform of the logic processor](images/logic_processor_waveform.png)

*Figure 1: Functional simulation of the logic processor. `select_n` cycles through `11`, `10`, `01`, `00` to step through XNOR, XOR, OR, and AND, with `logic_out` verified against `logic_in1`/`logic_in0` for each case.*

### System Integration
The final ALU brought together every sub-component built in the lab into one verified, working system: operand input via switches, operation selection via push buttons, arithmetic via the adder, logic operations via the logic processor, result routing via multiplexers, and output via seven-segment displays and LEDs. Debugging integration, finding where signals were misconnected across module boundaries, was as valuable as building each component.

### Key Takeaway
Complex digital systems are built by composing verified smaller blocks. Structural Verilog enforces this discipline by making the hierarchy explicit in code. Writing a working ALU from individual full adders and multiplexers made the internals of computer arithmetic concrete in a way that reading about it never could.

## Tools & Environment

| Tool | Purpose |
|---|---|
| Intel Quartus Prime v18.1 | Synthesis, simulation, compilation, FPGA programming |
| University of Waterloo LogicalStep Board | Altera MAX10 FPGA development platform |
| Verilog HDL | Hardware description language for all designs |
| Quartus Waveform Simulator (VWF) | Functional simulation and verification |
| USB Blaster (JTAG) | Programming interface to the FPGA |
