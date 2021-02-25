class Tally
    include ActiveModel::Model
    attr_accessor :id, :text, :votes, :total_votes

    def initialize(attributes={})
        super
    end

    def voting_option=(opt)
        self.id = opt.id
        self.text = opt.text
        self.votes = 0
    end

    def percentage(total)
        Rails.logger.debug(self.inspect)
        Rails.logger.debug(total)
        return 'N/A' if total <= 0
        (self.votes.to_f / total.to_f) * 100.0
    end

    def add(vote, amount)
        self.votes += amount
    end
end