#' Prima Stop-Loss para Distribuciones Continuas
#' 
#' Calcula la prima stop-loss E[max(X-d, 0)] para diferentes distribuciones
#' 
#' @param distribucion Tipo de distribución ("gamma", "lognormal", "weibull", "normal")
#' @param parametros Lista con los parámetros de la distribución
#' @param deducible Valor del deducible d
#' @param metodo Método de cálculo ("integracion", "montecarlo")
#' @param n_sim Número de simulaciones para Monte Carlo (default: 100000)
#' 
#' @return Prima stop-loss calculada
#' 
#' @examples
#' # Para distribución Gamma
#' params <- list(shape = 1.874, rate = 6.152e-07)
#' prima <- Prima_stop_loss("gamma", params, deducible = 2000000)
#' 
#' # Para distribución Lognormal
#' params <- list(meanlog = 14.64, sdlog = 0.81)
#' prima <- Prima_stop_loss("lognormal", params, deducible = 2000000)

Prima_stop_loss <- function(distribucion, parametros, deducible, 
                           metodo = "integracion", n_sim = 100000) {
  
  if (!distribucion %in% c("gamma", "lognormal", "weibull", "normal")) {
    stop("Distribución no soportada. Use: gamma, lognormal, weibull, normal")
  }
  
  if (metodo == "integracion") {
    
    # Calcular límite superior razonable (percentil 99.9 de la distribución)
    if (distribucion == "gamma") {
      if (!all(c("shape", "rate") %in% names(parametros))) {
        stop("Para Gamma se requieren parámetros: shape, rate")
      }
      
      limite_superior <- qgamma(0.999, shape = parametros$shape, rate = parametros$rate)
      
      integrand <- function(x) {
        (x - deducible) * dgamma(x, shape = parametros$shape, rate = parametros$rate)
      }
      
    } else if (distribucion == "lognormal") {
      if (!all(c("meanlog", "sdlog") %in% names(parametros))) {
        stop("Para Lognormal se requieren parámetros: meanlog, sdlog")
      }
      
      limite_superior <- qlnorm(0.999, meanlog = parametros$meanlog, sdlog = parametros$sdlog)
      
      integrand <- function(x) {
        (x - deducible) * dlnorm(x, meanlog = parametros$meanlog, sdlog = parametros$sdlog)
      }
      
    } else if (distribucion == "weibull") {
      if (!all(c("shape", "scale") %in% names(parametros))) {
        stop("Para Weibull se requieren parámetros: shape, scale")
      }
      
      limite_superior <- qweibull(0.999, shape = parametros$shape, scale = parametros$scale)
      
      integrand <- function(x) {
        (x - deducible) * dweibull(x, shape = parametros$shape, scale = parametros$scale)
      }
      
    } else if (distribucion == "normal") {
      if (!all(c("mean", "sd") %in% names(parametros))) {
        stop("Para Normal se requieren parámetros: mean, sd")
      }
      
      limite_superior <- qnorm(0.999, mean = parametros$mean, sd = parametros$sd)
      
      integrand <- function(x) {
        (x - deducible) * dnorm(x, mean = parametros$mean, sd = parametros$sd)
      }
    }
    
    # Asegurar que el límite superior sea mayor al deducible
    limite_superior <- max(limite_superior, deducible * 10)
    
    # Intentar integración con manejo de errores
    resultado <- tryCatch({
      integrate(integrand, lower = deducible, upper = limite_superior, 
                subdivisions = 1000, rel.tol = 1e-6)
    }, error = function(e) {
      warning("Error en integración numérica, usando Monte Carlo: ", e$message)
      return(NULL)
    })
    
    if (is.null(resultado)) {
      # Fallback a Monte Carlo si falla la integración
      return(Prima_stop_loss(distribucion, parametros, deducible, metodo = "montecarlo", n_sim))
    }
    
    if (resultado$message != "OK") {
      warning("Problemas en la integración numérica: ", resultado$message)
    }
    
    # Ajustar por la cola truncada (aproximación)
    if (distribucion == "gamma") {
      cola_truncada <- (1 - pgamma(limite_superior, shape = parametros$shape, rate = parametros$rate)) * 
                      (limite_superior - deducible)
    } else if (distribucion == "lognormal") {
      cola_truncada <- (1 - plnorm(limite_superior, meanlog = parametros$meanlog, sdlog = parametros$sdlog)) * 
                      (limite_superior - deducible)
    } else if (distribucion == "weibull") {
      cola_truncada <- (1 - pweibull(limite_superior, shape = parametros$shape, scale = parametros$scale)) * 
                      (limite_superior - deducible)
    } else {
      cola_truncada <- (1 - pnorm(limite_superior, mean = parametros$mean, sd = parametros$sd)) * 
                      (limite_superior - deducible)
    }
    
    return(resultado$value + cola_truncada)
    
  } else if (metodo == "montecarlo") {
    
    if (distribucion == "gamma") {
      simulaciones <- rgamma(n_sim, shape = parametros$shape, rate = parametros$rate)
    } else if (distribucion == "lognormal") {
      simulaciones <- rlnorm(n_sim, meanlog = parametros$meanlog, sdlog = parametros$sdlog)
    } else if (distribucion == "weibull") {
      simulaciones <- rweibull(n_sim, shape = parametros$shape, scale = parametros$scale)
    } else if (distribucion == "normal") {
      simulaciones <- rnorm(n_sim, mean = parametros$mean, sd = parametros$sd)
    }
    
    excesos <- pmax(simulaciones - deducible, 0)
    prima <- mean(excesos)
    
    return(prima)
    
  } else {
    stop("Método no reconocido. Use 'integracion' o 'montecarlo'")
  }
}

