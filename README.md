# Ball-and-Beam Stabilization & PID Control Design

MATLAB/Simulink project on modeling, stabilizing, and tuning a PID controller for a **ball-and-beam system**. The plant (motor + gearbox + beam + ball) is linearized about the equilibrium point, an inner stabilizing loop is designed for the beam angle, and an outer PID loop controls the ball's position. Several classical and optimization-based PID tuning methods (Ziegler–Nichols, Cohen–Coon, CHR, Åström–Hägglund, refined ZN, optimal/opt-app, and a custom "WJC" tuning rule) are implemented and compared, both in simulation and on hardware.

## Project Structure

```
.
├── MATLAB/
│   ├── CODES/        # MATLAB functions/scripts: modeling, PID tuning laws, model-order reduction
│   ├── SIMULINK/      # Simulink models (.slx / .mdl) of the plant, stabilizer, and control loops
│   └── SISOTOOL/      # Saved SISO Tool sessions (.mat) for stabilizer/PID tuning
├── MEDIA/
│   ├── PICTURES/       # Simulink diagrams, scope plots, response curves, setup photos
│   │   └── steps/        # Step-by-step build/setup photos
│   └── VIDEOS/         # Video of the system running on real hardware
└── REPORT/
    ├── REPORT_PDF.pdf    # Full project report (Persian)
    └── REPORT_WORD.docx  # Same report, Word format
```

## Overview

- **Plant**: DC motor + gearbox driving a beam, with a ball rolling on the beam (classic ball-and-beam problem). The motor/gearbox and ball/beam dynamics are combined into an approximate plant transfer function and linearized about the equilibrium (beam angle) point.
- **Inner loop — stabilization**: Because the raw system is open-loop unstable/marginally stable with poles at the origin, an inner loop with lead/lag compensation (`C` in `all_codes.m`) is designed first to stabilize the beam angle dynamics and improve the stability margin, using SISO Tool (see `MATLAB/SISOTOOL`).
- **Outer loop — PID position control**: Once the inner loop is stabilized, a PID controller regulates the ball's position on the beam. The reduced/approximated plant is characterized by FOPDT-type parameters `[K, L, T, N]` (gain, delay, time constant, derivative filter coefficient), extracted via `get_fod.m`, and several tuning rules are applied to that model.
- **Comparison**: The closed-loop step responses of all tuning methods are simulated together (`all_codes.m`) and compared against hardware step responses (see `MEDIA/PICTURES` and `MEDIA/VIDEOS`).

## MATLAB Code (`MATLAB/CODES`)

**Plant modeling & model reduction**
- `get_fod.m` — Extracts an FOPDT (First-Order-Plus-Dead-Time) approximation `K, L, T` from a higher-order transfer function (frequency-response or derivative-matching method).
- `get_ipd.m` — Extracts an IPDT (Integrator-Plus-Dead-Time) approximation `Kv, L` for integrating plants.
- `tf_derv.m` — Helper: computes the derivative of a transfer function (used by `get_fod.m`).
- `opt_app.m` / `opt_fun.m` — Optimal low-order transfer-function approximation of a higher-order/plant model via H2-norm minimization (`fminsearch`).

**PID / controller tuning rules** (each takes model parameters and returns a controller `Gc`, gains `Kp, Ti, Td`, and, where relevant, a derivative filter `H`):
- `ziegler_nic.m` — Classical Ziegler–Nichols tuning (open-loop reaction curve or closed-loop ultimate-gain forms).
- `rziegler_nic.m` — Refined/modified Ziegler–Nichols tuning.
- `chr_pid.m` — Chien–Hrones–Reswick (CHR) tuning, 0% and 20% overshoot variants.
- `cohen_pid.m` — Cohen–Coon tuning (set-point and disturbance-rejection variants).
- `astrom_hagglund.m` — Åström–Hägglund tuning (time-domain and frequency-response/relay-based variants).
- `opt_pid.m` — Table-based "optimal" PID tuning (Zhuang/Atherton-style lookup tables).
- `wjcpid.m` — Custom PID tuning rule used for comparison.
- `foipdt.m`, `ipdtctrl.m`, `ufopdt.m` — PD/PID tuning formulas for FOIPDT, IPDT, and unstable FOPDT plant models respectively.

