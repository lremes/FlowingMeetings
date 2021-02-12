class Voting < ApplicationRecord
    belongs_to :meeting

    has_many :votes, dependent: :destroy

    has_many :voting_options, dependent: :destroy

    validates :text, presence: true

    enum voting_type: { single: 0, multiple: 1 }
end
