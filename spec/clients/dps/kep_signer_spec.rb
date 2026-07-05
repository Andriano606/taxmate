require "rails_helper"

RSpec.describe Dps::KepSigner do
  subject(:signer) do
    described_class.new(key_path: "/tmp/k.jks", cert_path: "/tmp/c.crt", password: "secret")
  end

  def status(success:, code: 0)
    instance_double(Process::Status, success?: success, exitstatus: code)
  end

  it "returns the stripped base64 authorization from the node signer" do
    allow(Open3).to receive(:capture3).and_return(["MIIbase64==\n", "", status(success: true)])
    expect(signer.authorization("3525511937")).to eq("MIIbase64==")
  end

  it "passes key/cert/password via ENV and the rnokpp as an argument" do
    captured = nil
    allow(Open3).to receive(:capture3) do |env, *cmd, **_opts|
      captured = { env: env, cmd: cmd }
      ["X", "", status(success: true)]
    end

    signer.authorization("3525511937")

    expect(captured[:env]).to include(
      "DPS_KEY_PATH" => "/tmp/k.jks",
      "DPS_CERT_PATH" => "/tmp/c.crt",
      "DPS_KEY_PASSWORD" => "secret"
    )
    expect(captured[:cmd]).to include("3525511937")
  end

  it "raises Dps::Error when the signer fails" do
    allow(Open3).to receive(:capture3).and_return(["", "bad key", status(success: false, code: 1)])
    expect { signer.authorization("1") }.to raise_error(Dps::Error, /bad key/)
  end
end
