convolucion <- function(px, py) {
  
  # Validación de entrada
  if (!is.numeric(px) || !is.numeric(py)) {
    stop("Los vectores de probabilidad deben ser numéricos")
  }
  
  if (any(px < 0) || any(py < 0)) {
    stop("Las probabilidades no pueden ser negativas")
  }
  
  if (abs(sum(px) - 1) > 1e-10 || abs(sum(py) - 1) > 1e-10) {
    warning("Los vectores no suman exactamente 1. Se normalizarán automáticamente.")
    px <- px / sum(px)
    py <- py / sum(py)
  }
  
  # Longitudes de los vectores
  n <- length(px)
  m <- length(py)
  
  # La longitud del resultado será n + m - 1
  # (suma mínima: 0+0=0, suma máxima: (n-1)+(m-1)=n+m-2)
  longitud_resultado <- n + m - 1
  
  # Inicializar vector resultado
  pz <- numeric(longitud_resultado)
  
  # Calcular la convolución discreta
  # P(Z = k) = sum_{i=0}^{min(k,n-1)} P(X = i) * P(Y = k-i)
  for (k in 0:(longitud_resultado - 1)) {
    suma_prob <- 0
    
    # Índices válidos para X (de 0 a n-1, ajustados a índices de R 1 a n)
    for (i in 0:(n - 1)) {
      j <- k - i  # Índice correspondiente en Y
      
      # Verificar que ambos índices sean válidos
      if (i >= 0 && i < n && j >= 0 && j < m) {
        # Convertir a índices de R (base 1)
        i_r <- i + 1
        j_r <- j + 1
        suma_prob <- suma_prob + px[i_r] * py[j_r]
      }
    }
    
    # Asignar al vector resultado (índice k+1 en R)
    pz[k + 1] <- suma_prob
  }
  
  # Verificar que la suma sea 1 (dentro de tolerancia numérica)
  suma_total <- sum(pz)
  if (abs(suma_total - 1) > 1e-10) {
    warning(sprintf("La suma de probabilidades resultado es %.10f, no exactamente 1", suma_total))
  }
  
  return(pz)
}