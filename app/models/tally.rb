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
        return 'N/A' if total <= 0
        (self.votes / total) * 100.0
    end

    def add(vote, amount)
        self.votes += amount
    end
end