#' Prima Stop-Loss para Múltiples Deducibles
#' 
#' Calcula primas stop-loss para un vector de deducibles
#' 
#' @param distribucion Tipo de distribución
#' @param parametros Lista con parámetros de la distribución
#' @param deducibles Vector de deducibles (opcional, se generará automáticamente)
#' @param desde Deducible mínimo en COP (default: 200000)
#' @param hasta Deducible máximo en COP (default: 10000000)
#' @param paso Incremento entre deducibles en COP (default: 200000)
#' @param metodo Método de cálculo
#' 
#' @return Data frame con deducibles y primas correspondientes

Prima_stop_loss_multiple <- function(distribucion, parametros, deducibles = NULL, 
                                   desde = 200000, hasta = 10000000, paso = 200000,
                                   metodo = "integracion") {
  
  # Si no se proporcionan deducibles, generar secuencia
  if (is.null(deducibles)) {
    deducibles <- seq(desde, hasta, by = paso)
  }
  
  cat("Calculando primas stop-loss para", length(deducibles), "niveles de deducible...\n")
  cat("Rango:", format(min(deducibles), big.mark = ","), "a", format(max(deducibles), big.mark = ","), "COP\n\n")
  
  primas <- sapply(deducibles, function(d) {
    Prima_stop_loss(distribucion, parametros, d, metodo)
  })
  
  resultado <- data.frame(
    deducible = deducibles,
    deducible_millones = deducibles / 1e6,
    prima_stop_loss = primas,
    prima_millones = primas / 1e6,
    ratio_prima_deducible = primas / deducibles
  )
  
  return(resultado)
}

#' Prima Stop-Loss desde Datos Observados (Empírica)
#' 
#' Calcula primas stop-loss directamente desde un vector de datos observados
#' usando la función de distribución empírica
#' 
#' @param datos Vector de datos observados
#' @param deducible Valor del deducible d
#' 
#' @return Prima stop-loss empírica

Prima_stop_loss_empirica <- function(datos, deducible) {
  
  if (!is.numeric(datos) || length(datos) == 0) {
    stop("Los datos deben ser un vector numérico no vacío")
  }
  
  # Remover valores NA
  datos <- datos[!is.na(datos)]
  
  # Calcular excesos directamente
  excesos <- pmax(datos - deducible, 0)
  prima_empirica <- mean(excesos)
  
  return(prima_empirica)
}

#' Prima Stop-Loss Empírica para Múltiples Deducibles
#' 
#' Calcula primas stop-loss empíricas para múltiples deducibles desde datos observados
#' 
#' @param datos Vector de datos observados
#' @param deducibles Vector de deducibles (opcional)
#' @param desde Deducible mínimo en COP (default: 200000)
#' @param hasta Deducible máximo en COP (default: 10000000) 
#' @param paso Incremento entre deducibles en COP (default: 200000)
#' 
#' @return Data frame con deducibles y primas empíricas

Prima_stop_loss_empirica_multiple <- function(datos, deducibles = NULL,
                                            desde = 200000, hasta = 10000000, paso = 200000) {
  
  if (!is.numeric(datos) || length(datos) == 0) {
    stop("Los datos deben ser un vector numérico no vacío")
  }
  
  # Remover valores NA
  datos <- datos[!is.na(datos)]
  
  # Generar deducibles si no se proporcionan
  if (is.null(deducibles)) {
    deducibles <- seq(desde, hasta, by = paso)
  }
  
  # Ajustar el rango máximo según los datos
  max_dato <- max(datos)
  deducibles <- deducibles[deducibles <= max_dato]
  
  if (length(deducibles) == 0) {
    stop("Todos los deducibles son mayores que el valor máximo de los datos")
  }
  
  cat("Calculando primas stop-loss empíricas para", length(deducibles), "niveles de deducible...\n")
  cat("Rango:", format(min(deducibles), big.mark = ","), "a", format(max(deducibles), big.mark = ","), "COP\n")
  cat("N datos:", length(datos), "\n\n")
  
  # Calcular primas para cada deducible
  primas <- sapply(deducibles, function(d) {
    Prima_stop_loss_empirica(datos, d)
  })
  
  resultado <- data.frame(
    d = deducibles,
    pi_X_d = primas,
    deducible_millones = deducibles / 1e6,
    prima_millones = primas / 1e6,
    ratio_prima_deducible = primas / deducibles
  )
  
  return(resultado)
}

