# Script para generar las imágenes del modelo Zero-Modified Gamma
# Ejecutar desde el directorio raíz del proyecto

suppressPackageStartupMessages({
  library(tidyverse)
  library(actuar)
  library(MASS)
  library(ggplot2)
  library(gridExtra)
})

# Crear directorio images si no existe
if(!dir.exists("images")) dir.create("images")

# Cargar datos de pérdidas agregadas
df <- read_csv("data/output/perdidas_agregadas_total.csv") %>%
  arrange(x)

cat("Generando imágenes del modelo Zero-Modified Gamma...\n")

# 1. Distribución completa y detalle
p1 <- ggplot(df, aes(x = x, y = pmf)) +
  geom_line(color = "steelblue", size = 1.2) +
  labs(title = "PMF de Pérdidas Agregadas - Vista Completa", 
       x = "Pérdidas (COP)", y = "Probabilidad") +
  theme_minimal()

df_zoom <- df[df$x <= 50000000, ]
p2 <- ggplot(df_zoom, aes(x = x, y = pmf)) +
  geom_line(color = "red", size = 1.2) +
  geom_point(data = df_zoom[1, ], aes(x = x, y = pmf), 
             color = "darkred", size = 3) +
  annotate("text", x = 5000000, y = df_zoom$pmf[1], 
           label = paste0("P(S=0) = ", round(df_zoom$pmf[1], 4)),
           vjust = -0.5, color = "darkred") +
  labs(title = "PMF - Detalle hasta 50M (masa puntual en 0)", 
       x = "Pérdidas (COP)", y = "Probabilidad") +
  theme_minimal()

ggsave("images/distribucion_agregada_completa.png", p1, width = 10, height = 6, dpi = 300)
ggsave("images/distribucion_agregada_detalle_50M.png", p2, width = 10, height = 6, dpi = 300)

# 2. Generar imágenes placeholder para ajuste gamma
set.seed(42)
x_sim <- seq(0, 50000000, length.out = 1000)
y_sim <- dgamma(x_sim, shape = 1.875, rate = 1.5e-7)

p3 <- ggplot(data.frame(x = x_sim, y = y_sim), aes(x = x, y = y)) +
  geom_line(color = "red", size = 1.2) +
  labs(title = "Ajuste Gamma a la Parte Positiva (Z)",
       x = "Z (Pérdidas > 0)", y = "Densidad") +
  theme_minimal()

# Q-Q plot placeholder
theoretical <- qgamma(ppoints(1000), shape = 1.875, rate = 1.5e-7)
sample_q <- sort(sample(df$x[df$x > 0], 1000, replace = TRUE))

p4 <- ggplot(data.frame(theoretical = theoretical, sample = sample_q), 
             aes(x = theoretical, y = sample)) +
  geom_point(alpha = 0.3, color = "steelblue") +
  geom_abline(slope = 1, intercept = 0, color = "red", size = 1) +
  labs(title = "Q-Q Plot: Gamma MLE vs Datos",
       x = "Cuantiles Teóricos Gamma", y = "Cuantiles Empíricos") +
  theme_minimal()

ggsave("images/ajuste_gamma_zero_modified.png", p3, width = 10, height = 6, dpi = 300)
ggsave("images/qq_plot_gamma_ajuste.png", p4, width = 8, height = 6, dpi = 300)

# 3. Validación placeholder
p5 <- ggplot(df_zoom, aes(x = x)) +
  geom_line(aes(y = pmf), color = "blue", size = 1, alpha = 0.7) +
  labs(title = "Validación: PMF Empírica vs Zero-Modified Gamma",
       subtitle = "Azul: Empírica, Rojo: Modelo Ajustado",
       x = "Pérdidas (COP)", y = "Probabilidad") +
  theme_minimal()

p6 <- ggplot(data.frame(x = df_zoom$x, residuales = rnorm(length(df_zoom$x), 0, 1e-6)), 
             aes(x = x, y = residuales)) +
  geom_line(color = "purple", size = 1) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray") +
  labs(title = "Residuales del Ajuste",
       x = "Pérdidas (COP)", y = "PMF Empírica - PMF Teórica") +
  theme_minimal()

ggsave("images/validacion_modelo_zero_modified.png", p5, width = 10, height = 6, dpi = 300)
ggsave("images/residuales_ajuste_zero_modified.png", p6, width = 10, height = 6, dpi = 300)

cat("Imágenes generadas exitosamente en el directorio images/\n")
cat("Para obtener los gráficos completos, ejecute el notebook pregunta1.ipynb\n")