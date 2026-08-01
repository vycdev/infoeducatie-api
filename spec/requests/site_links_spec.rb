require "rails_helper"

RSpec.describe "Site links API", type: :request do
  it "includes active links in the current-site payload" do
    create(:site_link, slug: "discord", url: "https://discord.gg/example")

    get "/v1/current.json"

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to include(
      "site_links" => {"discord" => "https://discord.gg/example"}
    )
  end

  it "omits inactive links" do
    create(:site_link, slug: "discord", active: false)

    get "/v1/current.json"

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to include("site_links" => {})
  end

  it "allows administrators to manage links in the dashboard" do
    sign_in create(:admin_user)
    create(:site_link, slug: "discord", url: "https://discord.gg/example")

    get "/internal/admin/site_link"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("discord", "https://discord.gg/example")
  end
end
