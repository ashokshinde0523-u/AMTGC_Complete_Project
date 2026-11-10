# Adaptive Multi-Junction Traffic Grid Controller (AMTGC)
## Technical Project Report

### 1. Introduction

The Adaptive Multi-Junction Traffic Grid Controller (AMTGC) is a digital traffic management system designed using Verilog HDL. The project focuses on controlling multiple road junctions while supporting pedestrian requests, emergency vehicle priority, and adaptive traffic signal timing.

### 2. Project Objectives

- Design a modular traffic signal controller.
- Control two interconnected road junctions.
- Implement pedestrian request arbitration.
- Provide emergency override functionality.
- Adjust green signal duration according to traffic density.
- Verify system operation using ModelSim simulation.

### 3. System Architecture

The system consists of four main RTL modules:

1. **amtgc_top.v:** Integrates the two junction controllers and coordinates system inputs and outputs.
2. **junction_controller.v:** Implements the traffic signal control FSM and adaptive timing.
3. **generic_timer.v:** Provides timer functionality for signal transitions.
4. **ped_arbiter.v:** Manages pedestrian requests and provides fair arbitration.

### 4. Design Decisions and Trade-offs

**Modular design:** Separate modules make the system easier to understand, test, maintain, and extend.

**Finite State Machine:** The junction controller uses eight states to represent traffic signal and pedestrian phases.

**Parameterized timing:** Parameters allow timing values to be configured without redesigning the complete controller.

**Pedestrian arbitration:** A shared arbiter manages requests from both junctions and supports fair servicing.

**Adaptive timing:** Traffic density is used to adjust green duration within configured minimum and maximum limits.

### 5. Adaptive Timing Results

The verified Task 5 configuration produced the following green-time values:

| Traffic Density | Green Duration |
|---:|---:|
| 0 | 10 cycles |
| 1 | 13 cycles |
| 3 | 19 cycles |
| 5 | 25 cycles |
| 7 | 30 cycles |

### 6. Verification Methodology

A unified self-checking testbench named `tb_amtgc_system.v` was used for full-system verification.

The verification included:

- Reset operation.
- Normal traffic operation.
- Adaptive traffic-density testing.
- Pedestrian fairness testing.
- Emergency override testing.
- Repeated emergency testing.
- Active reset testing.
- Randomized traffic testing for 500 cycles.

### 7. Verification Results

The recorded Task 5 simulation summary was:

| Verification Metric | Result |
|---|---:|
| Safety checks | 2820 |
| Errors | 0 |
| Total pedestrian services | 120 |
| Junction A services | 60 |
| Junction B services | 60 |
| Randomized test duration | 500 cycles |
| Final verification result | PASS |

The simulation reported:

**AMTGC TASK 5: PASS**

### 8. Debugging and Issues Encountered

During project development, simulation setup and file organization issues were encountered.

Examples included:

- Correcting the ModelSim working directory when compiling project files.
- Resolving testbench file-location issues.
- Checking testbench compilation and simulation