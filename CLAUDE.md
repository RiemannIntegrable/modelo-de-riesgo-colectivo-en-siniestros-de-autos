# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an academic project implementing collective risk models for analyzing automobile insurance portfolios, developed in R for Universidad Nacional de Colombia. The project includes comprehensive data processing, exploratory analysis, IPC inflation adjustments, daily exposure calculations, and actuarial risk modeling with LaTeX documentation.

## Environment Setup

The project uses a conda environment defined in `environment.yml` with R 4.2.3 and comprehensive statistical packages including:
- Core R packages: tidyverse, dplyr, ggplot2, data.table
- Statistical modeling: forecast, caret, lme4, survival
- Actuarial/Financial: quantmod, vars, tseries
- Testing framework: testthat
- Excel support: readxl
- Jupyter notebook support for R

To set up the environment:
```bash
conda env create -f environment.yml
conda activate Renv
```

## Code Architecture

### Directory Structure
- `data/`: Raw and processed insurance data
  - `input/`: Original datasets and reference files
    - `Grupo_P11.xlsx`, `Siniestros_Hist.xlsx`: Main policy and claims data
    - `Historico_IPC_Factor_Ajuste.xlsx`: IPC adjustment factors
    - `factores_ipc.csv`, `IPC_Update.csv`: IPC data in CSV format
    - `polizas.csv`, `polizas_v2.txt`: Processed policy data
    - HTML files: Actuarial formula references and examples
  - `processed/`: Daily data by coverage type (8 CSV files)
    - Policy files: `polizas_ppd.csv`, `polizas_pth.csv`, `polizas_pph.csv`, `polizas_rc.csv`
    - Claims files: `siniestros_ppd.csv`, `siniestros_pth.csv`, `siniestros_pph.csv`, `siniestros_rc.csv`
  - `output/`: Analysis results
- `src/`: Source code
  - `data/`: Core data processing functions
    - `polizas_diarias.R`: Daily exposure calculations by coverage
    - `ajuste_prima_ipc.R`: IPC inflation adjustment for premiums
  - `models/`: Statistical models
  - `test/`: Unit tests using testthat framework
    - `test_polizas_diarias.R`: Tests for daily calculations
    - `test_ajuste_prima_ipc.R`: Tests for IPC adjustments
  - `utils/`: Utility functions
- `notebooks/`: Jupyter notebooks for analysis
  - `Polizas.ipynb`: Policy data exploration and processing
  - `Exploracion_Siniestros.ipynb`: Claims data exploration
  - `Siniestros_New.ipynb`: Updated claims analysis
  - `modelacion.ipynb`: Statistical modeling and parameter estimation
  - `exploracion.ipynb`: General exploratory analysis
- `docs/`: LaTeX documentation
  - `config/`: LaTeX configuration (packages, commands, styling)
  - `content/`: Document sections (.tex files)
  - `main.tex`: Main document file

### Key Functions

**IPC Adjustment (`src/data/ajuste_prima_ipc.R`)**:
- Function `ajuste_prima_ipc(polizas)`: Adjusts premiums using Colombian IPC factors
- Input: Dataframe with `Fecha_inicio` and `Prima` columns
- Output: Same dataframe with added `Prima_ajustada` column
- Handles Spanish month names to numeric conversion
- Uses merge operation for efficient factor matching
- Purpose: Adjust all premiums to January 2019 values

**Daily Exposure (`src/data/polizas_diarias.R`)**:
- Function `polizas_diarias(polizas)`: Calculates daily policy exposure by coverage type
- Input: Dataframe with policy data and coverage indicators
- Output: List of 4 dataframes (PPD, PTH, PPH, RC), each with 365 rows (2018 daily data)
- Each output dataframe contains:
  - `Fecha`: Date (2018-01-01 to 2018-12-31)
  - `Numero_polizas`: Number of active policies with that coverage
  - `Suma_primas`: Sum of premiums for active policies
  - `Exposicion`: Sum of remaining policy durations / 365

**Coverage Types**:
- **PPD**: Perdida_parcial_danos (Partial loss due to damage)
- **PTH**: Perdida_total_hurto (Total loss due to theft) 
- **PPH**: Perdida_parcial_hurto (Partial loss due to theft)
- **RC**: Responsabilidad_civil (Civil liability)

