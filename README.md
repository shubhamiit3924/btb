# Branch Target Buffer (BTB) Design and Formal Verification

This project implements a **direct-mapped Branch Target Buffer (BTB)** for the processor fetch stage to improve branch prediction performance. The design features **optimized Boolean tag-matching logic**, a **finite state machine (FSM)** for control, and **formal verification using NuSMV** to mathematically prove correctness, safety, and liveness properties.

---

## 📌 Project Overview

Branches introduce control hazards in pipelined processors, causing pipeline stalls and performance degradation. A Branch Target Buffer (BTB) enables **early branch target prediction** by storing previously encountered branch addresses and their targets.

This project focuses on:
- Efficient BTB microarchitecture design  
- Optimized hit/miss detection logic  
- FSM-based operational control  
- Formal verification using temporal logic  

---

## 🧠 Key Concepts Used

- Processor fetch-stage microarchitecture  
- Direct-mapped cache design  
- Boolean logic optimization  
- Finite State Machines (FSM)  
- Formal verification (CTL & LTL)  

---

## 🏗️ BTB Architecture

- **Organization**: Direct-mapped BTB with 16 entries  
- **Lookup latency**: Single-cycle  
- **Entry format**:
  - Valid bit (1 bit)
  - Tag field (26 bits)
  - Target address (32 bits)

### Address Decomposition
- **Index**: PC[5:2] (4 bits → 16 entries)
- **Tag**: PC[31:6] (26 bits)

---

## ⚙️ Optimized Tag-Matching Logic

Tag comparison is implemented using a **bitwise XNOR followed by AND reduction**:
tag_match = &(~(stored_tag ^ tag_in))


Hit condition:
pred_valid = fetch_valid & stored_valid & tag_match


This logic ensures **single-cycle hit detection** with minimal hardware overhead.

---

## 🔄 Operational FSM

The BTB is modeled as a **three-state FSM**:

- **Idle** – Ready to accept lookup or update requests  
- **Lookup** – Performs tag comparison and prediction generation  
- **Update** – Writes new branch information after resolution  

FSM guarantees:
- Atomic updates  
- No deadlocks or unreachable states  
- Bounded completion time  

---

## 🧪 Implementation

- **HDL**: Verilog  
- **Design Style**: RTL, synchronous  
- **Reset**: Synchronous clear of all valid bits  
- **Testbench**:
  - Covers hit, miss, conflict, overwrite, and reset scenarios  
  - Fully self-checking waveform-based verification  

---

## ✅ Formal Verification (NuSMV)

Formal verification was performed using **NuSMV model checking**.

### Verified Properties

- **Liveness (CTL)**  


AG ((lookup & miss) -> AF update)

*Every branch miss eventually updates the BTB.*

- **State Reachability (CTL)**  
- All FSM states are reachable  

- **Safety & Sequencing (LTL)**  
- Update always returns to Idle  
- BTB entries become visible after update  

Fairness constraints were applied to ensure realistic execution paths.

---

## 📊 Results

- Correct single-cycle prediction delivery  
- Guaranteed BTB update on every branch miss  
- No unreachable or deadlocked FSM states  
- All CTL and LTL properties successfully verified  

---

## 🛠️ Tools & Technologies

- **RTL Design**: Verilog  
- **Simulation**: Vivado / ModelSim  
- **Formal Verification**: NuSMV  
- **Domain**: CPU Microarchitecture, RTL Verification  

---



## 📈 Key Takeaways

- Demonstrates strong understanding of **branch prediction hardware**
- Combines **RTL design with formal verification**
- Applies Boolean optimization for performance-critical logic
- Suitable for real-world processor pipelines

---

## 👤 Author

**Shubham Meena**  
B.Tech, Microelectronics and VLSI Engineering  
Indian Institute of Technology Mandi  


