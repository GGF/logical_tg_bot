# ###########################################################
# Function for work bot with database

# get current chat state
get_state <- function(chat_id) {
  
  con <- dbConnect(SQLite(), cfg$db_settings$db_path)
  
  chat_state <- dbGetQuery(con, str_interp("SELECT state FROM chat_state WHERE chat_id == ${chat_id}"))$state
  
  return(unlist(chat_state))
  
  dbDisconnect(con)
}

# set current chat state
set_state <- function(chat_id, state) {
  
  con <- dbConnect(SQLite(), cfg$db_settings$db_path)
  
  # upsert состояние чата
  dbExecute(con, 
            str_interp("
            INSERT INTO chat_state (chat_id, state)
                VALUES(${chat_id}, '${state}') 
                ON CONFLICT(chat_id) 
                DO UPDATE SET state='${state}';
            ")
  )
  
  dbDisconnect(con)
  
}

# write chat data
set_chat_data <- function(chat_id, field, value) {
  
  
  con <- dbConnect(SQLite(), cfg$db_settings$db_path)
  
  # upsert состояние чата
  dbExecute(con, 
            str_interp("
            INSERT INTO chat_data (chat_id, ${field})
                VALUES(${chat_id}, '${value}') 
                ON CONFLICT(chat_id) 
                DO UPDATE SET ${field}='${value}';
            ")
  )
  
  dbDisconnect(con)
  
}

# read chat data
get_chat_data <- function(chat_id, field) {
  
  
  con <- dbConnect(SQLite(), cfg$db_settings$db_path)
  
  # upsert состояние чата
  data <- dbGetQuery(con, 
                     str_interp("
            SELECT ${field}
            FROM chat_data
            WHERE chat_id = ${chat_id};
            ")
  )
  
  dbDisconnect(con)
  
  return(data[[field]])
  
}

# read diary records for month
get_diary_data <- function(chat_id, month) {
  
  
  con <- dbConnect(SQLite(), cfg$db_settings$db_path)
  
  # 
  data <- dbGetQuery(con, str_interp("SELECT record FROM diary_data WHERE chat_id = ${chat_id} AND rmonth = ${month};") )
  
  dbDisconnect(con)

  # объединить в один текст
  t <- ""
  for (i in 1:length(data$record)) t <- str_c(t,data$record[i], sep="\n\n")
  
  return(t)
  
}

# write record
set_diary_record <- function(chat_id, record) {
  
  
  con <- dbConnect(SQLite(), cfg$db_settings$db_path)

  # record month
  rmonth <- as.numeric(format(Sys.Date(),"%m"))

  # Добавим заголовки в маркдауне даты и времени, я так вставляю потом в дневник
  # если уже были сегодня записи, то дату не добавляем, только время
  
  res <- dbGetQuery(con, "select COUNT(*) as n from 'diary_data' where date(rdatime) = date('now')")
  if ( res$n > 0 ) {
    rdate <- ""
  } else {
    rdate <- format(Sys.Date(),"===%d-%m-%Y===\n")
  }

  rtime <- format(Sys.time(),"**%H:%M**\n")
  # добавим время и если надо дату
  record <- paste0(rdate,rtime,record)

  # insert record
  res <- dbExecute(con, str_interp("INSERT INTO diary_data (chat_id, record, rdatime, rmonth) VALUES(${chat_id}, '${record}', datetime('now'), '${rmonth}');"))
  
  dbDisconnect(con)
  
}


# read all ids active chats
get_active_chat_ids <- function() {
 
  con <- dbConnect(SQLite(), cfg$db_settings$db_path)
  # 
  res <- dbGetQuery(con, str_interp("SELECT chat_id FROM chat_state;") )

  dbDisconnect(con)

  return(res$chat_id)
  
}

