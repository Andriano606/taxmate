require "rails_helper"

RSpec.describe Monobank::Client do
  subject(:client) { described_class.new(token: "T") }
  let(:base) { "https://api.monobank.ua" }

  let(:accounts_body) do
    {
      "name" => "Test",
      "accounts" => [
        { "id" => "usd1", "type" => "fop", "currencyCode" => 840 },
        { "id" => "uah1", "type" => "fop", "currencyCode" => 980 },
        { "id" => "black1", "type" => "black", "currencyCode" => 980 }
      ]
    }.to_json
  end

  it "sends the X-Token header and parses client info" do
    stub_request(:get, "#{base}/personal/client-info")
      .with(headers: { "X-Token" => "T" })
      .to_return(status: 200, body: accounts_body)
    expect(client.client_info["name"]).to eq("Test")
  end

  it "returns only FOP accounts" do
    stub_request(:get, "#{base}/personal/client-info").to_return(status: 200, body: accounts_body)
    expect(client.fop_accounts.map { |a| a["id"] }).to contain_exactly("usd1", "uah1")
  end

  it "builds the statement URL converting Time to unix seconds" do
    from = Time.utc(2026, 4, 1)
    to = Time.utc(2026, 5, 1)
    stub = stub_request(:get, "#{base}/personal/statement/usd1/#{from.to_i}/#{to.to_i}")
      .to_return(status: 200, body: "[]")
    client.statement(account: "usd1", from: from, to: to)
    expect(stub).to have_been_requested
  end

  it "returns only credits (amount > 0)" do
    body = [
      { "amount" => 195936, "counterName" => "Luca Labs As" },
      { "amount" => -160000, "description" => "conversion" }
    ].to_json
    stub_request(:get, %r{\A#{Regexp.escape(base)}/personal/statement/usd1/}).to_return(status: 200, body: body)
    credits = client.credits(account: "usd1", from: 1, to: 2)
    expect(credits.size).to eq(1)
    expect(credits.first["counterName"]).to eq("Luca Labs As")
  end

  it "raises Monobank::Error on a non-200 response" do
    stub_request(:get, "#{base}/personal/client-info").to_return(status: 429, body: "rate limited")
    expect { client.client_info }.to raise_error(Monobank::Error, /HTTP 429/)
  end
end
