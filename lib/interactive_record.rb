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
    sql = "PRAGMA table_info('#{self.table_name}')"
  end

end
