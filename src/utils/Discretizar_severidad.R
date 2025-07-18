Discretizar_severidad <- function(distribucion, parametros, paso = 10000, limite = 20000000) {
  
  library(actuar)
  
  # Crear secuencia de valores
  x <- seq(0, limite, by = paso)
  
  # Crear función CDF según la distribución
  if (distribucion == "weibull") {
    cdf_funcion <- function(x) pweibull(x, shape = parametros$shape, scale = parametros$scale)
  } else if (distribucion == "gamma") {
    cdf_funcion <- function(x) pgamma(x, shape = parametros$shape, rate = parametros$rate)
  } else if (distribucion == "lognormal") {
    cdf_funcion <- function(x) plnorm(x, meanlog = parametros$meanlog, sdlog = parametros$sdlog)
  } else if (distribucion == "normal") {
    cdf_funcion <- function(x) pnorm(x, mean = parametros$mean, sd = parametros$sd)
  } else if (distribucion == "inv_gaussian") {
    # Función de distribución acumulada inverse gaussian
    cdf_funcion <- function(x) {
      mu <- parametros$mu
      lambda <- parametros$lambda
      pnorm(sqrt(lambda/x) * (x/mu - 1)) + exp(2*lambda/mu) * pnorm(-sqrt(lambda/x) * (x/mu + 1))
    }
  } else if (distribucion == "pareto") {
    library(actuar)
    cdf_funcion <- function(x) ppareto(x, shape = parametros$shape, scale = parametros$scale)
  } else if (distribucion == "burr") {
    library(actuar)
    cdf_funcion <- function(x) pburr(x, shape1 = parametros$shape1, shape2 = parametros$shape2, scale = parametros$scale)
  } else {
    stop(paste("Distribución no soportada:", distribucion))
  }
  
  # Usar método "upper" para la discretización
  pmf_discreto <- discretize(cdf_funcion, from = 0, to = limite, step = paso, method = "upper")
  
  # Asegurar que las longitudes coincidan
  if (length(pmf_discreto) != length(x)) {
    # Ajustar la longitud de x para que coincida con pmf_discreto
    x <- seq(0, by = paso, length.out = length(pmf_discreto))
  }
  
  # Crear lista de resultados
  resultado <- list(
    valores = x,
    probabilidades = pmf_discreto,
    distribucion = distribucion,
    parametros = parametros,
    paso = paso,
    limite = limite,
    suma_probabilidades = sum(pmf_discreto),
    numero_puntos = length(pmf_discreto)
  )
  
  return(resultado)
}