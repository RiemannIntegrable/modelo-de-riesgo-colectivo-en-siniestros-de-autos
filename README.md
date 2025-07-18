<div align="center">

# 🚗 **Modelo de Riesgo Colectivo en Siniestros de Autos**

*Análisis actuarial de portafolios de seguros de automóviles*

[![R](https://img.shields.io/badge/R-4.2.3-blue.svg)](https://www.r-project.org/)
[![Conda](https://img.shields.io/badge/Conda-Environment-green.svg)](https://conda.io/)
[![Jupyter](https://img.shields.io/badge/Jupyter-Notebooks-orange.svg)](https://jupyter.org/)
[![LaTeX](https://img.shields.io/badge/LaTeX-Document-red.svg)](https://www.latex-project.org/)
[![Universidad Nacional](https://img.shields.io/badge/Universidad-Nacional%20de%20Colombia-yellow.svg)](https://unal.edu.co/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](#licencia)

</div>

---

## 👥 **Autoría**

### 🎓 **Estudiante**
| Nombre | Email | GitHub |
|--------|-------|---------|
| José Miguel Acuña Hernández | jacunah@unal.edu.co | [@RiemannIntegrable](https://github.com/RiemannIntegrable) |

### 👩‍🏫 **Supervisión Académica**
**Docente:** Alejandra Sánchez Vásquez  
**Materia:** Teoría del Riesgo Actuarial 2025-I  
**Universidad:** Universidad Nacional de Colombia  
**Facultad:** Ciencias - Departamento de Matemáticas

---

## 🛠️ **Estructura del Proyecto**

```
📦 modelo-de-riesgo-colectivo-en-siniestros-de-autos/
├── 📁 data/
│   ├── 📁 input/                    # 📊 Datos originales
│   │   ├── Grupo_P11.xlsx           # Datos de pólizas históricas
│   │   ├── Siniestros_Hist.xlsx     # Histórico de siniestros
│   │   ├── Historico_IPC_Factor_Ajuste.xlsx # Factores de ajuste IPC
│   │   ├── factores_ipc.csv         # Factores IPC en formato CSV
│   │   ├── IPC_Update.csv           # Actualización datos IPC
│   │   ├── polizas.csv              # Pólizas procesadas
│   │   └── polizas_v2.txt           # Pólizas formato texto
│   ├── 📁 processed/                # ✅ Datos procesados por cobertura
│   │   ├── polizas_ppd.csv          # Pólizas Pérdida Parcial Daños
│   │   ├── polizas_pth.csv          # Pólizas Pérdida Total Hurto
│   │   ├── polizas_pph.csv          # Pólizas Pérdida Parcial Hurto
│   │   ├── polizas_rc.csv           # Pólizas Responsabilidad Civil
│   │   ├── siniestros_ppd.csv       # Siniestros PPD
│   │   ├── siniestros_pth.csv       # Siniestros PTH
│   │   ├── siniestros_pph.csv       # Siniestros PPH
│   │   └── siniestros_rc.csv        # Siniestros RC
│   └── 📁 output/                   # 📈 Resultados del análisis
│       ├── perdidas_agregadas_*.csv # Distribuciones de pérdida agregada
│       ├── distribucion_severidad_*.csv # Distribuciones de severidad
│       ├── validacion_*.csv         # Datos de validación FFT vs Panjer
│       └── perdidas_agregadas_total.csv # Distribución total del portafolio
├── 📁 src/
│   ├── 📁 data/                     # 🔧 Funciones de procesamiento
│   │   ├── polizas_diarias.R        # Cálculo de exposición diaria
│   │   └── ajuste_prima_ipc.R       # Ajuste por inflación IPC
│   ├── 📁 models/                   # 📊 Modelos estadísticos
│   ├── 📁 utils/                    # ⚙️ Algoritmos y utilidades
│   │   ├── Panjer.R                 # Algoritmo de Panjer
│   │   └── FFT_RiesgoColectivo.R    # Algoritmo FFT para riesgo colectivo
│   └── 📁 test/                     # 🧪 Tests unitarios
│       ├── test_polizas_diarias.R   # Tests para cálculos diarios
│       └── test_ajuste_prima_ipc.R  # Tests para ajuste IPC
├── 📁 notebooks/                    # 📓 Análisis en Jupyter
│   ├── limpieza_de_polizas.ipynb    # Limpieza de datos de pólizas
│   ├── limpieza_de_siniestros.ipynb # Limpieza de datos de siniestros
│   ├── limpieza_de_vigentes.ipynb   # Procesamiento de pólizas vigentes
│   ├── modelo_de_frecuencia.ipynb   # Modelado de frecuencia de siniestros
│   ├── modelo_de_severidad.ipynb    # Modelado de severidad de siniestros
│   ├── panjer.ipynb                 # Implementación algoritmo Panjer
│   └── convolucion_final.ipynb      # Convolución final del portafolio
├── 📁 docs/                         # 📄 Documentación técnica
│   ├── 📁 config/                   # Configuración LaTeX
│   ├── 📁 content/                  # Secciones del documento
│   │   ├── Introduccion.tex         # Introducción del proyecto
│   │   ├── Metodologia.tex          # Metodología empleada
│   │   ├── Implementacion.tex       # Detalles de implementación
│   │   ├── Resultados.tex           # Resultados y análisis
│   │   └── Conclusiones.tex         # Conclusiones y recomendaciones
│   └── main.tex                     # Documento principal LaTeX
├── 📁 images/                       # 📊 Gráficos y visualizaciones
│   ├── distribucion_severidad_*.png # Distribuciones de severidad
│   ├── ajuste_lognormal_*.png       # Ajustes de distribución lognormal
│   └── validacion_*.png             # Gráficos de validación
├── environment.yml                  # 🐍 Configuración entorno Conda
└── README.md                        # 📖 Este archivo
```

---

## 🚀 **Instalación y Uso**

### 📋 **Prerequisitos**

- 🐧 **Sistema Operativo**: Linux (Ubuntu, WSL, etc.)
- 🐍 **Conda/Miniconda**: Para gestión de entornos
- 📝 **Editor de Código**: VSCode, Cursor, o similar con soporte para Jupyter
- 📊 **R**: >= 4.2.3 (se instala automáticamente con el entorno)

### ⚡ **Setup Rápido**

```bash
# 1. Clonar repositorio
git clone https://github.com/RiemannIntegrable/modelo-de-riesgo-colectivo-en-siniestros-de-autos.git
cd modelo-de-riesgo-colectivo-en-siniestros-de-autos

# 2. Crear entorno conda (IMPORTANTE: usar conda, no mamba)
conda env create -f environment.yml
conda activate Renv

# 3. Verificar instalación
R --version
jupyter --version

# 4. Iniciar Jupyter Lab
jupyter lab
```

### 📓 **Orden de Ejecución de Notebooks**

**⚠️ IMPORTANTE**: Los notebooks deben ejecutarse en este orden específico:

#### 🧹 **Fase 1: Limpieza de Datos**
```
1. 📋 limpieza_de_polizas.ipynb      # Procesar datos de pólizas
2. 📊 limpieza_de_siniestros.ipynb   # Procesar datos de siniestros  
3. 📈 limpieza_de_vigentes.ipynb     # Procesar pólizas vigentes
```

#### 🎯 **Fase 2: Modelado Estadístico**
```
4. 📊 modelo_de_frecuencia.ipynb     # Estimar distribuciones de frecuencia
5. 📈 modelo_de_severidad.ipynb      # Estimar distribuciones de severidad
```

#### ⚙️ **Fase 3: Modelos de Riesgo Colectivo**
```
6. 🔄 panjer.ipynb                   # Aplicar algoritmo de Panjer
7. 🔗 convolucion_final.ipynb        # Convolución final del portafolio
```

### 🔧 **Funciones Principales**

```r
# Cargar funciones de procesamiento
source("src/data/polizas_diarias.R")
source("src/data/ajuste_prima_ipc.R")

# Calcular exposición diaria por cobertura
exposicion_diaria <- polizas_diarias(polizas_limpias)

# Ajustar primas por inflación IPC
primas_ajustadas <- ajuste_prima_ipc(polizas_raw)

# Cargar algoritmos de riesgo colectivo
source("src/utils/Panjer.R")
source("src/utils/FFT_RiesgoColectivo.R")

# Aplicar algoritmo de Panjer
resultado_panjer <- Panjer(
  prob_severidad = severidad_discretizada,
  dist_frecuencia = "poisson",
  parametros_frecuencia = list(lambda = 0.123),
  x_scale = 10000,
  maxit = 50000
)

# Aplicar algoritmo FFT
resultado_fft <- FFT_RiesgoColectivo(
  prob_severidad = severidad_discretizada,
  dist_frecuencia = "poisson", 
  parametros_frecuencia = list(lambda = 0.123),
  x_scale = 10000,
  n_points = 50000
)
```

### 🎯 **Configuración del Entorno**

El archivo `environment.yml` incluye:

- **R 4.2.3**: Lenguaje principal
- **Paquetes estadísticos**: tidyverse, ggplot2, dplyr, forecast
- **Paquetes actuariales**: actuar (para algoritmo Panjer)
- **Jupyter**: Para notebooks interactivos
- **Testing**: testthat para pruebas unitarias