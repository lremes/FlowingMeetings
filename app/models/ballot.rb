class Ballot < ApplicationRecord
    scope :submitted, -> { where(submitted: true) }

    belongs_to :participant
    belongs_to :voting

    validates :participant, presence: true
    validates :voting, presence: true
    
    has_one :vote, dependent: :destroy

    def submit!
        self.submitted = true
        self.save!
    end
end
