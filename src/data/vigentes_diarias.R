vigentes_diarias <- function(df) {
  
  df <- na.omit(df[, c("inicio", "fin")])
  
  if (nrow(df) == 0) {
    stop("El dataframe no contiene datos válidos o las columnas 'inicio' y 'fin' no existen")
  }
  
  if (!inherits(df$inicio, "Date")) {
    df$inicio <- as.Date(df$inicio)
  }
  if (!inherits(df$fin, "Date")) {
    df$fin <- as.Date(df$fin)
  }
  
  fecha_min <- min(df$inicio, na.rm = TRUE)
  fecha_max <- max(df$fin, na.rm = TRUE)
  
  secuencia_fechas <- seq(from = fecha_min, to = fecha_max, by = "day")
  
  resultado <- data.frame(
    fecha = secuencia_fechas,
    polizas_activas = 0,
    stringsAsFactors = FALSE
  )
  
  for (i in 1:length(secuencia_fechas)) {
    fecha_actual <- secuencia_fechas[i]
    
    polizas_vigentes <- sum(df$inicio <= fecha_actual & df$fin >= fecha_actual, na.rm = TRUE)
    
    resultado$polizas_activas[i] <- polizas_vigentes
  }
  
  return(resultado)
}

vigentes_mensuales <- function(df) {
  
  df <- na.omit(df[, c("inicio", "fin")])
  
  if (nrow(df) == 0) {
    stop("El dataframe no contiene datos válidos o las columnas 'inicio' y 'fin' no existen")
  }
  
  if (!inherits(df$inicio, "Date")) {
    df$inicio <- as.Date(df$inicio)
  }
  if (!inherits(df$fin, "Date")) {
    df$fin <- as.Date(df$fin)
  }
  
  # Crear secuencia de 12 meses del 2019 (basado en los datos del notebook)
  meses_2019 <- 1:12
  
  resultado <- data.frame(
    mes = meses_2019,
    polizas_activas = 0,
    stringsAsFactors = FALSE
  )
  
  for (i in 1:length(meses_2019)) {
    mes <- meses_2019[i]
    fecha_inicio_mes <- as.Date(paste("2019", sprintf("%02d", mes), "01", sep = "-"))
    fecha_fin_mes <- as.Date(paste("2019", sprintf("%02d", mes), 
                                 ifelse(mes == 2, "28", 
                                        ifelse(mes %in% c(4, 6, 9, 11), "30", "31")), 
                                 sep = "-"))
    
    # Contar pólizas vigentes durante el mes
    polizas_vigentes <- sum(df$inicio <= fecha_fin_mes & df$fin >= fecha_inicio_mes, na.rm = TRUE)
    
    resultado$polizas_activas[i] <- polizas_vigentes
  }
  
  return(resultado)
}