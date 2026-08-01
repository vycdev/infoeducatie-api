class ContentPage < ActiveRecord::Base
  validates :slug,
    presence: true,
    uniqueness: true,
    format: {with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/}
  validates :title, presence: true
  validates :body, presence: true

  with_options if: :english_content_present? do
    validates :title_en, presence: true
    validates :body_en, presence: true
  end

  scope :active, -> { where(active: true) }

  def localized_title(locale)
    english_locale?(locale) ? title_en.presence || title : title
  end

  def localized_body(locale)
    english_locale?(locale) ? body_en.presence || body : body
  end

  def to_s
    title
  end

  rails_admin do
    label "Content page"
    label_plural "Content pages"
    navigation_label "Community"

    list do
      field :title
      field :slug
      field :active
      field :updated_at
    end

    edit do
      field :slug do
        help "Stable public identifier. Use lowercase letters, numbers and hyphens."
      end
      field :title do
        label "Title (Romanian)"
      end
      field :title_en do
        label "Title (English)"
        help "Optional. Romanian content is used when the English translation is blank."
      end
      field :body do
        partial :form_rich_text_editor
        label "Body (Romanian)"
        help "Formatted Romanian page content. Images are uploaded securely when attached."
      end
      field :body_en do
        partial :form_rich_text_editor
        label "Body (English)"
        help "Optional formatted English page content."
      end
      field :active do
        help "Inactive pages remain in the dashboard but are hidden from the public API."
      end
    end
  end

  private

  def english_content_present?
    title_en.present? || body_en.present?
  end

  def english_locale?(locale)
    locale.to_s.downcase.start_with?("en")
  end
end
