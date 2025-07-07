library(testthat)
source("../data/ajuste_prima_ipc.R")

test_that("ajuste_prima_ipc funciona", {
  
  polizas_test <- data.frame(
    Fecha_inicio = as.Date(c("2018-01-15", "2018-02-20")) ,
    Prima = c(100000, 200000)
  )
  
  resultado <- ajuste_prima_ipc(polizas_test)
  
  expect_true("Prima_ajustada" %in% names(resultado))
  expect_equal(nrow(resultado), 2)
  expect_true(all(!is.na(resultado$Prima_ajustada)))
  
  print(resultado)
})