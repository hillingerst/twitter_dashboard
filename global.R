# Load packages
library(shiny)
library(shinydashboard)
library(highcharter)
library(igraph)
library(readr)
library(tidytext)
library(dplyr)
library(data.table)

# Setup data
Sys.setlocale("LC_TIME", "English")
data <- fread("data.csv", encoding = "UTF-8")
data[, created_at := as.Date(created_at, format = "%Y-%m-%d")]
langlist <- fread("langlist.csv", encoding = "UTF-8")
langlist <- unlist(langlist)
stop_de <- fread("stop.csv", encoding = "UTF-8")
stop_de <- dplyr::pull(stop_de, a)
