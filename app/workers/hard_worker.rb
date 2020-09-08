class HardWorker
  include Sidekiq::Worker

  def perform(name, count)
    puts "\nHallo, #{name} for the #{count}th time!\n\n"
  end
end
