require "net/http"
require "json"

module Dps
  # Клієнт приватного API Електронного кабінету ДПС — ТІЛЬКИ читання інформації.
  # Порт логіки з колишніх Node-скриптів (check.js, decl.js).
  #
  # Приклад:
  #   signer = Dps::KepSigner.new(key_path:, cert_path:, password_path:)
  #   dps = Dps::Client.new(rnokpp: "3525511937", signer: signer)
  #   dps.debt
  #   dps.settlements(year: 2026)
  #
  # У тестах замість signer можна передати готовий authorization:.
  class Client
    BASE_URL = "https://cabinet.tax.gov.ua/ws/public_api".freeze

    def initialize(rnokpp:, signer: nil, authorization: nil)
      raise ArgumentError, "потрібен signer або authorization" if signer.nil? && authorization.nil?

      @rnokpp = rnokpp
      @signer = signer
      @authorization = authorization
    end

    # Податковий борг (порожній масив => боргу немає).
    def debt
      get_json("/ta/debt")
    end

    # Стан розрахунків з бюджетом за рік (масив по кожному податку).
    def settlements(year:)
      get_json("/ta/splatp?year=#{year}")
    end

    # Перелік поданих/зареєстрованих документів за рік.
    def declarations(year:)
      get_json("/reg_doc/list?periodYear=#{year}")
    end

    # Реєстраційна картка платника.
    def payer_card
      get_json("/payer_card")
    end

    # Вихідні документи (що надіслав платник).
    def sent_documents(page: 0)
      get_json("/post/sent?page=#{page}")
    end

    # Вхідні документи/листи від ДПС.
    def incoming_documents(page: 0)
      get_json("/post/incoming?page=#{page}")
    end

    # XML конкретної декларації (сирий рядок, windows-1251).
    def declaration_xml(year:, cod_regdoc:)
      get_body("/reg_doc/doc/#{year}/#{cod_regdoc}/xml")
    end

    private

    def authorization
      @authorization ||= @signer.authorization(@rnokpp)
    end

    def get_json(path)
      JSON.parse(get_body(path))
    end

    def get_body(path)
      uri = URI("#{BASE_URL}#{path}")
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = authorization
      request["Accept"] = "application/json"
      request["Content-Type"] = "application/json"

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      unless response.code.to_i == 200
        raise Error, "ДПС GET #{path} -> HTTP #{response.code}"
      end

      response.body
    end
  end
end
