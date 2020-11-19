library(telegram.bot)
library(tidyverse)
library(RSQLite)
library(DBI)
library(configr)

# work directory
setwd(Sys.getenv('TG_BOT_PATH'))

# read config
cfg <- read.config('config.cfg')
#cfg <- read.config('config_win.cfg')

# bot instance
updater <- Updater(cfg$bot_settings$bot_token)

# loading R code
source('db_bot_function.R') # read db functions
source('bot_methods.R')     # read bot methods
source('message_filters.R') # message state filters
source('handlers.R') # message state filters

# dispetcher
updater <- updater +
  start_h +
  state_h +
  wait_diary_record_h +
  wait_month_h +
  listrec_h +
  curlistrec_h +
  query_h +
  reset_h

updater$bot$clean_updates()
# run bot
tryCatch(
  
  # запускаем пуллинг
  expr = updater$start_polling(), 
  
  # действия при ошибке пуллинга
  error = function(err) {
    
    # бот для оповещения
    bot <- Bot(token = cfg$bot_settings$bot_token)
    
    # чат для оповещения

    chat_ids <- get_active_chat_ids()

    # сообщение
    msg <- str_glue("*Бот упал*: Ошибка (_{err$message}_).")

    # очищаем полученный апдейт бота, который вызвал ошибку
    updater$bot$clean_updates()
    
    for (id in chat_ids) {
      bot$sendMessage(chat_id = id, text = msg, parse_mode = 'Markdown')
      # информация о том, что бот будет перезапущен
      bot$sendMessage(chat_id = id, text = str_glue('*Перезапускаю бота* в {Sys.time()}'), parse_mode = 'Markdown')
      # перезапускаем скрипт бота, мы же текущий каталог установили?
      source('bot.R') 
    }
  }, 
  # действия которые будут выполненны в любом случае
  finally = {
    
    # останавливаем пулинг
    updater$stop_polling()
        


  }
)
