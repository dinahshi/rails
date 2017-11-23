# frozen_string_literal: true

module ActiveRecord
  module ConnectionAdapters
    module PostgreSQL
      class SchemaCreation < AbstractAdapter::SchemaCreation # :nodoc:
        private
          def add_column_options!(sql, options)
            if options[:collation]
              sql << " COLLATE \"#{options[:collation]}\""
            end
            super
          end

          def visit_ColumnDefinition(o)
            o.sql_type = type_to_sql(o.type, o.options)
            column_sql = "#{quote_column_name(o.name)} #{o.sql_type}".dup
            add_column_options!(column_sql, column_options(o)) unless o.type == :primary_key
            column_sql
          end

          def visit_ChangeColumnDefinition(o)
            require "byebug"; byebug
            o = o.column
            o.sql_type = type_to_sql(o.type, o.options)
            column_sql = "#{quote_column_name(o.name)}".dup
            add_column_options!(column_sql, column_options(o)) unless o.type == :primary_key
            change_column_sql = "ALTER #{column_sql}".dup
            add_column_position!(change_column_sql, column_options(o))
          end

          def add_column_position!(sql, options)
            if options[:first]
              sql << " FIRST"
            elsif options[:after]
              sql << " AFTER #{quote_column_name(options[:after])}"
            end

            sql
          end
      end
    end
  end
end
