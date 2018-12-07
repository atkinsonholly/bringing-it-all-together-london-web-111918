require 'pry'
require 'sqlite3'
DB = { :conn => SQLite3::Database.new('./dogs.db')}
DB[:conn].results_as_hash = true

class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    drop table dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
     sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = #{self.id}"
       DB[:conn].execute(sql, self.name, self.breed)
     else
       sql = <<-SQL
       INSERT INTO dogs (name, breed)
       VALUES (?, ?)
       SQL
       DB[:conn].execute(sql, self.name, self.breed)
     end
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
     self
  end

  def self.create(hash) #Dog.create(name: "Ralph", breed: "lab")
    dog = Dog.new(hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    hash = DB[:conn].execute("select * from dogs where id=?", id)[0]
    dog = Dog.new(id: hash[0], name: hash[1], breed: hash[2])
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("select * from dogs where name = ? and breed = ? limit 1", name, breed)
    if dog.empty?
      dog = Dog.create(name: name, breed: breed)
    else
      dog = Dog.new(id: dog[0][0], name: dog[0][1], breed: dog[0][2])
    end
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    new_dog = Dog.new(id: id, name: name, breed: breed)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs where name = ?"
    search_result = DB[:conn].execute(sql, name)
      found_dog = Dog.new(id: search_result[0][0],name: search_result[0][1], breed: search_result[0][2])
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = #{self.id}"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

end
