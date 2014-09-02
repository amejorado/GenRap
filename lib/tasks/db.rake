namespace :db do
  namespace :data do
    desc 'Validates all records in the database'
    task validate: :environment do
      original_log_level = ActiveRecord::Base.logger.level
      ActiveRecord::Base.logger.level = 1

      puts 'Validate database (this will take some time)...'

      ActiveRecord::Base.connection.tables.each do |table|
        model_class = table.capitalize.singularize.camelize
        begin
          klass = Module.const_get(model_class)
          model_class = klass if klass.is_a?(Class)
        rescue NameError
          next
        end

        begin
          model_class.find_each do |record|
            next if record.valid?
            puts "#<#{ model_class } id: #{ record.id }," \
              " errors: #{ record.errors.full_messages }>"
          end
        rescue e
          puts "An exception occurred: #{ e.message }"
        end
      end

      ActiveRecord::Base.logger.level = original_log_level
    end
  end
end
