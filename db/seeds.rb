# Seeds для TaxMate через Oaken (модель — ApplyMate/db/seeds.rb).
#
# Oaken тягне файли з db/seeds/#{Rails.env}/ — по одному на набір даних.
# У кожному такому файлі доступний DSL за назвою таблиці, напр.:
#
#   # db/seeds/development/users.rb
#   users.create :andrii, unique_by: :email, email: "andrii@example.com", ...
#
# і тут вмикається порядок завантаження:  Oaken.loader.seed :users
#
# Доменних моделей у проєкті ще нема (лише Active Storage) — тож наборів поки
# немає. Додавай `Oaken.loader.seed :<набір>` нижче в міру появи моделей.
# Запуск:  bin/rails db:seed

require "benchmark"

time = Benchmark.realtime do
  # Oaken.loader.seed :users
end

puts "Time to create seeds: #{time.round(3)} seconds" # rubocop:disable Rails/Output
