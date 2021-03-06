require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    # first set the DB return values to hash
    DB[:conn].results_as_hash = true

    # next build the SQL query that will pull the column names from the table using PRAGMA
    sql = "PRAGMA table_info('#{table_name}')"

    # capture the table info hash containing column names
    table_info = DB[:conn].execute(sql)

    # store specifically the column names
    column_names = []

    # iterate through the table_info hash to add the column names to the column_names array
    table_info.each do |row|
      column_names << row["name"]
    end

    # remove nils from the array
    column_names.compact
  end

  def initialize(options = {})
    self.class.attr_accessors
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def self.attr_accessors
    self.column_names.each { |col_name| attr_accessor col_name.to_sym }
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(', ')
  end

  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
    VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM #{table_name}
    WHERE name = \'#{name}\'
    SQL

    DB[:conn].execute(sql)
  end

  def self.find_by(hash)
    sql = ""

    hash.each do |k, v|
      v = "\'#{v}\'" if v.is_a?(String)
      sql = <<-SQL
      SELECT *
      FROM #{table_name}
      WHERE #{k} = #{v}
      SQL
    end
    DB[:conn].execute(sql)
  end

end
