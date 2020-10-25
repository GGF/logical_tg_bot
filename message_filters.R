# ###########################################################
# message state filters

# фильтр сообщение в состоянии ожидания имени
MessageFilters$wait_name <- BaseFilter(function(message) {
  get_state( message$chat_id )  == "wait_name"
}
)

# фильтр сообщение в состоянии ожидания возраста
MessageFilters$wait_age <- BaseFilter(function(message) {
  get_state( message$chat_id )   == "wait_age"
}
)