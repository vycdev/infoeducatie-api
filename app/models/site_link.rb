class SiteLink < ActiveRecord::Base
  validates :slug,
    presence: true,
    uniqueness: true,
    format: {with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/}
  validates :url, presence: true
  validate :url_uses_http

  scope :active, -> { where(active: true) }

  def to_s
    slug.titleize
  end

  rails_admin do
    label "Site link"
    label_plural "Site links"
    navigation_label "Community"

    list do
      field :slug
      field :url
      field :active
      field :updated_at
    end

    edit do
      field :slug do
        help "Stable frontend identifier. Use lowercase letters, numbers and hyphens."
      end
      field :url do
        help "Full destination URL, including https://."
      end
      field :active do
        help "Inactive links are omitted from the public website."
      end
    end
  end

  private

  def url_uses_http
    parsed_url = URI.parse(url.to_s)
    return if parsed_url.is_a?(URI::HTTP) && parsed_url.host.present?

    errors.add(:url, "must be a complete HTTP or HTTPS URL")
  rescue URI::InvalidURIError
    errors.add(:url, "must be a complete HTTP or HTTPS URL")
  end
end
