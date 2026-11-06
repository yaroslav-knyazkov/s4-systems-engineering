# Project Mechatronic Design 2026 — Group 18

Mechatronic design project (Systems Engineering, Group 18, tutor Bernard Hoppenreijs).

## Design problem

A precision, single-degree-of-freedom mechanism for a laser weeding system: a stage that
rotates a mirror about a pivot point to steer a laser onto weeds. The mechanism must track a
prescribed motion profile accurately (±2 mm / ±0.931 mrad) with a return time of ≤30 ms, over a
±1° (±17.5 mrad) motion amplitude.

Hardware: a magnetic encoder (RLS LM10, 8192 counts/2 mm), a voice coil motor actuator
(AVM30-15, 4.63 N continuous force) driven by a custom PWM voltage amplifier, and a custom
control electronics box built on a C2000 LAUNCHXL-F28379D microcontroller.

The full report (design problem, controller design, mechanical design, simulation, hardware
identification, and experimental results) is in
[`project-mechatronics-group-18.pdf`](./project-mechatronics-group-18.pdf).

## Repository structure

| Path | Contents |
|---|---|
| `simulink-model/` | Simulink models and MATLAB scripts for the nominal plant model, system identification, and simulation-based controller analysis. |
| `simulink-hardware/` | Simulink models and MATLAB scripts for hardware identification, static gain measurement, and running the controller on the physical C2000-based setup. |
| `stiffness/` | MATLAB scripts for the stiffness/stress analysis of the leaf-spring flexure and ranking of candidate designs by natural frequency (`wn-ranking.csv`). |
| `project-mechatronics-group-18.pdf` | Full project report. |

## Running the MATLAB/Simulink files

Requires MATLAB with Simulink, Control System Toolbox, and (for the hardware folder) Embedded
Coder with the C2000 target support package, since those models were built and flashed against a
LAUNCHXL-F28379D.

The `.m` and `.slx` files keep their original underscore-style names because several of them are
invoked by bare script name (e.g. `system_init;`, `hardware_init;`) or by model name
(e.g. `sim('system_ident_model')`), and Embedded Coder uses the model name to generate C
identifiers for the target build — renaming them would break those references.

Generated build output (Embedded Coder `*_ert_rtw/` folders, `slprj/` caches, compiler
intermediates such as `.obj`/`.out`/`.hex`/`.map`, and Simulink autosave/cache files) is not
tracked; see `.gitignore`. Re-run the models to regenerate it locally.
