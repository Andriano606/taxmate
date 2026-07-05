require "rails_helper"

RSpec.describe Dps::Client do
  let(:auth) { "TEST-AUTH-TOKEN" }
  let(:base) { "https://cabinet.tax.gov.ua/ws/public_api" }
  subject(:client) { described_class.new(rnokpp: "3525511937", authorization: auth) }

  it "requires signer or authorization" do
    expect { described_class.new(rnokpp: "1") }.to raise_error(ArgumentError)
  end

  it "fetches debt, parses JSON and sends the Authorization header" do
    stub = stub_request(:get, "#{base}/ta/debt")
      .with(headers: { "Authorization" => auth, "Accept" => "application/json" })
      .to_return(status: 200, body: "[]")
    expect(client.debt).to eq([])
    expect(stub).to have_been_requested
  end

  it "fetches settlements for a year" do
    stub_request(:get, "#{base}/ta/splatp?year=2026")
      .to_return(status: 200, body: [{ "namePlt" => "ЄП", "debtAll" => 0 }].to_json)
    expect(client.settlements(year: 2026).first["debtAll"]).to eq(0)
  end

  it "fetches the declarations list" do
    stub_request(:get, "#{base}/reg_doc/list?periodYear=2026")
      .to_return(status: 200, body: { "content" => [{ "doc" => "F0103309" }] }.to_json)
    expect(client.declarations(year: 2026)["content"].first["doc"]).to eq("F0103309")
  end

  it "returns raw XML for a declaration" do
    xml = "<DECLAR><R006G3>291342.04</R006G3></DECLAR>"
    stub_request(:get, "#{base}/reg_doc/doc/2026/123/xml").to_return(status: 200, body: xml)
    expect(client.declaration_xml(year: 2026, cod_regdoc: 123)).to include("291342.04")
  end

  it "fetches sent and incoming documents" do
    stub_request(:get, "#{base}/post/sent?page=0").to_return(status: 200, body: { "content" => [] }.to_json)
    stub_request(:get, "#{base}/post/incoming?page=0").to_return(status: 200, body: { "content" => [] }.to_json)
    expect(client.sent_documents).to have_key("content")
    expect(client.incoming_documents).to have_key("content")
  end

  it "raises Dps::Error on a non-200 response" do
    stub_request(:get, "#{base}/payer_card").to_return(status: 401, body: "nope")
    expect { client.payer_card }.to raise_error(Dps::Error, /HTTP 401/)
  end

  it "signs on demand when only a signer is given" do
    signer = instance_double(Dps::KepSigner, authorization: "SIGNED")
    signing_client = described_class.new(rnokpp: "3525511937", signer: signer)
    stub_request(:get, "#{base}/ta/debt")
      .with(headers: { "Authorization" => "SIGNED" })
      .to_return(status: 200, body: "[]")
    expect(signing_client.debt).to eq([])
    expect(signer).to have_received(:authorization).with("3525511937")
  end
end
