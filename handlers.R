# ###########################################################
# handlers

# command handlers
start_h <- CommandHandler('start', start)
state_h <- CommandHandler('state', state)
reset_h <- CommandHandler('reset', reset)
listrec_h <- CommandHandler('list', listrec)
curlistrec_h <- CommandHandler('curlist', curlistrec)

# message handlers
## !MessageFilters$command - означает что команды данные обработчики не обрабатывают, 
## только текстовые сообщения
wait_age_h  <- MessageHandler(enter_age,  MessageFilters$wait_age  & !MessageFilters$command)
wait_name_h <- MessageHandler(enter_name, MessageFilters$wait_name & !MessageFilters$command)

# ожидание ввода дневниковой записи
wait_diary_record_h <- MessageHandler(enter_diary_record, MessageFilters$wait_diary_record & !MessageFilters$command)

# при выводе записей ожидание ввода месяца, пока только текущего года
wait_month_h <- MessageHandler(enter_month, MessageFilters$wait_month & !MessageFilters$command)

# обработчик инлайн кнопок выбора месяца
query_h <- CallbackQueryHandler(month_butons)