class Url < ApplicationRecord
 validates :original_url, presence: true, format: URI::regexp(%w[http https])
 validates :short_url, presence: true, uniqueness: true
end
