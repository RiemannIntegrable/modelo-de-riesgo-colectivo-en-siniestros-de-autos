# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an academic project implementing collective risk models for analyzing automobile insurance portfolios, developed in R for Universidad Nacional de Colombia. The project includes data processing, exploratory analysis, and actuarial risk modeling with LaTeX documentation.

## Environment Setup

The project uses a conda environment defined in `environment.yml` with R 4.2.3 and comprehensive statistical packages including:
- Core R packages: tidyverse, dplyr, ggplot2, data.table
- Statistical modeling: forecast, caret, lme4, survival
- Actuarial/Financial: quantmod, vars, tseries
- Jupyter notebook support for R

To set up the environment:
```bash
conda env create -f environment.yml
conda activate Renv
```

## Code Architecture

### Directory Structure
- `data/`: Raw and processed insurance data
  - `input/`: Original datasets (Excel files with claims and policy data)
  - `processed/`: Cleaned data files by coverage type (PPD, PTH, PPH, RC)
  - `output/`: Analysis results
- `src/`: Source code
  - `data/`: Data processing functions (R scripts)
  - `models/`: Statistical models
  - `test/`: Unit tests using testthat framework
  - `utils/`: Utility functions
- `notebooks/`: Jupyter notebooks for data exploration and analysis
- `docs/`: LaTeX documentation
  - `config/`: LaTeX configuration (packages, commands, styling)
  - `content/`: Document sections (.tex files)
  - `main.tex`: Main document file

### Key Components

**Data Processing (`src/data/polizas_diarias.R`)**:
- Function `polizas_diarias()`: Calculates daily policy exposure by coverage type
- Processes four insurance coverage types: PPD (partial damage), PTH (total theft), PPH (partial theft), RC (civil liability)
- Computes daily metrics: number of policies, premium sums, exposure calculations

**Coverage Types**:
- **PPD**: Perdida_parcial_danos (Partial loss due to damage)
- **PTH**: Perdida_total_hurto (Total loss due to theft) 
- **PPH**: Perdida_parcial_hurto (Partial loss due to theft)
- **RC**: Responsabilidad_civil (Civil liability)

**Data Flow**:
1. Raw data in Excel format (`Grupo_P11.xlsx`, `Siniestros_Hist.xlsx`)
2. Processing scripts clean and transform data
3. Processed data saved by coverage type
4. Analysis performed in Jupyter notebooks
5. Results compiled in LaTeX documentation

## Development Workflow

### Running Tests
```bash
# From src/test/ directory
Rscript test_polizas_diarias.R
Rscript test_ajuste_prima_ipc.R
```

### Data Processing
Key data processing functions are in `src/data/`. The main function `polizas_diarias()` expects a dataframe with columns:
- `Fecha_inicio`, `Fecha_fin`: Policy start/end dates
- `Prima_ajustada`: Inflation-adjusted premiums
- Coverage indicator columns (binary): `Perdida_parcial_danos`, `Perdida_total_hurto`, `Perdida_parcial_hurto`, `Responsabilidad_civil`

### Jupyter Notebooks
Start Jupyter with R kernel:
```bash
jupyter lab
```

Main analysis notebooks:
- `Exploracion_Siniestros.ipynb`: Claims data exploration
- `Polizas.ipynb`: Policy data analysis
- `Siniestros_New.ipynb`: Updated claims analysis

### LaTeX Documentation
Compile the main document:
```bash
cd docs/
pdflatex main.tex
pdflatex main.tex  # Run twice for cross-references
```

The document structure uses modular .tex files:
- Configuration in `config/` (packages, commands, styling)
- Content sections in `content/` directory
- Custom styling includes Universidad Nacional de Colombia branding

## Data Conventions

**Date Handling**: All dates use R Date class, formatted as YYYY-MM-DD for 2018 analysis period.

**Coverage Indicators**: Binary columns (0/1) indicate which coverages apply to each policy.

**Monetary Values**: Values are inflation-adjusted using IPC (Colombian Consumer Price Index) factors.

**File Naming**: Processed files follow pattern `{data_type}_{coverage}.csv` (e.g., `polizas_ppd.csv`, `Siniestros_rc.csv`).

## Testing Framework

Uses R's `testthat` package for unit testing. Tests verify:
- Function input/output structure
- Data processing correctness
- Edge case handling (empty datasets)
- Coverage calculations

Run individual test files directly with Rscript or source them in R sessions.