**GUI / optimization tooling**
- `optimpid.m` — GUIDE-based MATLAB GUI ("Optimal PID Controller Design") for interactively tuning a PID controller against a Simulink model using various optimization algorithms (fminsearch/fmincon, GA, PSO, simulated annealing, pattern search).
- `optpidfun_0.m` — Auto-generated objective function (created by `optimpid.m`) that simulates `pidctrl_model` for given `Kp, Ki, Kd` and returns the performance index.

**Example / driver scripts**
- `EX1.m` – `EX4.m` — Standalone examples: FOPDT/IPDT approximation of test plants, low-order approximation with time delay, and PID tuning applied to an example plant.
- `all_codes.m` — Main driver script: builds the ball-and-beam plant, designs the inner stabilizer, applies every PID tuning method above to the stabilized plant, and plots all closed-loop step responses on one figure for comparison.

## Simulink Models (`MATLAB/SIMULINK`)

- `Final_3.slx`, `Final_4.slx`, `Final_7.slx` — Iterations of the full closed-loop ball-and-beam model (inner stabilization loop + outer PID position loop).
- `real_model_siso.slx`, `real_model_dodegree.slx`, `real_model_project (1).slx` — Models configured for running/validating against the real hardware setup.
- `shabih_model.slx`, `shabih_model_dodegree.slx` — Simulation-only ("shabih" = simulated/emulated) versions of the model for testing without hardware.
- `mod4.mdl` — Additional/legacy model in the older `.mdl` format.

## SISO Tool Sessions (`MATLAB/SISOTOOL`)

- `Stabilizer.mat` — Saved SISO Tool session for designing the inner stabilizing compensator.
- `PID_Tun.mat`, `PID_Tun (1).mat` — Saved SISO Tool sessions for PID tuning of the outer loop.

## Media (`MEDIA`)

- **PICTURES/** — Simulink block diagrams, scope traces (with and without output saturation), root-locus/response comparisons on the real system (`3_rzn_on_real.png`, `ise_4_on_real.png`), controller-effort and ISE comparison plots (`ce_4.png`, `optpid_4.png`), and reference screenshots.
- **PICTURES/steps/** — Photographed steps of the hardware build/setup process.
- **VIDEOS/** — Recording of the ball-and-beam system running under closed-loop control on real hardware.

## Report (`REPORT`)

Full write-up (in Persian) covering the initial assumptions, plant derivation (motor/gearbox + ball-and-beam dynamics), the two-stage design approach (inner-loop stabilization, then outer-loop PID tuning), the seven project "requirements" addressed, and results — available as `REPORT_PDF.pdf` and `REPORT_WORD.docx`.

## Requirements

- MATLAB with the **Control System Toolbox** (transfer functions, `feedback`, `margin`, `step`, SISO Tool).
- **Simulink** to open and run the `.slx` / `.mdl` models.
- Optional, for `optimpid.m`'s extra optimization algorithms: Global Optimization Toolbox (`ga`, `patternsearch`, `simulannealbnd`), or third-party GAOT / PSOt toolboxes.
- `get_ipd.m` uses the **Symbolic Math Toolbox** (`syms`, `ilaplace`).

## Usage

1. Open MATLAB and add `MATLAB/CODES` to the path.
2. Run `all_codes.m` to build the plant, design the stabilizer, apply all PID tuning methods, and plot the comparative closed-loop step responses.
3. Open any model in `MATLAB/SIMULINK` (e.g. `Final_7.slx`) in Simulink to inspect or simulate the full block-diagram implementation.
4. Open `MATLAB/SISOTOOL/Stabilizer.mat` or `PID_Tun.mat` in the SISO Tool (`sisotool`) to reproduce or adjust the compensator/PID designs interactively.
5. See `REPORT/` for the full derivation, methodology, and results, and `MEDIA/` for supporting figures and hardware footage.
