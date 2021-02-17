class Meeting < ApplicationRecord
    TOKEN_CHARS = ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a

    has_many :participants, dependent: :destroy
    has_many :votings, dependent: :destroy

    belongs_to :active_voting, class_name: 'Voting', optional: true

    validates :name, presence: true

    def generate_admin_token
        pwd = TOKEN_CHARS.sort_by { rand }.join[0...16]
        while Meeting.where(admin_password: pwd).exists? do
            pwd = TOKEN_CHARS.sort_by { rand }.join[0...16]
        end
        self.admin_password = pwd
    end

    def generate_passcode
        code = 10.times.map{rand(10)}.join
        while Meeting.where(passcode: code).exists? do
            code = 10.times.map{rand(10)}.join
        end
        self.passcode = code
    end

end
