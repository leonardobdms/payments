namespace :doc do
  desc "Generate API documentation"
  task generate: :environment do
    ENV["RSWAG_DRY_RUN"] ||= "0"
    Rake::Task["rswag:specs:swaggerize"].invoke
  end
end
