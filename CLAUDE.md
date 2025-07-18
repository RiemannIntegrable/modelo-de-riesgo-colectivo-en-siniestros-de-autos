# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an academic project implementing collective risk models for analyzing automobile insurance portfolios, developed in R for Universidad Nacional de Colombia. The project includes comprehensive data processing, exploratory analysis, IPC inflation adjustments, daily exposure calculations, frequency modeling, severity modeling, and complete collective risk model implementation using both FFT and Panjer algorithms. The final implementation includes convolution of all coverage distributions and dual-scale visualization with comprehensive validation and LaTeX documentation.

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
  - `output/`: Analysis results and collective risk model outputs
    - Individual aggregate loss distributions: `perdidas_agregadas_{coverage}.csv`
    - Total aggregate loss distribution: `perdidas_agregadas_total.csv`
    - Severity distributions: `distribucion_severidad_{coverage}.csv`
    - Validation data: `validacion_{coverage}.csv`
    - Graphics: PNG files for distributions and validation plots
    - Dual-scale visualizations (50M detail, 500M complete range)
- `src/`: Source code
  - `data/`: Core data processing functions
    - `polizas_diarias.R`: Daily exposure calculations by coverage
    - `ajuste_prima_ipc.R`: IPC inflation adjustment for premiums
  - `models/`: Statistical models
  - `test/`: Unit tests using testthat framework
    - `test_polizas_diarias.R`: Tests for daily calculations
    - `test_ajuste_prima_ipc.R`: Tests for IPC adjustments
  - `utils/`: Utility functions and algorithms
    - `Panjer.R`: Panjer recursive algorithm for collective risk models
    - `FFT_RiesgoColectivo.R`: Fast Fourier Transform implementation for collective risk
- `notebooks/`: Jupyter notebooks for analysis
  - `Polizas.ipynb`: Policy data exploration and processing
  - `Exploracion_Siniestros.ipynb`: Claims data exploration
  - `Siniestros_New.ipynb`: Updated claims analysis
  - `modelacion.ipynb`: Statistical modeling and parameter estimation
  - `exploracion.ipynb`: General exploratory analysis
  - `limpieza_de_polizas.ipynb`: Policy data cleaning and processing
  - `limpieza_de_siniestros.ipynb`: Claims data cleaning and validation
  - `limpieza_de_vigentes.ipynb`: Active policy data processing
  - `modelo_de_frecuencia.ipynb`: Frequency distribution modeling (Poisson, Negative Binomial)
  - `modelo_de_severidad.ipynb`: Severity distribution modeling (Gamma, Lognormal)
  - `panjer.ipynb`: Panjer algorithm implementation and validation
  - `fft.ipynb`: FFT algorithm implementation and validation
  - `convolucion_final.ipynb`: Final convolution of all coverage distributions
- `docs/`: LaTeX documentation
  - `config/`: LaTeX configuration (packages, commands, styling)
  - `content/`: Document sections (.tex files)
  - `main.tex`: Main document file
- `images/`: Generated graphics and visualizations
  - Distribution plots for each coverage type
  - Fitted distribution graphics (lognormal adjustments)
  - Aggregate loss distribution visualizations
  - Validation plots comparing FFT vs Panjer results
  - Dual-scale plots (50M detail view, 500M complete range)

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

**Panjer Algorithm (`src/utils/Panjer.R`)**:
- Function `Panjer(prob_severidad, dist_frecuencia, parametros_frecuencia, x_scale, convolve, maxit, echo)`
- Implements recursive algorithm using `actuar::aggregateDist`
- Supports Poisson and Negative Binomial frequency distributions
- Extended range calculation up to 600M with redistribution of probability mass
- Advanced error handling and convergence optimization
- Returns CDF function and discrete probability extraction utility

