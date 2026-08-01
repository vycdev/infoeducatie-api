class News < ActiveRecord::Base
  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 20 }
  validates :short, presence: true

  with_options if: :english_content_present? do
    validates :title_en, presence: true
    validates :body_en, presence: true, length: { minimum: 20 }
  end

  belongs_to :edition
  validates :edition, presence: true

  before_validation do
    self.short = ActionController::Base.helpers.strip_tags(self.body)[0..125]
  end

  def localized_title(locale)
    english_locale?(locale) ? title_en.presence || title : title
  end

  def localized_body(locale)
    english_locale?(locale) ? body_en.presence || body : body
  end

  def localized_short(locale)
    return short unless english_locale?(locale) && body_en.present?

    ActionController::Base.helpers.strip_tags(body_en)[0..125]
  end

  rails_admin do
    list do
      field :title
      field :short
      field :pinned
      field :created_at
      field :edition
    end
    edit do
      field :title
      field :title_en do
        label "Title (English)"
        help "Optional. Romanian content is used when the English translation is blank."
      end
      field :pinned
      field :edition
      field :body do
        partial :form_rich_text_editor
        label "Body (Romanian)"
        help "Formatted Romanian article content. Images are uploaded securely when attached."
      end
      field :body_en do
        partial :form_rich_text_editor
        label "Body (English)"
        help "Optional formatted English article content."
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
