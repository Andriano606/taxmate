require 'net/http'
require 'json'

# Клієнт monobank Personal API — ТІЛЬКИ читання (рахунки та виписки).
# Порт логіки з колишнього Node-скрипта income.js.
#
# Приклад:
#   mono = Monobank::Client.new(token: ENV["MONOBANK_TOKEN"])
#   mono.fop_accounts
#   mono.credits(account: id, from: Time.zone.local(2026, 4, 1), to: Time.zone.local(2026, 7, 1))
#
# Ліміти API: виписка — не частіше 1 запиту/60с, діапазон — максимум 31 день.
class Monobank::Client
  BASE_URL = 'https://api.monobank.ua'.freeze

  def initialize(token:)
    @token = token
  end

  # Дані клієнта та список рахунків.
  def client_info
    get_json('/personal/client-info')
  end

  # Лише ФОП-рахунки.
  def fop_accounts
    client_info.fetch('accounts', []).select { |account| account['type'] == 'fop' }
  end

  # Виписка за період. from/to — Time або unix-секунди.
  def statement(account:, from:, to:)
    get_json("/personal/statement/#{account}/#{to_unix(from)}/#{to_unix(to)}")
  end

  # Лише надходження (зарахування, amount > 0) за період.
  def credits(account:, from:, to:)
    statement(account: account, from: from, to: to).select { |tx| tx['amount'].to_i.positive? }
  end

  private

  def to_unix(value)
    value.respond_to?(:to_i) ? value.to_i : value
  end

  def get_json(path)
    JSON.parse(get_body(path))
  end

  def get_body(path)
    uri = URI("#{BASE_URL}#{path}")
    request = Net::HTTP::Get.new(uri)
    request['X-Token'] = @token

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    unless response.code.to_i == 200
      raise Monobank::Error, "monobank GET #{path} -> HTTP #{response.code}"
    end

    response.body
  end
end
