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
    
  end

end
