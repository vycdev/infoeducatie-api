FactoryBot.define do
  factory :site_link do
    sequence(:slug) { |number| "site-link-#{number}" }
    url { "https://example.com/community" }
    active { true }
  end
end
