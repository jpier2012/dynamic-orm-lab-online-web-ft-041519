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
    hash.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  self.attr_accessor.each do |attr|
    attr_accessor attr.to_sym
  end
  
end
