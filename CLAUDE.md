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

## Report Generation Guidelines

### Writing Methodology
- Vamos a redactar el reporte del trabajo realizado en @notebooks/ con los siguientes criterios:
  - Generar un texto académicamente legible y matemáticamente correcto
  - Evitar redundancia y complejidad innecesaria
  - Utilizar tablas para presentar información que sea más clara en formato tabular
  - Usar [H] en \begin{figure} para fijar imágenes
  - Mantener un enfoque de actuario experto con perspectiva de MBA en administración
  - Redactar únicamente lo solicitado, sin añadir contenido adicional
  - Mantener un tono formal y profesional en la documentación

### Report Content Strategy
- Documentar el desarrollo en notebooks con precisión técnica
- Enfocarse en la claridad y concisión de la explicación
- Priorizar la presentación de resultados y metodología
- Incluir referencias matemáticas rigurosas pero comprensibles
- Utilizar visualizaciones y tablas para complementar el texto

### Technical Writing Approach
- Estructurar el documento con secciones claras y bien definidas
- Explicar la lógica detrás de cada decisión metodológica
- Presentar los resultados de manera objetiva y técnicamente sólida
- Incluir validaciones estadísticas y comparativas de los modelos

## Development Workflow

(Rest of the existing content remains unchanged)