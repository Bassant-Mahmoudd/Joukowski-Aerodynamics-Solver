# Flow Simulation over a Joukowski Airfoil

## Overview
This repository contains a modular MATLAB simulation of inviscid, incompressible flow over a cambered Joukowski airfoil (3% camber, 6% thickness). The project utilizes potential flow theory and conformal mapping to transform the flow around a rotating cylinder to the airfoil plane. 

This simulation evaluates surface pressure distribution, velocity distribution, and the flow field over a range of angles of attack $\alpha \in [-5^{\circ}, 15^{\circ}]$. Key results quantify the linear relationship between lift ($C_l$) and $\alpha$, demonstrate the effect of camber on the zero-lift angle, and visualize the migration of the stagnation point to the lower surface at high incidence.

## Mathematical Formulation
The flow is modeled using the conformal mapping function:
$$Z_{1} = Z + \frac{b^{2}}{Z}$$
where $b$ is a transformation constant related to the chord length. To generate the camber and thickness, the generating cylinder of radius $a$ is displaced by a complex shift $Z_0$.

The complex potential $W(Z)$ is formed from uniform flow, a doublet, and a vortex to satisfy Kutta condition at the trailing edge:
$$W(Z) = V_{\infty} \left( (Z-Z_{0})e^{-i\alpha} + \frac{a^{2}e^{i\alpha}}{Z-Z_{0}} \right) + \frac{i\Gamma}{2\pi}\ln(Z-Z_{0})$$

## Project Architecture
The codebase is structured to separate mathematical modeling from visualization logic:
* `main.m`: The executive script defining geometry parameters and AoA ranges.
* `src/joukowski_transform.m`: Discretizes geometry and applies conformal mapping.
* `src/solve_potential_flow.m`: Computes complex potential, velocity, and surface pressure coefficients.
* `src/compute_aerodynamics.m`: Integrates pressure distributions for moment coefficients and locates stagnation points.
* `src/plot_flow_dashboard.m`: Generates the detailed flow field and pressure contour dashboards for specific angles of attack.
* `src/plot_aerodynamic_curves.m`: Plots the final lift, moment, and stagnation trajectory curves.

## How to Run
1. Clone the repository to your local machine.
2. Open MATLAB and navigate to the project root directory.
3. Run the `main.m` script. 
4. The simulation will automatically compute the flow fields and export high-resolution dashboard `.png` files to your current directory.

## Results Preview
<img width="3111" height="1459" alt="stag" src="https://github.com/user-attachments/assets/b56a3197-9995-44c6-80c8-8f4e200384db" />
<img width="3115" height="1906" alt="dash5" src="https://github.com/user-attachments/assets/9239b129-0a5e-4f84-89cd-13c0d68ac08e" />
<img width="3149" height="1906" alt="dash0" src="https://github.com/user-attachments/assets/27fa78ad-35cd-4ce1-b035-35826c8d50cd" />
<img width="3167" height="1906" alt="dash-5" src="https://github.com/user-attachments/assets/6da22580-e711-4813-863f-23d2dd8cf711" />
<img width="3119" height="1202" alt="transformation_process" src="https://github.com/user-attachments/assets/1c73f5b9-549b-4d19-9f2d-ff518ce1df54" />

