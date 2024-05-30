class Tweet < Description
   validates :text, format: { with: /\A[а-яёa-z\-_]+\z/ }, if: :present?
end
