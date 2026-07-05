require "open3"

module Dps
  # Будує заголовок Authorization для приватного API ДПС, підписуючи РНОКПП
  # файловим КЕП. Підпис ДСТУ 4145 накладається Node-скриптом lib/kep/sign.js
  # (чистого Ruby-аналога немає), результат — base64 CMS.
  class KepSigner
    def initialize(key_path:, cert_path:, password: nil, password_path: nil, script: nil)
      @key_path = key_path
      @cert_path = cert_path
      @password = password
      @password_path = password_path
      @script = script || Rails.root.join("lib/kep/sign.js").to_s
    end

    # Повертає значення заголовка Authorization для заданого РНОКПП.
    def authorization(rnokpp)
      # Node-підписувач запускається з chdir у lib/kep (щоб знайти node_modules),
      # тож шляхи до ключа/сертифіката/пароля робимо абсолютними (відносні — від cwd процесу Rails).
      env = {
        "DPS_KEY_PATH" => File.expand_path(@key_path.to_s),
        "DPS_CERT_PATH" => File.expand_path(@cert_path.to_s),
      }
      env["DPS_KEY_PASSWORD"] = @password if @password
      env["DPS_KEY_PASSWORD_PATH"] = File.expand_path(@password_path.to_s) if @password_path

      stdout, stderr, status = Open3.capture3(
        env, "node", @script, rnokpp.to_s, chdir: File.dirname(@script)
      )
      raise Error, "КЕП-підпис не вдався: #{stderr.presence || "код #{status.exitstatus}"}" unless status.success?

      stdout.strip
    end
  end
end
