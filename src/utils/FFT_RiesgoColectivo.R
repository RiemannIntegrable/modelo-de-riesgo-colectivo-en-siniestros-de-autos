FFT_RiesgoColectivo <- function(prob_severidad, dist_frecuencia, parametros_frecuencia, x_scale = 1, n_points = NULL, echo = FALSE) {
  
  # Validar que prob_severidad sea un vector de probabilidades
  if (!is.numeric(prob_severidad) || any(prob_severidad < 0) || any(prob_severidad > 1)) {
    stop("prob_severidad debe ser un vector de probabilidades válidas (entre 0 y 1)")
  }
  
  # Validar que las probabilidades sumen aproximadamente 1
  if (abs(sum(prob_severidad) - 1) > 0.01) {
    warning(paste("La suma de probabilidades es", round(sum(prob_severidad), 6), "- debería ser cercana a 1"))
  }
  
  # Validar distribución de frecuencia
  distribuciones_validas <- c("poisson", "negative binomial", "nbinom")
  if (!dist_frecuencia %in% distribuciones_validas) {
    stop(paste("Distribución de frecuencia no soportada para FFT:", dist_frecuencia, 
               "\nDistribuciones válidas:", paste(distribuciones_validas, collapse = ", ")))
  }
  
  # Normalizar nombre de distribución
  if (dist_frecuencia == "nbinom") {
    dist_frecuencia <- "negative binomial"
  }
  
  # Determinar número de puntos para FFT (debe ser potencia de 2)
  if (is.null(n_points)) {
    n_points <- 2^ceiling(log2(length(prob_severidad) * 4))
  } else {
    # Asegurar que sea potencia de 2
    n_points <- 2^ceiling(log2(n_points))
  }
  
  # Rellenar vector de severidad con ceros si es necesario
  if (length(prob_severidad) < n_points) {
    prob_severidad_fft <- c(prob_severidad, rep(0, n_points - length(prob_severidad)))
  } else {
    prob_severidad_fft <- prob_severidad[1:n_points]
  }
  
  # Implementación correcta de suma aleatoria usando FFT
  if (echo) {
    cat("Calculando distribución compuesta usando suma aleatoria FFT...\n")
  }
  
  # Calcular distribución de frecuencia
  if (dist_frecuencia == "poisson") {
    lambda <- parametros_frecuencia$lambda
    max_n <- min(50, floor(lambda + 6*sqrt(lambda)))  # 99.9% de la masa de probabilidad
    freq_probs <- dpois(0:max_n, lambda)
    
  } else if (dist_frecuencia == "negative binomial") {
    if ("size" %in% names(parametros_frecuencia) && "mu" %in% names(parametros_frecuencia)) {
      size <- parametros_frecuencia$size
      mu <- parametros_frecuencia$mu
      prob <- size / (size + mu)
    } else if ("size" %in% names(parametros_frecuencia) && "prob" %in% names(parametros_frecuencia)) {
      size <- parametros_frecuencia$size
      prob <- parametros_frecuencia$prob
    } else {
      stop("Para Binomial Negativa se requieren parámetros 'size' y 'prob' o 'size' y 'mu'")
    }
    # Calcular hasta 99.9% de la masa de probabilidad
    max_n <- tryCatch({
      min(50, qnbinom(0.999, size = size, prob = prob))
    }, error = function(e) {
      # Si falla qnbinom, usar aproximación
      if ("mu" %in% names(parametros_frecuencia)) {
        mu <- parametros_frecuencia$mu
        min(50, ceiling(mu + 6*sqrt(mu * (1 + mu/size))))
      } else {
        min(50, ceiling(size * (1-prob)/prob + 6*sqrt(size * (1-prob)/prob^2)))
      }
    })
    freq_probs <- dnbinom(0:max_n, size = size, prob = prob)
  }
  
  # Validar que freq_probs no tenga NA
  if (any(is.na(freq_probs))) {
    stop("Error: freq_probs contiene valores NA")
  }
  
  if (echo) {
    cat(sprintf("Distribución de frecuencia: max_n = %d, suma = %.6f\n", max_n, sum(freq_probs)))
  }
  
  # Inicializar distribución compuesta
  prob_compuesta <- numeric(n_points)
  
  # Calcular FFT de la distribución de severidad una sola vez
  fft_sev <- fft(prob_severidad_fft)
  
  if (echo) {
    cat("Aplicando suma aleatoria FFT...\n")
  }
  
  # Para cada valor de N, agregar la contribución N-fold convolución
  for (n in 0:(length(freq_probs) - 1)) {
    if (!is.na(freq_probs[n + 1]) && freq_probs[n + 1] > 1e-10) {  # Solo procesar si la probabilidad es significativa
      if (n == 0) {
        # N=0: solo contribuye a x=0
        prob_compuesta[1] <- prob_compuesta[1] + freq_probs[1]
      } else {
        # N>0: n-fold convolución usando FFT
        fft_n_fold <- fft_sev^n
        n_fold_conv <- Re(fft(fft_n_fold, inverse = TRUE)) / n_points
        n_fold_conv <- pmax(n_fold_conv, 0)  # Asegurar no negatividad
        
        # Agregar contribución ponderada
        prob_compuesta <- prob_compuesta + freq_probs[n + 1] * n_fold_conv
      }
    }
  }
  
  # Asegurar que las probabilidades sean no negativas
  prob_compuesta <- pmax(prob_compuesta, 0)
  
  # Normalizar para que sumen 1
  prob_compuesta <- prob_compuesta / sum(prob_compuesta)
  
  # Crear vector de valores x consistente con la escala
  x_vals <- (0:(n_points-1)) * x_scale
  
  # Calcular CDF
  cdf_vals <- cumsum(prob_compuesta)
  
  # Información del modelo
  info_modelo <- list(
    distribucion_frecuencia = dist_frecuencia,
    parametros_frecuencia = parametros_frecuencia,
    num_puntos_severidad = length(prob_severidad),
    suma_prob_severidad = sum(prob_severidad),
    n_points_fft = n_points,
    x_scale = x_scale
  )
  
  # Mostrar información si echo = TRUE
  if (echo) {
    cat("═══════════════════════════════════════════════════════════════════════════\n")
    cat("                       MODELO DE RIESGO COLECTIVO (FFT)                    \n")
    cat("═══════════════════════════════════════════════════════════════════════════\n")
    cat(sprintf("Distribución de frecuencia: %s\n", stringr::str_to_title(dist_frecuencia)))
    cat("Parámetros de frecuencia:\n")
    for (param in names(parametros_frecuencia)) {
      cat(sprintf("  %s = %.6f\n", param, parametros_frecuencia[[param]]))
    }
    cat(sprintf("Puntos de severidad: %d\n", length(prob_severidad)))
    cat(sprintf("Suma probabilidades severidad: %.6f\n", sum(prob_severidad)))
    cat(sprintf("Puntos FFT: %d\n", n_points))
    cat(sprintf("Factor de escala: %d\n", x_scale))
    cat("═══════════════════════════════════════════════════════════════════════════\n")
  }
  
  # Función para obtener probabilidades discretas
  obtener_probabilidades <- function(x_max = NULL, paso = NULL) {
    if (is.null(paso)) {
      paso <- x_scale
    }
    
    if (is.null(x_max)) {
      # Encontrar x_max donde CDF >= 0.999
      idx_999 <- which(cdf_vals >= 0.999)[1]
      if (is.na(idx_999)) idx_999 <- length(cdf_vals)
      x_max <- x_vals[idx_999]
    }
    
    # Filtrar datos hasta x_max
    idx_max <- which(x_vals <= x_max)
    if (length(idx_max) == 0) idx_max <- 1:length(x_vals)
    
    # Submuestrear si el paso es diferente a x_scale
    if (paso != x_scale) {
      step_ratio <- paso / x_scale
      if (step_ratio >= 1) {
        indices <- seq(1, length(idx_max), by = round(step_ratio))
        return(data.frame(
          x = x_vals[idx_max[indices]],
          cdf = cdf_vals[idx_max[indices]],
          pmf = prob_compuesta[idx_max[indices]]
        ))
      }
    }
    
    return(data.frame(
      x = x_vals[idx_max],
      cdf = cdf_vals[idx_max],
      pmf = prob_compuesta[idx_max]
    ))
  }
  
  # Retornar lista con resultados
  return(list(
    probabilidades = prob_compuesta,
    cdf = cdf_vals,
    x_vals = x_vals,
    obtener_probabilidades = obtener_probabilidades,
    info = info_modelo
  ))
}