**FFT Algorithm (`src/utils/FFT_RiesgoColectivo.R`)**:
- Function `FFT_RiesgoColectivo(prob_severidad, dist_frecuencia, parametros_frecuencia, x_scale, n_points, echo)`
- Implements collective risk model using Fast Fourier Transform
- Correctly implements compound distribution theory: φ_S(t) = φ_N(φ_X(t))
- Uses n-fold convolution via FFT for computational efficiency O(n log n)
- Supports up to 500M calculation range with proper probability normalization
- Validates against Panjer algorithm with high correlation (>0.99)

**Data Processing Pipeline**:
1. Raw data import from Excel files
2. Data cleaning and column standardization
3. IPC inflation adjustment using `ajuste_prima_ipc()`
4. Daily exposure calculation using `polizas_diarias()`
5. Coverage-specific data export to `data/processed/`
6. Frequency distribution modeling (Poisson/Negative Binomial)
7. Severity distribution modeling (Gamma/Lognormal with discretization)
8. Collective risk model estimation using FFT and Panjer algorithms
9. Convolution of all coverage distributions
10. Comprehensive validation and visualization
11. Export of final results to `data/output/`

## Development Workflow

### Running Tests
```bash
# From src/test/ directory
conda activate Renv
Rscript test_polizas_diarias.R    # Test daily calculations
Rscript test_ajuste_prima_ipc.R   # Test IPC adjustments
```

### Complete Collective Risk Model Workflow
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

# 5. Estimate frequency and severity models
# (Implemented in modelo_de_frecuencia.ipynb and modelo_de_severidad.ipynb)

# 6. Apply collective risk models
source("src/utils/Panjer.R")
source("src/utils/FFT_RiesgoColectivo.R")

# 7. Calculate aggregate loss distributions
modelo_ppd <- Panjer(severidad_ppd, "poisson", params_freq_ppd, x_scale=10000, maxit=50000)
modelo_fft_ppd <- FFT_RiesgoColectivo(severidad_ppd, "poisson", params_freq_ppd, x_scale=10000)

# 8. Validate and compare results
correlacion <- cor(modelo_ppd$obtener_probabilidades()$pmf, modelo_fft_ppd$obtener_probabilidades()$pmf)

# 9. Generate final convolution (implemented in convolucion_final.ipynb)
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

**Complete Modeling Workflow**:
1. `limpieza_de_polizas.ipynb`: Policy data cleaning and IPC adjustment
2. `limpieza_de_siniestros.ipynb`: Claims data cleaning and validation
3. `limpieza_de_vigentes.ipynb`: Active policy data processing
4. `modelo_de_frecuencia.ipynb`: Frequency distribution estimation
5. `modelo_de_severidad.ipynb`: Severity distribution fitting and discretization
6. `panjer.ipynb`: Panjer algorithm implementation for each coverage
7. `fft.ipynb`: FFT algorithm implementation and validation
8. `convolucion_final.ipynb`: Final convolution and comprehensive output

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

**Algorithm Usage**:

**Panjer Algorithm**:
```r
source("src/utils/Panjer.R")
resultado_panjer <- Panjer(
  prob_severidad = severidad_discretizada,
  dist_frecuencia = "poisson",
  parametros_frecuencia = list(lambda = 0.1234),
  x_scale = 10000,
  maxit = 50000,
  echo = TRUE
)
probs <- resultado_panjer$obtener_probabilidades(x_max = 500000000)
```

**FFT Algorithm**:
```r
source("src/utils/FFT_RiesgoColectivo.R")
resultado_fft <- FFT_RiesgoColectivo(
  prob_severidad = severidad_discretizada,
  dist_frecuencia = "poisson",
  parametros_frecuencia = list(lambda = 0.1234),
  x_scale = 10000,
  n_points = 50000,
  echo = TRUE
)
probs <- resultado_fft$obtener_probabilidades(x_max = 500000000)
```

**Data Merging**: When joining claims and policy data, use inner join by date:
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

## Collective Risk Model Implementation

### Algorithm Comparison and Validation

