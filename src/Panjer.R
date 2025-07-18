Panjer <- function(prob_severidad, dist_frecuencia, parametros_frecuencia, x_scale = 1, convolve = 0, maxit = 500, echo = FALSE) {
  
  library(actuar)
  
  # Validar que prob_severidad sea un vector de probabilidades
  if (!is.numeric(prob_severidad) || any(prob_severidad < 0) || any(prob_severidad > 1)) {
    stop("prob_severidad debe ser un vector de probabilidades válidas (entre 0 y 1)")
  }
  
  # Validar que las probabilidades sumen aproximadamente 1
  if (abs(sum(prob_severidad) - 1) > 0.01) {
    warning(paste("La suma de probabilidades es", round(sum(prob_severidad), 6), "- debería ser cercana a 1"))
  }
  
  # Validar distribución de frecuencia
  distribuciones_validas <- c("poisson", "binomial", "geometric", "negative binomial", "nbinom")
  if (!dist_frecuencia %in% distribuciones_validas) {
    stop(paste("Distribución de frecuencia no soportada:", dist_frecuencia, 
               "\nDistribuciones válidas:", paste(distribuciones_validas, collapse = ", ")))
  }
  
  # Normalizar nombre de distribución
  if (dist_frecuencia == "nbinom") {
    dist_frecuencia <- "negative binomial"
  }
  
  # Preparar argumentos base para aggregateDist
  args_base <- list(
    method = "recursive",
    model.freq = dist_frecuencia,
    model.sev = prob_severidad,
    x.scale = x_scale,
    convolve = convolve,
    maxit = maxit,
    echo = echo
  )
  
  # Agregar parámetros específicos de la distribución de frecuencia
  if (dist_frecuencia == "poisson") {
    # Para Poisson: solo necesita lambda
    if (!"lambda" %in% names(parametros_frecuencia)) {
      stop("Para distribución Poisson se requiere el parámetro 'lambda'")
    }
    args_base$lambda <- parametros_frecuencia$lambda
    
  } else if (dist_frecuencia == "negative binomial") {
    # Para Binomial Negativa: necesita size y prob (o mu)
    if ("size" %in% names(parametros_frecuencia) && "mu" %in% names(parametros_frecuencia)) {
      # Convertir de (size, mu) a (size, prob)
      size <- parametros_frecuencia$size
      mu <- parametros_frecuencia$mu
      prob <- size / (size + mu)
      args_base$size <- size
      args_base$prob <- prob
    } else if ("size" %in% names(parametros_frecuencia) && "prob" %in% names(parametros_frecuencia)) {
      # Usar directamente size y prob
      args_base$size <- parametros_frecuencia$size
      args_base$prob <- parametros_frecuencia$prob
    } else {
      stop("Para Binomial Negativa se requieren parámetros 'size' y 'prob' o 'size' y 'mu'")
    }
    
  } else if (dist_frecuencia == "binomial") {
    # Para Binomial: necesita size y prob
    if (!"size" %in% names(parametros_frecuencia) || !"prob" %in% names(parametros_frecuencia)) {
      stop("Para distribución Binomial se requieren parámetros 'size' y 'prob'")
    }
    args_base$size <- parametros_frecuencia$size
    args_base$prob <- parametros_frecuencia$prob
    
  } else if (dist_frecuencia == "geometric") {
    # Para Geométrica: necesita prob
    if (!"prob" %in% names(parametros_frecuencia)) {
      stop("Para distribución Geométrica se requiere el parámetro 'prob'")
    }
    args_base$prob <- parametros_frecuencia$prob
  }
  
  # Ejecutar aggregateDist con manejo de errores
  resultado <- tryCatch({
    do.call(aggregateDist, args_base)
  }, error = function(e) {
    if (grepl("maximum number of recursions", e$message)) {
      # Intentar con más iteraciones o convolución
      warning("Máximo número de recursiones alcanzado. Intentando con convolución...")
      args_base$convolve <- max(1, convolve + 1)
      args_base$maxit <- maxit * 2
      do.call(aggregateDist, args_base)
    } else {
      stop(paste("Error en aggregateDist:", e$message))
    }
  })
  
  # Crear función para evaluar la CDF
  cdf_function <- resultado
  
  # Crear función para obtener probabilidades discretas
  obtener_probabilidades <- function(x_max = NULL, paso = 1) {
    if (is.null(x_max)) {
      # Estimar x_max basado en percentiles
      x_max <- 0
      while (cdf_function(x_max) < 0.999 && x_max < 1000000) {
        x_max <- x_max + paso * 100
      }
    }
    
    x_vals <- seq(0, x_max, by = paso)
    cdf_vals <- sapply(x_vals, cdf_function)
    
    # Calcular PMF a partir de CDF
    pmf_vals <- c(cdf_vals[1], diff(cdf_vals))
    
    return(data.frame(
      x = x_vals,
      cdf = cdf_vals,
      pmf = pmf_vals
    ))
  }
  
  # Información del modelo
  info_modelo <- list(
    distribucion_frecuencia = dist_frecuencia,
    parametros_frecuencia = parametros_frecuencia,
    num_puntos_severidad = length(prob_severidad),
    suma_prob_severidad = sum(prob_severidad),
    x_scale = x_scale,
    convolve = convolve,
    maxit = maxit
  )
  
  # Mostrar información si echo = TRUE
  if (echo) {
    cat("═══════════════════════════════════════════════════════════════════════════\n")
    cat("                           MODELO DE RIESGO COLECTIVO                       \n")
    cat("                            (Algoritmo de Panjer)                           \n")
    cat("═══════════════════════════════════════════════════════════════════════════\n")
    cat(sprintf("Distribución de frecuencia: %s\n", stringr::str_to_title(dist_frecuencia)))
    cat("Parámetros de frecuencia:\n")
    for (param in names(parametros_frecuencia)) {
      cat(sprintf("  %s = %.6f\n", param, parametros_frecuencia[[param]]))
    }
    cat(sprintf("Puntos de severidad: %d\n", info_modelo$num_puntos_severidad))
    cat(sprintf("Suma probabilidades severidad: %.6f\n", info_modelo$suma_prob_severidad))
    cat(sprintf("Factor de escala: %d\n", x_scale))
    if (convolve > 0) {
      cat(sprintf("Convoluciones: %d\n", convolve))
    }
    cat("═══════════════════════════════════════════════════════════════════════════\n")
  }
  
  # Retornar lista con función CDF y utilidades
  return(list(
    cdf = cdf_function,
    obtener_probabilidades = obtener_probabilidades,
    info = info_modelo
  ))
}