**Data Processing Pipeline**:
1. Raw data import from Excel files
2. Data cleaning and column standardization
3. IPC inflation adjustment using `ajuste_prima_ipc()`
4. Daily exposure calculation using `polizas_diarias()`
5. Coverage-specific data export to `data/processed/`
6. Statistical parameter estimation
7. Model validation and testing

## Development Workflow

### Running Tests
```bash
# From src/test/ directory
conda activate Renv
Rscript test_polizas_diarias.R    # Test daily calculations
Rscript test_ajuste_prima_ipc.R   # Test IPC adjustments
```

### Data Processing Workflow
```r
# 1. Load and clean raw data
source("src/data/ajuste_prima_ipc.R")
source("src/data/polizas_diarias.R")

# 2. Apply IPC adjustment
polizas_ajustadas <- ajuste_prima_ipc(polizas_raw)

# 3. Calculate daily exposures
resultados_diarios <- polizas_diarias(polizas_ajustadas)

# 4. Access coverage-specific data
ppd_data <- resultados_diarios$PPD
pth_data <- resultados_diarios$PTH
pph_data <- resultados_diarios$PPH
rc_data <- resultados_diarios$RC
```

### Expected Data Structure
**Input for `polizas_diarias()`**:
- `Fecha_inicio`, `Fecha_fin`: Policy start/end dates (Date class)
- `Prima_ajustada`: IPC-adjusted premiums (numeric)
- Coverage indicators (binary 0/1): `Perdida_parcial_danos`, `Perdida_total_hurto`, `Perdida_parcial_hurto`, `Responsabilidad_civil`

**Output structure** (each coverage dataframe):
- `Fecha`: Daily dates for 2018 (365 rows)
- `Numero_polizas`: Count of active policies (integer)
- `Suma_primas`: Sum of premiums (numeric)
- `Exposicion`: Policy exposure in years (numeric)

### Jupyter Notebooks
Start Jupyter with R kernel:
```bash
jupyter lab
```

**Notebook workflow**:
1. `Polizas.ipynb`: Data loading, cleaning, IPC adjustment
2. `exploracion.ipynb`: General exploratory data analysis
3. `Exploracion_Siniestros.ipynb`: Claims data exploration
4. `modelacion.ipynb`: Parameter estimation and model fitting

### LaTeX Documentation
Compile the main document:
```bash
cd docs/
pdflatex main.tex
pdflatex main.tex  # Run twice for cross-references
```

## Data Conventions

**Date Handling**: All dates use R Date class, formatted as YYYY-MM-DD. Analysis focuses on 2018 calendar year.

**Coverage Indicators**: Binary columns (0/1) indicate which coverages apply to each policy.

**Monetary Values**: All monetary values are adjusted to January 2019 pesos using IPC factors.

**IPC Factors**: Colombian Consumer Price Index factors for inflation adjustment, sourced from DANE.

**File Naming Convention**: 
- Processed files: `{data_type}_{coverage}.csv`
- Functions: `{purpose}_{data_type}.R`
- Tests: `test_{function_name}.R`

**Merge Operations**: When joining claims and policy data, use inner join by date:
```r
merged <- merge(polizas_data, siniestros_data, by.x = "Fecha", by.y = "Fecha_siniestro")
```

## Testing Framework

Comprehensive unit testing using R's `testthat` package:

**Test Coverage**:
- Function input/output structure validation
- Data processing correctness verification
- Edge case handling (empty datasets, invalid dates)
- Coverage calculations accuracy
- IPC factor application verification

**Test Execution**:
```bash
# Individual test files
Rscript src/test/test_polizas_diarias.R
Rscript src/test/test_ajuste_prima_ipc.R

# Or source in R session
source("src/test/test_polizas_diarias.R")
```

**Test Structure**: Each test file includes multiple test cases covering normal operation, edge cases, and error conditions.

## Statistical Modeling

**Parameter Estimation**: The project implements collective risk model parameter estimation:
- **Frequency (λ)**: Expected number of claims per coverage type
- **Severity**: Distribution fitting for claim amounts
- **Exposure**: Policy-years of exposure by coverage

**Model Implementation**: Ready for Compound Poisson and other collective risk models using the processed daily exposure data.

**Validation**: Statistical tests and model diagnostics implemented in modeling notebooks.