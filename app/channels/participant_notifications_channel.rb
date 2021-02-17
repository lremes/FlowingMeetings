class ParticipantNotificationsChannel < ApplicationCable::Channel
  # Called when the consumer has successfully
  # become a subscriber to this channel.
  def subscribed
    @participant = Participant.find_by_id(params[:id])
    logger.debug(@participant)
    stream_for @participant
  end
end