# A Comparative Study of Exact Algorithm and Cuckoo Search for the Capacitated Facility Location Problem

**University of Ruhuna | Department of Mathematics | April 2026**

**Project Type:** Undergraduate Group Project  
**Programming Language:** MATLAB  
**Research Area:** Operations Research and Mathematical Optimization

## Project Overview

This project presents a comparative study of two optimization approaches for solving the **Capacitated Facility Location Problem (CFLP)**:

1. **Exact Algorithm** – Integer Linear Programming
2. **Cuckoo Search Algorithm** – Metaheuristic Optimization

The study evaluates both approaches based on solution quality, computational time, convergence behaviour, and scalability across different problem sizes.

## Research Objectives

- Formulate the Capacitated Facility Location Problem mathematically.
- Implement an Exact Algorithm using Integer Linear Programming.
- Implement the Cuckoo Search metaheuristic algorithm.
- Compare the performance of both algorithms.
- Analyze computational efficiency and scalability.

## Methodology

The Capacitated Facility Location Problem involves selecting facilities and allocating customers while minimizing total operating and transportation costs.

The mathematical model considers:

- Facility opening costs
- Transportation costs
- Facility capacity constraints
- Customer demand requirements
- Customer-to-facility assignments

Both algorithms were implemented using **MATLAB**.

Six randomly generated problem instances were evaluated, ranging from 5 facilities and 20 customers to 100 facilities and 1,000 customers.

The Exact Algorithm was implemented using MATLAB's `intlinprog` solver, while Cuckoo Search was implemented as a population-based metaheuristic.

## Key Findings

- The Exact Algorithm produced better solution costs in the reported experiments.
- Cuckoo Search showed a reported solution-cost gap of approximately 72.25% for the smallest instance and 20.93% for the largest instance.
- The Exact Algorithm reached its 300-second time limit on larger problem instances.
- Cuckoo Search required substantial computational time for large-scale problems.
- The study highlights trade-offs between solution quality, computational efficiency, and scalability.

**Note:** For instances where the exact solver reached its time limit, the reported cost differences should not be interpreted as certified optimality gaps.

## Tools and Technologies

- MATLAB
- Integer Linear Programming
- MATLAB Optimization Toolbox (`intlinprog`)
- Cuckoo Search Algorithm
- Computational Optimization
- Data Visualization

## Repository Contents

- **Research Report (PDF):** Complete research methodology, experimental results, and conclusions.
- **MATLAB Code Archive (ZIP):** MATLAB implementations and supporting scripts for the optimization experiments.
- **README.md:** Project documentation.

## Group Members

1. H. K. T. Handagala
2. H. B. G. Jayasinghe
3. A. K. S. G. S. B. Wasalaarachchi
4. I. W. D. S. Haripriya
5. K. M. S. Wasana

## Academic Information

**Department:** Department of Mathematics  
**Faculty:** Faculty of Science  
**University:** University of Ruhuna, Sri Lanka  
**Year:** 2026

## Conclusion

This research demonstrates the strengths and limitations of Exact Optimization and Cuckoo Search for the Capacitated Facility Location Problem. The findings provide insights into solution accuracy, computational requirements, and the challenges of solving large-scale optimization problems.

---

*This repository is maintained for academic, research, and educational purposes.*
