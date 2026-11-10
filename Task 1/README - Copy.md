# Adaptive Traffic Controller — System Architecture Planning

This repository contains the pre-RTL planning deliverables for a coordinated two-junction traffic controller.

## Files
- `Traffic_Controller_Architecture_Report.pdf` — submission-ready report.
- `Traffic_Controller_Architecture_Report.docx` — editable Word report.
- `traffic_controller_architecture.png` — top-level architecture diagram.

## Scope
The report defines two local junction controllers, a green-wave coordinator, a shared round-robin pedestrian arbiter, a global emergency manager, a single-clock/synchronous-reset strategy, module interfaces, safety invariants, and 24 simulation test scenarios.

## Important design assumptions
The 50 MHz clock and cycle counts are illustrative parameters. The emergency response target is three cycles from the specified synchronous capture event. It must not be interpreted as a physical pin-to-light guarantee without hardware timing and safety analysis.

## Status
Planning only. No Verilog RTL or simulation results are included, by design.
