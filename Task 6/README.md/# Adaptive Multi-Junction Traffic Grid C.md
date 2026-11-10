# Adaptive Multi-Junction Traffic Grid Controller (AMTGC)

## 1. Project Overview

The Adaptive Multi-Junction Traffic Grid Controller (AMTGC) is a Verilog-based traffic signal control system designed to manage multiple road junctions efficiently and safely.

The project includes normal traffic signal operation, pedestrian request handling, emergency vehicle priority, and adaptive green signal timing based on traffic density.

## 2. Project Features

- Parameterized traffic signal controller.
- Two-junction system integration.
- Pedestrian request arbitration with fair servicing.
- Emergency override with all-red safety control.
- Adaptive green timing based on traffic density.
- Self-checking testbenches and simulation-based verification.
- Directed and randomized verification scenarios.

## 3. Tools and Technologies

- Hardware Description Language: Verilog HDL
- Simulation Tool: ModelSim Intel FPGA Edition 2020.1
- Editor: Visual Studio Code
- Version Control: Git and GitHub

## 4. Repository Structure

```text
AMTGC_Task6_Documentation/
│
├── rtl/
│   ├── amtgc_top.v
│   ├── generic_timer.v
│   ├── junction_controller.v
│   └── ped_arbiter.v
│
├── tb/
│   ├── Task2/
│   ├── Task3/
│   ├── Task4/
│   └── Task5/
│
├── docs/
├── reports/
├── screenshots/
├── sim/
│   ├── waveforms/
│   └── logs/
│
├── demo/
└── README.md
```

## 5. Task Description

- **Task 1:** Initial project report and requirements.
- **Task 2:** Parameterized RTL design and module-level simulation.
- **Task 3:** Integration of two junction controllers and pedestrian arbitration.
- **Task 4:** Adaptive traffic-density-based green timing.
- **Task 5:** Full system verification using a unified self-checking testbench.
- **Task 6:** Documentation, repository organization, and final project delivery.

## 6. Simulation Instructions

Open ModelSim and change the working directory to:

```tcl
cd C:/AMTGC_Task6_Documentation
```

Create the simulation library:

```tcl
vlib work
```

Compile the Task 5 RTL and testbench:

```tcl
vlog rtl/generic_timer.v rtl/ped_arbiter.v rtl/junction_controller.v rtl/amtgc_top.v tb/Task5/tb_amtgc_system.v
```

Load the testbench:

```tcl
vsim work.tb_amtgc_system
```

Run the simulation:

```tcl
run -all
```

The expected successful verification result is:

```text
AMTGC TASK 5: PASS
```

## 7. Verification Summary

The Task 5 full verification included:

- Normal traffic operation.
- Adaptive traffic density testing.
- Pedestrian fairness testing.
- Emergency override testing.
- Repeated emergency testing.
- Active reset testing.
- Randomized traffic testing for 500 cycles.

**Recorded verification results:**
- Safety checks: 2820
- Errors: 0
- Pedestrian services: 120
- Junction A services: 60
- Junction B services: 60
- Final result: PASS

## 8. Documentation and Evidence

The repository contains project RTL files, testbenches, simulation waveforms, screenshots, reports, and demonstration recordings.

Architecture diagrams, FSM diagrams, and the final technical report are included in the documentation deliverables.

## 9. Future Improvements

- Support for additional junctions.
- More advanced traffic-density detection.
- Real-time sensor integration.
- Hardware implementation on an FPGA board.
- Improved traffic optimization algorithms.

## 10. Conclusion

The AMTGC project demonstrates the design, integration, and verification of an adaptive multi-junction traffic control system using Verilog HDL. The system provides pedestrian fairness, emergency priority, adaptive timing, and simulation-based safety verification.
