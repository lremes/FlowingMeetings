class VotingOption < ApplicationRecord
    belongs_to :voting
    validates :text, presence: true
end
