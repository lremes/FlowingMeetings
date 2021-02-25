class Participant < ApplicationRecord
    scope :permitted, -> { where(permitted: true) }
    belongs_to :meeting

    has_many :ballots, dependent: :destroy

    validates :name, presence: true
    validates :token, presence: true

    def generate_identifier
        self.token = 6.times.map{rand(10)}.join
    end

    def generate_rejoin_code
        self.rejoin_code = 6.times.map{rand(10)}.join
    end
end
