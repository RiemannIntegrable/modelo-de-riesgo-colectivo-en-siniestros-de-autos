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
├── 📁 data/                         # 📊 Datos del proyecto
│   ├── 📁 input/                    # Datos originales (trackeados en Git)
│   ├── 📁 processed/                # Datos procesados (generados)
│   └── 📁 output/                   # Resultados del análisis (generados)
├── 📁 src/                          # 🔧 Código fuente
│   ├── 📁 data/                     # Funciones de procesamiento
│   ├── 📁 utils/                    # Algoritmos y utilidades
│   └── 📁 test/                     # Tests unitarios
├── 📁 notebooks/                    # 📓 Análisis en Jupyter
├── 📁 docs/                         # 📄 Documentación técnica
│   ├── 📁 config/                   # Configuración LaTeX
│   └── 📁 content/                  # Secciones del documento
├── 📁 images/                       # 📊 Gráficos y visualizaciones
├── 📄 CLAUDE.md                     # Instrucciones para Claude Code
├── 📄 LICENCE                       # Licencia MIT
├── 📄 environment.yml               # 🐍 Configuración entorno Conda
└── 📄 README.md                     # 📖 Este archivo
```

---

## 🚀 **Instalación y Uso**

### 📋 **Prerequisitos**

- 🐧 **Sistema Operativo**: Linux (Ubuntu, WSL, etc.)
- 🐍 **Conda/Miniconda**: Para gestión de entornos
- 📝 **Editor de Código**: VSCode o Cursor configurado para compilar con XeLaTeX
- 📊 **R**: >= 4.2.3 (se instala automáticamente con el entorno)
- 📄 **TeXLive Full**: Distribución completa de LaTeX para compilación de documentos

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
xelatex --version

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

### 📄 **Configuración de LaTeX**

**Instalación de TeXLive Full**:
```bash
# Ubuntu/Debian
sudo apt-get install texlive-full

# Verificar XeLaTeX
xelatex --version
```

**Configuración del Editor**:
- **VSCode**: Instalar extensión "LaTeX Workshop" y configurar para usar XeLaTeX
- **Cursor**: Configurar compilador LaTeX para usar XeLaTeX por defecto
- **Compilación**: Los documentos requieren XeLaTeX (no pdfLaTeX)

**Compilar documentación**:
```bash
cd docs/
xelatex main.tex
xelatex main.tex  # Ejecutar dos veces para referencias cruzadas
```