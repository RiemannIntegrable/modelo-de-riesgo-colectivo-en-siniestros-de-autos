library(testthat)
source("../data/polizas_diarias.R")

test_that("polizas_diarias funciona correctamente", {
  
  polizas_test <- data.frame(
    Fecha_inicio = as.Date(c("2018-01-01", "2018-01-01", "2018-12-01")),
    Fecha_fin = as.Date(c("2018-12-31", "2018-12-31", "2018-12-31")),
    Prima_ajustada = c(100000, 150000, 200000),
    Perdida_parcial_danos = c(1, 1, 1),
    Perdida_total_hurto = c(0, 1, 1),
    Perdida_parcial_hurto = c(1, 1, 0),
    Responsabilidad_civil = c(1, 1, 1)
  )
  
  resultado <- polizas_diarias(polizas_test)
  
  expect_true(is.list(resultado))
  expect_equal(length(resultado), 4)
  expect_true(all(c("PPD", "PTH", "PPH", "RC") %in% names(resultado)))
  
  expect_equal(nrow(resultado$PPD), 365)
  expect_equal(nrow(resultado$PTH), 365)
  expect_equal(nrow(resultado$PPH), 365)
  expect_equal(nrow(resultado$RC), 365)
  
  expect_true(all(c("Fecha", "Numero_polizas", "Suma_primas", "Exposicion") %in% names(resultado$PPD)))
  
  primer_dia <- resultado$PPD[1, ]
  expect_equal(primer_dia$Numero_polizas, 2)
  expect_equal(primer_dia$Suma_primas, 250000)
  
  cat("Primer día PPD:\n")
  print(primer_dia)
  
  cat("Primer día RC:\n")
  print(resultado$RC[1, ])
})

test_that("polizas_diarias maneja dataframe vacío", {
  
  polizas_vacio <- data.frame(
    Fecha_inicio = as.Date(character(0)),
    Fecha_fin = as.Date(character(0)),
    Prima_ajustada = numeric(0),
    Perdida_parcial_danos = numeric(0),
    Perdida_total_hurto = numeric(0),
    Perdida_parcial_hurto = numeric(0),
    Responsabilidad_civil = numeric(0)
  )
  
  resultado <- polizas_diarias(polizas_vacio)
  
  expect_true(is.list(resultado))
  expect_equal(length(resultado), 4)
  expect_equal(nrow(resultado$PPD), 365)
  expect_true(all(resultado$PPD$Numero_polizas == 0))
  expect_true(all(resultado$PPD$Suma_primas == 0))
  expect_true(all(resultado$PPD$Exposicion == 0))
})