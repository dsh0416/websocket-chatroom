require 'sqlite3'

class Database
  def initialize(db_file)
    @db = SQLite3::Database.new db_file
  end

  def initialize_data
    initialized = @db.get_first_value <<-SQL
      select name from sqlite_master where type='table'
    SQL
    unless initialized == 'history'
      @db.execute <<-SQL
        create table history (
         room_id int,
         msg text
        )
      SQL

      @db.execute <<-SQL
        create table users (
          username text,
          password text
        )
      SQL
    end
  end

  def insert_msg(room_id, msg)
    @db.execute('insert into history (room_id, msg)
                 values (?, ?)', [room_id, msg])
  end

  def select_history(room_id)
    @db.execute('select msg from history where room_id == ?', [room_id])
  end

  def search_user(username)
    @db.execute('select password from users where username == ?', [username])
  end

  def insert_user(username, password)
    @db.execute('insert into users (username, password) values (?, ?)', [username, password])
  end

  def close
    @db.close
  end
end
