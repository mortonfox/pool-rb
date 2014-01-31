require 'rubygems'
require 'sqlite3'

# Pool module.
module PoolRB

  DB_FNAME = 'poolrb.db'

  # Functions for working with SQLite3 database.
  class Database

    def initialize
      @db = SQLite3::Database.new DB_FNAME

      stmt = <<-EOM
CREATE TABLE IF NOT EXISTS `tokens` (
        `service` VARCHAR(100) PRIMARY KEY,
        `token` VARCHAR(100),
        `secret` VARCHAR(100),
        `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
      EOM
      @db.execute(stmt) {}
    end

    def add_token service, token, secret
      stmt = <<-EOM
REPLACE INTO `tokens` (`service`, `token`, `secret`) VALUES (?, ?, ?)
      EOM
      @db.execute(stmt, service, token, secret) {}
    end

    def get_token service
      stmt = <<-EOM
SELECT `token`, `secret` FROM `tokens` WHERE `service` = ?
      EOM
      @db.execute(stmt, service) { |row|
        return row
      }
      [ nil, nil ]
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  db = PoolRB::Database.new
  db.add_token 'hello', '1', '2'
  token, secret = db.get_token 'hello'
  puts "token = #{token}, secret = #{secret}"
end
