## Modelo de Riesgo Colectivo

- Modelo matemático para análisis de siniestros de seguros de automóviles
- Cubre 4 coberturas: PPD, PTH, PPH, RC
- Variables definidas:
  * E_{tj}: Exposición de la póliza j en el día t (días de vigencia restantes de todas las polizas vigentes en el dia t / 365)
  * N_{tj}: Número de siniestros por cobertura j en el día t
  * N_j: Número total de siniestros por cobertura j
  * X^{(j)}: Severidad de siniestros para la cobertura j
  * S_j: Valor total de pagos de la aseguradora por cobertura j
  * S: Valor total de pagos de la aseguradora
- Métricas calculadas:
  * Tasa de frecuencia por unidad de exposición: λ_j = (Σ N_{tj}) / (Σ E_{jt})
  * Dispersión muestral: D_j = (N_j - λ_j Σ E_{jt})^2 / (λ_j Σ E_{jt})

## Project Data Sources

- El objetivo es modelar un portafolio de seguros de automoviles. 
- Archivos de datos clave:
  - `@data/input/polizas.csv`: Contiene todas las polizas vendidas
  - `@data/input/Siniestros_Hist.xlsx`: Registro histórico de siniestros ocurridos para esas polizas
  - `@data/input/Siniestros_Hist.xlsx`: 300 polizas nuevas para las cuales se realizarán predicciones

### Data Structure Challenges

- `@data/input/polizas.csv` tiene columnas Fecha_inicio, Fecha_fin, Prima, PPD, PPH, PTH y RC. Las ultimas 4 son indicadoras que dicen si la poliza cuenta con esa cobertura o no.
- `@data/input/Siniestros_Hist.xlsx` tiene columnas Fecha_siniestro, Valor_siniestro_incurrido y Cobertura_final_aplicada.
- No hay identificadores que permitan relacionar directamente los siniestros con las coberturas específicas de las pólizas en las que ocurrieron.

### Current Analysis Progress

- En @notebooks/Polizas.ipynb estoy haciendo el analisis exploratorio y limpieza de @data/input/polizas.csv
- En @notebooks/Siniestros_New.ipynb estoy haciendo el analisis exploratorio y limpieza de @data/input/Siniestros_Hist.xlsx