**Mathematical Foundation**:
- **Compound Distribution Theory**: S = X₁ + X₂ + ... + Xₙ where N ~ frequency distribution, Xᵢ ~ severity distribution
- **Characteristic Function**: φₛ(t) = φₙ(φₓ(t)) for compound distributions
- **Discrete Implementation**: Both algorithms work with discretized severity distributions (10,000 points)

**Panjer Algorithm**:
- **Method**: Recursive calculation using `actuar::aggregateDist`
- **Computational Complexity**: O(n²) for large ranges
- **Range**: Extended to 600M with mass redistribution for ranges up to 500M
- **Advantages**: Mathematically exact, well-established actuarial standard
- **Configuration**: `maxit=50000`, `tol=1e-12` for high precision

**FFT Algorithm**:
- **Method**: Fast Fourier Transform with n-fold convolution
- **Computational Complexity**: O(n log n) - significantly faster for large ranges
- **Range**: Native support up to 500M with proper normalization
- **Advantages**: Computational efficiency, scalable to larger problems
- **Implementation**: Correct compound distribution theory with suma aleatoria

**Validation Results**:
- **Correlation**: >0.99 between FFT and Panjer for all coverage types
- **Range Consistency**: Both algorithms now calculate identical ranges (500M)
- **Performance**: FFT approximately 10x faster than Panjer for large ranges
- **Accuracy**: Validated against known analytical solutions where available

### Final Model Outputs

**Individual Coverage Distributions**:
- **PPD (Pérdida Parcial por Daños)**: Most frequent, moderate severity
- **PTH (Pérdida Total por Hurto)**: Low frequency, high severity
- **PPH (Pérdida Parcial por Hurto)**: Low frequency, moderate severity  
- **RC (Responsabilidad Civil)**: Variable frequency and severity

**Aggregate Portfolio Distribution**:
- **Total Range**: 0 to 500 million pesos
- **Convolution Method**: Sum of all 4 coverage distributions
- **Risk Metrics**: VaR₉₅%, VaR₉₉%, VaR₉₉.₉% calculated
- **Visualization**: Dual-scale plots (50M detail, 500M complete)

**Export Structure** (`data/output/`):
- **CSV Files**: 11 files including individual and aggregate distributions
- **Graphics**: 12 PNG files with publication-ready visualizations
- **Validation**: Comparative statistics and correlation analysis
- **Documentation**: Comprehensive metadata and parameter documentation

## Statistical Modeling

**Complete Collective Risk Model Implementation**:

**Frequency Modeling**:
- **Poisson Distribution**: λ parameter estimated from claims data
- **Negative Binomial Distribution**: size and μ parameters with overdispersion
- Validated using likelihood ratio tests and goodness-of-fit statistics

**Severity Modeling**:
- **Lognormal Distribution**: μ and σ parameters fitted via maximum likelihood
- **Gamma Distribution**: shape and rate parameters with method of moments
- Discretization to 10,000 points for computational efficiency
- Comprehensive distribution fitting validation with statistical tests

**Aggregate Loss Distributions**:
- **Individual Coverage Models**: PPD, PTH, PPH, RC using both FFT and Panjer
- **Computational Range**: Up to 500 million pesos with 10,000 peso increments
- **Algorithm Validation**: Correlation >0.99 between FFT and Panjer results
- **Performance**: FFT O(n log n) vs Panjer O(n²) computational complexity

**Final Convolution**:
- **Total Portfolio Risk**: Convolution of all 4 coverage distributions
- **Risk Metrics**: VaR calculations at 95%, 99%, and 99.9% confidence levels
- **Dual-Scale Visualization**: 50M detail plots and 500M complete range plots
- **Comprehensive Output**: 11 CSV files and 12 PNG graphics exported to `data/output/`

**Model Validation**:
- Cross-validation between FFT and Panjer algorithms
- Statistical goodness-of-fit tests for all distributions
- Comprehensive diagnostic plots and residual analysis
- Performance benchmarking and computational complexity analysis