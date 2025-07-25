ajuste_dinero_ipc <- function(df, fecha, dinero){

  ipc_data <- read.csv("../data/input/factores_ipc.csv")
  ipc_data$X <- NULL

  ipc_data$Mes[ipc_data$Mes == "Enero"] <- "01"
  ipc_data$Mes[ipc_data$Mes == "Febrero"] <- "02"
  ipc_data$Mes[ipc_data$Mes == "Marzo"] <- "03"
  ipc_data$Mes[ipc_data$Mes == "Abril"] <- "04"
  ipc_data$Mes[ipc_data$Mes == "Mayo"] <- "05"
  ipc_data$Mes[ipc_data$Mes == "Junio"] <- "06"
  ipc_data$Mes[ipc_data$Mes == "Julio"] <- "07"
  ipc_data$Mes[ipc_data$Mes == "Agosto"] <- "08"
  ipc_data$Mes[ipc_data$Mes == "Septiembre"] <- "09"
  ipc_data$Mes[ipc_data$Mes == "Octubre"] <- "10"
  ipc_data$Mes[ipc_data$Mes == "Noviembre"] <- "11"
  ipc_data$Mes[ipc_data$Mes == "Diciembre"] <- "12"
  
  df$mes <- format(df$fecha, "%m")
  df$anio <- format(df$fecha, "%Y")

  resultado <- merge(df, ipc_data, by.x = c("mes", "anio"), by.y = c("Mes", "Anio"), all.x = TRUE)

  resultado[[dinero]] <- resultado[[dinero]] * resultado$Factor

  resultado$mes <- NULL
  resultado$anio <- NULL
  resultado$Factor <- NULL
  resultado$X <- NULL

  return(resultado)
}