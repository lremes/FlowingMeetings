module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :participant

    def connect
    end
  end
end
