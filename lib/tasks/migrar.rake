namespace :migrar do
  desc 'migra las preguntas de archivos a la base de datos'
  task preguntas: :environment do
    original_log_level = ActiveRecord::Base.logger.level
    ActiveRecord::Base.logger.level = 1

    MasterQuestion.find_each do |question|
      begin
        randomizer = question.randomizer
        path = "#{Rails.root}/app/helpers/r/#{randomizer}.rb"
        question.randomizer = File.read(path)

        solver = question.solver
        path = "#{Rails.root}/app/helpers/s/#{solver}.rb"
        question.solver = File.read(path)

        question.save(validate: false)
      rescue => e
        puts question.id
        puts "An exception occurred: #{e.message}"
      end
    end

    ActiveRecord::Base.logger.level = original_log_level
  end
end
