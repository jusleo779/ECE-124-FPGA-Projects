# Lab 4: Sequential Logic & State Machines — Robotic Arm Controller (RAC)

## What I Built
A Robotic Arm Controller (RAC) that positions a simulated robotic arm in two dimensions (X/Y) and operates an extender/grappler mechanism. Target X and Y coordinates are set with switches and captured into holding registers on a push-button press. Once released, the arm moves automatically toward the target, updating position on a dual seven-segment display. A separate extender mechanism can extend/retract in four steps, and a grappler can open/close only once the extender is fully extended. The whole system is coordinated by three interacting finite state machines: XY Motion Control, Extender Control, and Grappler Control, with interlocks preventing the arm from moving while the extender is out.

### Demo

<video src="videos/rac_demo.mp4" controls width="480"></video>

*Demo of the working Robotic Arm Controller on the LogicalStep board.*

> **Note:** GitHub only renders this player inline if `rac_demo.mp4` is committed to `videos/` in this same repo. If you view the raw README elsewhere, [download the video directly](videos/rac_demo.mp4) instead.

## What I Learned

### Metastability and Why It Matters
Every register has a setup time (data must be stable before the clock edge) and a hold time (data must stay stable after it). Violating either can put the register output into an undefined, oscillating state called metastability, which can then propagate garbage values into downstream logic. This was the first lab where timing, not just logic correctness, became something I had to actively design around rather than assume away.

### Synchronous Design as the Default Discipline
The fix for metastability at the architecture level is to keep all sequential logic on a single common global clock rather than mixing clock domains. For external asynchronous inputs (like push buttons), the standard technique is a two-stage flip-flop synchronizer: the first stage may go metastable, but it has a full clock cycle to settle before the second stage samples it, so the metastability never reaches the rest of the design. This gave me a concrete, reusable pattern for interfacing any asynchronous signal to a synchronous system, not just something I'll only use in this course.

### Moore vs Mealy State Machines
Learned the structural and behavioural difference between the two: a Moore machine's outputs depend only on the current state and update strictly on the clock edge, while a Mealy machine's outputs depend on current state *and* current inputs, which lets outputs react immediately (zero-delay) but exposes them to asynchronous glitches on the inputs. Mealy machines can often be built with fewer states than an equivalent Moore design, but at the cost of that input-glitch sensitivity. Choosing between them per-block (I used Moore-style, register/transition/decoder-separated designs for all three RAC controllers) was a real design tradeoff, not just a syntax choice.

### Three-Section State Machine Architecture
Every state machine I built was split into three `always` blocks with strict rules: a Register section (sequential, `posedge clock`, holds `current_state`), a Transition section (pure combinational, `always @(*)`, computes `next_state` only, no other outputs allowed to come from it, and every `if` needed an `else` to avoid inferring a latch), and a Decoder section (pure combinational, generates the actual outputs from `current_state`, with a `default` case mandatory). Keeping these cleanly separated made debugging dramatically easier than mixing transition logic and output logic in one block, because I could reason about "what state am I in" and "what does that state do" independently.

### Interlocking Between Concurrent State Machines
This was the most difficult and most valuable part of the lab. The three controllers (XY Motion, Extender, Grappler) aren't independent; they have to enforce mutual exclusion and sequencing dependencies on each other in real time:
- The arm cannot move in X or Y while the extender is out. If motion is requested anyway, a System Fault Error must be raised and latched, and it can only be cleared by fully retracting the extender.
- The grappler is only allowed to change state when the extender is in the fully-extended position, and an enable signal has to be gated by another state machine's status output, not just its own logic.
- Only one function (Motion, Extender, or Grappler) can be active at a time, and each state machine has to correctly sense a button *press* as a distinct event from the button *release*, since the required action happens on release, not on press.

Getting this right meant treating the interlock signals (`extended`, `extender_enbl`, `grappler_enbl`, `posc_err`) as first-class parts of the state machine design, not afterthoughts wired in once each block "worked" in isolation. My first attempt at the extend/motion interlock had a gap: I had the fault condition checked only at the moment `motion` was first asserted, which meant if the extender state changed mid-motion, the interlock didn't catch it. I had to move the check into the state machine's steady-state condition instead of a one-time edge check. That bug taught me that interlocking logic has to be evaluated continuously against the current state, not just sampled once at a transition, or you get race conditions between state machines that only show up under specific timing.

### Bidirectional Shift Register for Position Feedback
The extender's physical position (retracted → extending → fully extended) was tracked with a bidirectional shift register producing a one-hot-style pattern on the LEDs (`0000` → `1000` → `1100` → `1110` → `1111`), driven by direction and enable signals from the Extender state machine. This was a clean example of separating "what state am I commanding" (state machine) from "what is the physical mechanism's actual position" (shift register), a pattern that maps directly onto real actuator control.

### Staged, Bottom-Up Bring-Up Strategy
Rather than building and simulating the whole RAC at once, the lab (and I) worked bottom-up: first verify the clock/reset/synchronizer infrastructure alone with all buttons off, then bring up the Grappler state machine in isolation (forcing its enable signal on), then the Extender state machine (again forcing its enable), and only then the full XY Motion controller with the real interlocks wired in. This staged approach caught bugs early, in a smaller and easier-to-reason-about scope, instead of debugging three interacting state machines simultaneously from a single large failing simulation.

### Key Takeaway
Lab 4 was less about learning new Verilog syntax and more about learning how independent pieces of sequential logic have to be made to cooperate safely, through synchronization to a single clock, through clean state-machine structure, and through interlocking logic that has to be continuously enforced rather than checked once. The interlock bugs were the hardest to find precisely because each individual state machine simulated correctly on its own; the failures only appeared once machines interacted under real timing, which is a much closer approximation to how bugs show up in production hardware than anything in the earlier labs.

## Tools & Environment

| Tool | Purpose |
|---|---|
| Intel Quartus Prime v18.1 | Synthesis, simulation, compilation, FPGA programming |
| University of Waterloo LogicalStep Board | Altera MAX10 FPGA development platform |
| Verilog HDL | Hardware description language for all designs |
| Quartus Waveform Simulator (VWF) | Functional simulation and verification |
| USB Blaster (JTAG) | Programming interface to the FPGA |
