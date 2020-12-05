# ###########################################################
# bot methods

# start dialog
start <- function(bot, update) {
  run_start(bot,update$message$chat_id)
}

#  обработка старта, будем вызывать на команду и на перезапуск для уже существующих чатов
run_start <- function(bot,chat_id) {
  # создаём клавиатуру
  RKM <- ReplyKeyboardMarkup(
    keyboard = list(
      list(KeyboardButton('/curlist'),  KeyboardButton('/list'))
    ),
    resize_keyboard = TRUE,
    one_time_keyboard = FALSE
  )

  # отправляем клавиатуру
  bot$sendMessage(chat_id,
                  text = 'Жду записей', 
                  reply_markup = RKM)
  
  # переключаем состояние диалога в режим ожидания ввода дневниковой записи
  set_state(chat_id = chat_id, state = 'wait_diary_record')
  
}

# get current chat state
state <- function(bot, update) {
  
  chat_state <- get_state(update$message$chat_id)
  
  # Send state
  bot$sendMessage(update$message$chat_id, 
                  text = unlist(chat_state))
  
}

# reset dialog state
reset <- function(bot, update) {
  
  set_state(chat_id = update$message$chat_id, state = 'start')
  
}

#get records
listrec <- function(bot, update) {
  
  # создаём InLine клавиатуру
  IKM <- InlineKeyboardMarkup(
    inline_keyboard = list(
      list(
        InlineKeyboardButton("01", callback_data = '1'),
        InlineKeyboardButton("02", callback_data = '2'),
        InlineKeyboardButton("03", callback_data = '3'),
        InlineKeyboardButton("04", callback_data = '4')
      ), list(
        InlineKeyboardButton("05", callback_data = '5'),
        InlineKeyboardButton("06", callback_data = '6'),
        InlineKeyboardButton("07", callback_data = '7'),
        InlineKeyboardButton("08", callback_data = '8')
      ), list (
        InlineKeyboardButton("09", callback_data = '9'), 
        InlineKeyboardButton("10", callback_data = '10'),
        InlineKeyboardButton("11", callback_data = '11'),
        InlineKeyboardButton("12", callback_data = '12')
      )
    )
  )
  #
  bot$sendMessage(update$message$chat_id, text = "За какой месяц?", reply_markup = IKM)
  #
  set_state(chat_id = update$message$chat_id, state = 'wait_month')
}

# enter username
enter_name <- function(bot, update) {
  
  uname <- update$message$text
  
  # Send message with name
  bot$sendMessage(update$message$chat_id, 
                  text = paste0(uname, ", приятно познакомится, я бот!"))
  
  # Записываем имя в глобальную переменную
  #username <<- uname
  set_chat_data(update$message$chat_id, 'name', uname) 
  
  # Справшиваем возраст
  bot$sendMessage(update$message$chat_id, 
                  text = "Сколько тебе лет?")
  
  # Меняем состояние на ожидание ввода имени
  set_state(chat_id = update$message$chat_id, state = 'wait_age')
  
}

# enter user age
enter_age <- function(bot, update) {
  
  uage <- as.numeric(update$message$text)
  
  # проверяем было введено число или нет
  if ( is.na(uage) ) {
    
    # если введено не число то переспрашиваем возраст
    bot$sendMessage(update$message$chat_id, 
                    text = "Ты ввёл некорректные данные, введи число")
    
  } else {
    
    # если введено число сообщаем что возраст принят
    bot$sendMessage(update$message$chat_id, 
                    text = "ОК, возраст принят")
    
    # записываем глобальную переменную с возрастом
    #userage <<- uage
    set_chat_data(update$message$chat_id, 'age', uage) 
    
    # сообщаем какие данные были собраны
    username <- get_chat_data(update$message$chat_id, 'name')
    userage  <- get_chat_data(update$message$chat_id, 'age')
    
    bot$sendMessage(update$message$chat_id, 
                    text = paste0("Тебя зовут ", username, " и тебе ", userage, " лет. Будем знакомы"))
    
    # возвращаем диалог в исходное состояние
    set_state(chat_id = update$message$chat_id, state = 'start')
  }
  
}

#get records for current month
curlistrec <- function(bot, update) {
  month <- as.numeric(format(Sys.Date(),'%m'))
  show_month(bot,update$message$chat_id,month)
  # статус не меняем, потому что должны бы ждать записей
}

# enter month
enter_month <- function(bot, update) {
  
  month <- as.numeric(update$message$text)
  show_month(bot,update$message$chat_id,month)
 
}

# обработка кнопок месяцев
month_butons <- function(bot, update) {

  # полученные данные с кнопки (номер месяца)
  month <- as.numeric(update$callback_query$data)
  # тут идентификатор чата по другому получается
  show_month(bot,update$from_chat_id(),month)
  # сообщим что обработали кнопку
  bot$answerCallbackQuery(callback_query_id = update$callback_query$id) 

}

# Показывание месяца чтобы не дублировать код
show_month <- function(bot,chat_id,month) {
  # проверяем было введено число или нет
  if ( is.na(month) ) {
    # если введено не число то переспрашиваем возраст
    bot$sendMessage(chat_id, text = "Некорректные данные, введите число")
  } else {
    #  еще нужно проверить диапазон 1-12
    # если введено число выбираеам из базы записи за выбранный месяц и выведем
    diary <- get_diary_data(chat_id, month)
    # тут надо проверять данные на величину и посылать разными сообщениями
    t <- ""
    for (i in 1:length(diary)) {
      t <- str_c(t,diary[i], sep="\n\n")
      # Я не знаю сколько конкретно берет телега ну пусть 600, может на больших текста за день падать, хотя может он сам разобьет
      if ( 600 < str_count(t) ) {
        bot$sendMessage(chat_id, text = paste0(t))    
        t <- ""
      }
    }
    # а тут послать остатки
    if ( 0 <  str_count(t) ) {
      bot$sendMessage(chat_id, text = paste0(t))
    }
    
    # возвращаем диалог в исходное состояние
    set_state(chat_id = chat_id, state = 'wait_diary_record')
  }
}

# enter diary record
enter_diary_record <- function(bot, update) {
  
  record <- update$message$text
  
  set_diary_record(update$message$chat_id, record) 
  
  # Пишем что поняли
  bot$sendMessage(update$message$chat_id, 
                  text = "угу...")

  # так и остаёмся в ожидании  
}