#' Esperanza Limitada
#' 
#' Calcula E[min(X, d)] para una distribución dada
#' 
#' @param distribucion Tipo de distribución
#' @param parametros Lista con parámetros
#' @param limite Valor límite d
#' 
#' @return Esperanza limitada

#' Prima Stop-Loss desde Vectores Discretos (PMF/CDF)
#' 
#' Calcula primas stop-loss desde vectores discretos de probabilidad
#' 
#' @param pmf Vector de función de masa de probabilidad
#' @param valores Vector de valores correspondientes (opcional, se asume secuencia 0, 1, 2, ...)
#' @param deducible Valor del deducible d
#' @param paso Tamaño del paso entre valores (default: 1)
#' 
#' @return Prima stop-loss calculada

Prima_stop_loss_discreta <- function(pmf, valores = NULL, deducible, paso = 1) {
  
  if (!is.numeric(pmf) || length(pmf) == 0) {
    stop("PMF debe ser un vector numérico no vacío")
  }
  
  # Si no se proporcionan valores, usar secuencia 0, paso, 2*paso, ...
  if (is.null(valores)) {
    valores <- seq(0, (length(pmf) - 1) * paso, by = paso)
  }
  
  if (length(pmf) != length(valores)) {
    stop("PMF y valores deben tener la misma longitud")
  }
  
  # Encontrar índices donde valor >= deducible
  indices_exceso <- which(valores >= deducible)
  
  if (length(indices_exceso) == 0) {
    return(0)  # No hay excesos
  }
  
  # Calcular excesos para cada valor
  excesos <- pmax(valores[indices_exceso] - deducible, 0)
  probabilidades <- pmf[indices_exceso]
  
  # Prima stop-loss = suma de excesos ponderados por probabilidades
  prima <- sum(excesos * probabilidades)
  
  return(prima)
}

#' Prima Stop-Loss Discreta para Múltiples Deducibles
#' 
#' Calcula primas stop-loss discretas para múltiples deducibles
#' 
#' @param pmf Vector de función de masa de probabilidad
#' @param valores Vector de valores correspondientes (opcional)
#' @param deducibles Vector de deducibles (opcional)
#' @param desde Deducible mínimo (default: 200000)
#' @param hasta Deducible máximo (default: 10000000)
#' @param paso_deducibles Incremento entre deducibles (default: 200000)
#' @param paso_valores Tamaño del paso entre valores de la distribución (default: 1)
#' 
#' @return Data frame con deducibles y primas correspondientes

Prima_stop_loss_discreta_multiple <- function(pmf, valores = NULL, deducibles = NULL,
                                            desde = 200000, hasta = 10000000, 
                                            paso_deducibles = 200000, paso_valores = 1) {
  
  if (!is.numeric(pmf) || length(pmf) == 0) {
    stop("PMF debe ser un vector numérico no vacío")
  }
  
  # Generar valores si no se proporcionan
  if (is.null(valores)) {
    valores <- seq(0, (length(pmf) - 1) * paso_valores, by = paso_valores)
  }
  
  # Generar deducibles si no se proporcionan
  if (is.null(deducibles)) {
    deducibles <- seq(desde, hasta, by = paso_deducibles)
  }
  
  # Ajustar deducibles al rango de valores disponibles
  max_valor <- max(valores)
  deducibles <- deducibles[deducibles <= max_valor]
  
  if (length(deducibles) == 0) {
    stop("Todos los deducibles exceden el rango de valores de la distribución")
  }
  
  cat("Calculando primas stop-loss discretas para", length(deducibles), "niveles de deducible...\n")
  cat("Rango deducibles:", format(min(deducibles), big.mark = ","), "a", format(max(deducibles), big.mark = ","), "\n")
  cat("Rango valores:", format(min(valores), big.mark = ","), "a", format(max(valores), big.mark = ","), "\n")
  cat("Paso valores:", paso_valores, "\n\n")
  
  # Calcular primas para cada deducible
  primas <- sapply(deducibles, function(d) {
    Prima_stop_loss_discreta(pmf, valores, d, paso_valores)
  })
  
  resultado <- data.frame(
    d = deducibles,
    pi_X_d = primas,
    deducible_millones = deducibles / 1e6,
    prima_millones = primas / 1e6,
    ratio_prima_deducible = primas / deducibles
  )
  
  return(resultado)
}

Esperanza_limitada <- function(distribucion, parametros, limite) {
  
  if (distribucion == "gamma") {
    integrand <- function(x) {
      pmin(x, limite) * dgamma(x, shape = parametros$shape, rate = parametros$rate)
    }
  } else if (distribucion == "lognormal") {
    integrand <- function(x) {
      pmin(x, limite) * dlnorm(x, meanlog = parametros$meanlog, sdlog = parametros$sdlog)
    }
  } else if (distribucion == "weibull") {
    integrand <- function(x) {
      pmin(x, limite) * dweibull(x, shape = parametros$shape, scale = parametros$scale)
    }
  } else if (distribucion == "normal") {
    integrand <- function(x) {
      pmin(x, limite) * dnorm(x, mean = parametros$mean, sd = parametros$sdlog)
    }
  }
  
  resultado <- integrate(integrand, lower = 0, upper = Inf)
  return(resultado$value)
}