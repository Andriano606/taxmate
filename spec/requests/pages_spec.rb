require "rails_helper"

RSpec.describe "Pages", type: :request do
  it "renders the hello world home page" do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Hello, world!")
    expect(response.body).to include('data-vue-component="HelloVue"')
    expect(response.body).to include('data-controller="hello"')
  end

  it "serves the Ukrainian locale" do
    get "/", params: { locale: "uk" }
    expect(response.body).to include("Привіт, світ!")
  end
end
