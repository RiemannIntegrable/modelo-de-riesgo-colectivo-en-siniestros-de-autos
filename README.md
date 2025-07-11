<div align="center">

# 🚗 **Modelo de Riesgo Colectivo en Siniestros de Autos**

*Análisis actuarial de portafolios de seguros de automóviles*

[![R](https://img.shields.io/badge/R-4.2.3-blue.svg)](https://www.r-project.org/)
[![LaTeX](https://img.shields.io/badge/LaTeX-Document-green.svg)](https://www.latex-project.org/)
[![Universidad Nacional](https://img.shields.io/badge/Universidad-Nacional%20de%20Colombia-red.svg)](https://unal.edu.co/)

</div>

---

## 👥 **Equipo**

| Estudiante | Email | Rol |
|------------|-------|-----|
| José Miguel Acuña Hernández | jacunah@unal.edu.co | Desarrollador Principal |
| Andrés Steven Puertas Londoño | apuertasl@unal.edu.co | Analista de Datos |
| Cristian Camilo González Morales | crigonzalezmo@unal.edu.co | Modelado Estadístico |

**Docente:** Alejandra Sánchez Vásquez  
**Materia:** Teoría del Riesgo Actuarial 2025-I  
**Universidad:** Universidad Nacional de Colombia

---

## 📋 **Descripción**

Este proyecto implementa modelos de riesgo colectivo para analizar portafolios de seguros de automóviles. Utilizamos datos reales de pólizas y siniestros para construir modelos actuariales que estiman la pérdida agregada por unidad de tiempo.

### 🎯 **Objetivo Principal**

Implementar modelos de riesgo colectivo para estimar la distribución de la variable aleatoria S (pérdida agregada) de un portafolio de seguros de automóviles, calibrando parámetros de frecuencia y severidad mediante técnicas estadísticas.

---

## 🔍 **Análisis Exploratorio**

### 🚧 **Limitaciones Identificadas**

- **Sin identificadores únicos**: Las pólizas no tienen IDs únicos, obligando a modelar por unidad temporal
- **Desalineación temporal**: Siniestros en 2018 vs pólizas 2016-2020
- **Coberturas inconsistentes**: 5 coberturas en pólizas vs 4 en siniestros
- **Ajuste por inflación**: Necesario para comparar 2018 vs 2019

### 📊 **Decisiones Metodológicas**

- Modelar pérdida agregada **por día** en lugar de por portafolio
- Usar solo datos con exposición en 2018
- Consolidar 4 coberturas: PPD, PPH, PTH, RC
- Ajustar valores monetarios con IPC a enero 2019

---

## 🧹 **Limpieza de Datos**

### 📁 **Histórico de Pólizas**
- ✅ Estandarización de nombres de columnas
- ✅ Eliminación de PTD (sin siniestros registrados)
- ✅ Filtro por exposición en 2018
- ✅ Umbral de prima mínima: $459,500 (SOAT 2016)
- ✅ Eliminación de pólizas < 60 días duración
- **Resultado:** 319,298 pólizas procesadas

### 📈 **Histórico de Siniestros**
- ✅ Consolidación RC BIENES + RC PERS → RC
- ✅ Solo siniestros de 2018
- ✅ Variable de severidad: `VLRSININCUR`
- ✅ Ajuste IPC mensual a enero 2019
- ✅ Filtros por cobertura:
  - PPH/PPD: > $70,000
  - PTH: > $3,000,000  
  - RC: > $500,000

### 🆕 **Nuevo Portafolio**
- ✅ Eliminación de 6 duplicados (300 → 294 pólizas)
- ✅ Corrección duración 1 día → 366 días
- ✅ Conservación de primas bajas (pagos mensuales)
- ✅ Segmentación por cobertura

---

## 🔬 **Modelación**

### 📐 **Marco Teórico**

Definimos **C = {PPD, PPH, PTH, RC}** como conjunto de coberturas.

Para cada cobertura *c*:
- **X^(c)**: Severidad de un siniestro
- **N^(c)**: Número de siniestros por unidad de tiempo  
- **S^(c) = Σ X^(c)_k**: Pérdida agregada por cobertura
- **S = Σ S^(c)**: Pérdida agregada total

### 🎲 **Distribuciones**

**Frecuencia:**
- 🎯 Poisson para coberturas con equidispersión
- 📊 Binomial Negativa para sobredispersión

**Severidad:**
- 📈 Distribuciones empíricas (frecuencias relativas)
- 🧮 Ajuste paramétrico: Gamma, Normal, LogNormal, Weibull

### ⚙️ **Algoritmos**
- 🔄 **Panjer**: Recursión para distribuciones discretas
- ⚡ **FFT**: Transformada rápida de Fourier
- 🔗 **Convolución**: Para pérdida agregada total

---

## 🛠️ **Estructura del Proyecto**

```
📦 modelo-de-riesgo-colectivo-en-siniestros-de-autos/
├── 📁 data/
│   ├── 📁 input/           # Datos originales (.xlsx, .txt)
│   ├── 📁 processed/       # Datos procesados (.csv)
│   └── 📁 output/          # Resultados del análisis
├── 📁 src/
│   ├── 📁 data/           # Funciones de procesamiento
│   ├── 📁 models/         # Modelos estadísticos
│   ├── 📁 utils/          # Utilidades (Panjer, tests)
│   └── 📁 test/           # Tests unitarios
├── 📁 notebooks/          # Análisis en Jupyter (.ipynb)
├── 📁 docs/              # Documentación LaTeX
│   ├── 📁 config/        # Configuración LaTeX
│   ├── 📁 content/       # Secciones del documento
│   └── main.tex          # Documento principal
└── 📁 images/            # Gráficos y visualizaciones
```

---

## 🚀 **Instalación y Uso**

### 📋 **Prerequisitos**

- R >= 4.2.3
- Conda/Miniconda

### ⚡ **Setup Rápido**

```bash
# Clonar repositorio
git clone https://github.com/RiemannIntegrable/modelo-de-riesgo-colectivo-en-siniestros-de-autos.git
cd modelo-de-riesgo-colectivo-en-siniestros-de-autos

# Crear entorno conda
conda env create -f environment.yml
conda activate Renv

# Ejecutar notebooks
jupyter lab
```

### 📊 **Funciones Principales**

```r
# Cargar funciones
source("src/data/polizas_diarias.R")
source("src/utils/panjer.R")

# Calcular exposición diaria
exposicion <- polizas_diarias(polizas_limpias)

# Aplicar algoritmo de Panjer
resultado <- panjer(p_severidad, q0, "poisson", lambda)
```

---

## 📈 **Resultados**

*Esta sección se completará una vez finalizado el análisis*

---

## ❓ **Preguntas de Investigación**

*Esta sección se completará según los objetivos específicos del proyecto*

---

## 🧪 **Testing**

```bash
# Ejecutar tests unitarios
cd src/test/
Rscript test_polizas_diarias.R
Rscript test_ajuste_prima_ipc.R
```

---

## 📚 **Documentación**

El documento técnico completo se encuentra en `docs/main.tex`. Para compilar:

```bash
cd docs/
pdflatex main.tex
pdflatex main.tex  # Ejecutar dos veces para referencias cruzadas
```

---

## 🤝 **Contribuciones**

Este es un proyecto académico de la Universidad Nacional de Colombia. Para sugerencias o preguntas, contactar a los autores.

---

## 📄 **Licencia**

Este proyecto es de uso académico para la materia Teoría del Riesgo Actuarial de la Universidad Nacional de Colombia.

---

## 🙏 **Agradecimientos**

- **Profesora Alejandra Sánchez Vásquez** por la guía y supervisión
- **Universidad Nacional de Colombia** por proporcionar los recursos
- **Departamento de Matemáticas** por el apoyo académico

---

<div align="center">

**🎓 Universidad Nacional de Colombia - Facultad de Ciencias - Departamento de Matemáticas**

*Teoría del Riesgo Actuarial 2025-I*

</div>