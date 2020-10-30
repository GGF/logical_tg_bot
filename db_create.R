# Скрипт создания базы данных
library(DBI)     # интерфейс для работы с СУБД
library(configr) # чтение конфига
library(readr)   # чтение текстовых SQL файлов
library(RSQLite) # драйвер для подключения к SQLite

# директория проекта
setwd(Sys.getenv('TG_BOT_PATH'))

# чтение конфига
cfg <- read.config('config.cfg')

# подключение к SQLite
con <- dbConnect(SQLite(), cfg$db_settings$db_path)

# Создание таблиц в базе
dbExecute(con, statement = read_file('create_db_data.sql'))
dbExecute(con, statement = read_file('create_db_state.sql'))
dbExecute(con, statement = read_file('create_db_diary.sql'))

dbDisconnect(con)

