require "rails_helper"

RSpec.describe SiteLink, type: :model do
  it "accepts a complete HTTPS destination" do
    expect(build(:site_link, url: "https://discord.gg/example")).to be_valid
  end

  it "rejects non-web destinations" do
    expect(build(:site_link, url: "javascript:alert(1)")).not_to be_valid
  end
end
