class ManagementNotificationsChannel < ApplicationCable::Channel
  # Called when the consumer has successfully
  # become a subscriber to this channel.
  def subscribed
    @meeting = Meeting.find_by_admin_password(params[:meeting])
    logger.debug(@meeting)
    stream_for @meeting
  end
end