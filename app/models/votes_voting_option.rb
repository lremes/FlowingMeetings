class VotesVotingOption < ApplicationRecord
    belongs_to :vote
    belongs_to :voting_option
end