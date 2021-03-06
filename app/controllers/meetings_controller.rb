class MeetingsController < ApplicationController
  def new
    respond_to do |format|
      format.html {
        @meeting = Meeting.new
      }
    end
  end

  def manage
    respond_to do |format|
      format.html {
        begin
          flash.clear
          get_meeting()
        rescue => ex
          handle_exception(request, ex, _('Failed to sign in.'))
          flash[:error] = ex.message
          redirect_to new_meeting_path() and return
        end
      }
    end
  end

  def admin_login
    respond_to do |format|
      format.html {
        begin
          @meeting = Meeting.find_by_admin_password(params[:meeting_password])
          if @meeting.nil?
            flash[:error] = _('Meeting not found.')
            not_found #redirect_to join_meeting_path() and return      
          end
          session[:meeting_id] = @meeting.id

          redirect_to manage_meeting_path()
        rescue => ex
          handle_exception(request, ex, _('Failed to sign in.'))
          @meeting = Meeting.new
          render action: 'new' and return
        end
      }
    end
  end

  def admin_logout
    respond_to do |format|
      format.html {
        session.delete(:meeting_id)
        redirect_to new_meeting_path()
      }
    end
  end

  def create
    respond_to do |format|
      format.html {
        begin
          @meeting = Meeting.new(meeting_params)
          @meeting.generate_admin_token
          @meeting.generate_passcode
          @meeting.save!

          session[:meeting_id] = @meeting.id

          redirect_to manage_meeting_path()
        rescue => ex
          handle_exception(request, ex, _('Failed to create meeting.'))
          render action: 'new' and return
        end
      }
    end
  end

  def start_voting
    respond_to do |format|
      format.html {
        get_meeting()
        voting = @meeting.votings.where(id: params[:voting_id]).first
        @meeting.active_voting = voting
        @meeting.save!

        # remove all ballots and votes
        @meeting.active_voting.ballots.destroy_all
        @meeting.active_voting.votes.destroy_all

        # TODO create ballots for current participants
        @meeting.participants.reject { |p| p.time_of_leaving.present? }.each do |p|
          ballot = Ballot.new
          ballot.participant = p
          ballot.voting = @meeting.active_voting
          ballot.submitted = false
          ballot.save!

          ParticipantNotificationsChannel.broadcast_to p, { message: "voting_started" }          
        end

        redirect_to manage_meeting_path() and return
      }
    end
  end

  def stop_voting
    respond_to do |format|
      format.html {
        get_meeting()

        # send meeting ended notification
        @meeting.active_voting.ballots.each do |b|
          ParticipantNotificationsChannel.broadcast_to b.participant, { message: "voting_ended" }          
        end

        @meeting.active_voting = nil
        @meeting.save!

        ParticipantNotificationsChannel.broadcast_to p, { message: "refresh" }          

        redirect_to manage_meeting_path() and return
      }
    end
  end

  def update
    respond_to do |format|
      format.html {
        get_meeting()
        @meeting.update!(meeting_params)
        render action: :manage and return
      }
    end
  end

  def destroy
    respond_to do |format|
      format.html {
        begin
          get_meeting()
          @meeting.destroy! if @meeting.present?
        rescue => ex
        ensure
          session.delete(:meeting_id)
        end
        redirect_to new_meeting_path() and return
      }
    end
  end

  def destroy_participant
    respond_to do |format|
      format.html {
        begin
          get_meeting()
          p = @meeting.participants.find_by_id(params[:participant_id])
          p.destroy! if p.present?
          ParticipantNotificationsChannel.broadcast_to p, { message: "removed" }
        rescue => ex
        ensure
          session.delete(:meeting_id)
        end
        redirect_to new_meeting_path() and return
      }
    end
  end

  def participants
    respond_to do |format|
      format.js {
        get_meeting()
      }
    end
  end

  def votings
    respond_to do |format|
      format.js {
        get_meeting()
      }
    end
  end

  def join
    respond_to do |format|
      format.html {
        begin
          if (session[:meeting_password].present?)
            redirect_to manage_meeting_path() and return
          end
  
          if (session[:participating_meeting_id].present?)
            redirect_to participate_path() and return
          end
  
          if params[:meeting_code].present?
            @meeting = Meeting.where(passcode: params[:meeting_code]).first

            raise _('Invalid meeting code') if @meeting.nil?

            session[:participating_meeting_id] = @meeting.id
            redirect_to new_participant_path() and return
          end
        rescue => ex
          handle_exception(request, ex, _('Failed to join meeting.'))
          flash[:warning] = ex.message
          render action: 'join' and return
        end
      }
    end
  end

  def new_participant
    respond_to do |format|
      format.html {
        @participant = Participant.new
      }
    end
  end

  def add_participant
    respond_to do |format|
      format.html {
        begin
          get_participating_meeting()

          @participant = Participant.new(participant_params)

          if @meeting.participants.where(name: @participant.name).first.present?
            @participant.errors.add(:name, _("Name '%{name}' is already taken. Please choose another name.") % { name: participant_params[:name] })
            render action: 'new_participant' and return
          end
          @participant.meeting = @meeting
          @participant.generate_identifier
          @participant.generate_rejoin_code
          @participant.save!

          session[:participant_id] = @participant.id

          ManagementNotificationsChannel.broadcast_to @meeting, { message: "new_participant" }

          redirect_to identify_participant_path()
        rescue => ex
          handle_exception(request, ex, ex.message)
          render action: 'new_participant' and return
        end
      }
    end
  end

  def rejoin_meeting
    respond_to do |format|
      format.html {
        begin
          @participant = Participant.find_by_rejoin_code(params[:rejoin_code])
          if @participant.present?
            if @participant.time_of_leaving.present?
              flash[:warning] = _('You have already left the meeting and cannot rejoin. You need rejoin the meeting entering the meeting code.')
              redirect_to join_meeting_path() and return
            end
            session[:participant_id] = @participant.id
            session[:participating_meeting_id] = @participant.meeting_id

            ManagementNotificationsChannel.broadcast_to @meeting, { message: "participant_rejoined" }

            redirect_to participate_path() and return
          end
        rescue => ex
          handle_exception(request, ex, ex.message)
          render action: 'join' and return
        end          
      }
    end
  end

  def identify_participant
    respond_to do |format|
      format.html {
        get_participant()
        if @participant.blank?
          flash[:error] = _('No participant information was found. Maybe you have been removed from the meeting?')
          redirect_to join_meeting_path() and return
        end

        if @participant.permitted?
          redirect_to participate_path() and return
        end
      }
    end
  end

  def permit_participant
    respond_to do |format|
      format.html {
        @participant = Participant.find_by_id(params[:participant_id])
        @participant.permitted = true
        @participant.save!

        ParticipantNotificationsChannel.broadcast_to @participant, { message: "refresh" }

        redirect_to manage_meeting_path() and return
      }
    end
  end

  def update_participant
    respond_to do |format|
      format.html {
        begin
          @participant = Participant.find_by_id(params[:participant_id])
          @participant.update!(participant_params)
          redirect_to manage_meeting_path() and return
        rescue => ex
          handle_exception(request, ex, _('Failed to create voting.'))
          redirect_to manage_meeting_path() and return
        end
      }
    end
  end

  def participate
    respond_to do |format|
      format.html {
        begin
          get_participating_meeting()
          if @meeting.blank?
            logger.warn('No meeting information was found.')
            flash[:error] = _('No meeting information was found.')
            redirect_to join_meeting_path() and return
          end

          get_participant()
          logger.debug(@participant.inspect)
          if @participant.blank?
            logger.warn('No participant information was found.')
            flash[:error] = _('No participant information was found. Maybe you have been removed from the meeting?')
            redirect_to join_meeting_path() and return
          else
            if @participant.time_of_leaving.present?
              reset_session
              redirect_to join_meeting_path() and return
            end
          end

        rescue => ex
          handle_exception(request, ex, _('Failed to participate in meeting.'))
          redirect_to join_meeting_path() and return
        end
      }
    end
  end

  def leave
    respond_to do |format|
      format.html {
        begin
          get_participating_meeting()
          if @meeting.blank?
            flash[:error] = _('No meeting information was found. Maybe it has already been removed?')
            redirect_to join_meeting_path() and return
          end

          get_participant()
          if @participant.blank?
            flash[:error] = _('No participant information was found. Maybe you have been removed from the meeting?')
            redirect_to join_meeting_path() and return
          end

          @participant.time_of_leaving = Time.now
          @participant.save!
          ManagementNotificationsChannel.broadcast_to @meeting, { message: "participant_left" }
          reset_session
        rescue => ex
          handle_exception(request, ex, _('Failed to leave meeting.'))
        end
        redirect_to '/' and return
      }
    end
  end

  def submit_vote
    respond_to do |format|
      format.html {
        begin
          get_participating_meeting()
          get_participant()
          
          @voting = @meeting.active_voting

          if @voting.nil?
            flash[:error] = _('Voting is not active.')
            redirect_to participate_path() and return
          end

          ballot = @voting.ballots.where(participant_id: @participant.id).first
          if ballot.nil?
            flash[:error] = _('You are not allowed to participate in this vote.')
            redirect_to participate_path() and return
          end
          if ballot.submitted == true
            flash[:error] = _('You have already submitted your vote.')
            redirect_to participate_path() and return
          else
            ballot.submit!
            logger.debug("Ballot submitted: #{ballot.inspect}")

            vote = Vote.new
            vote.voting = @voting
            vote.amount = @participant.num_votes
            unless @meeting.active_voting.secret?
              vote.ballot = ballot
            end # else we leave the ballot empty since this was an secret ballot
            vote.voting_options << @voting.voting_options.where(id: vote_params[:option_ids])
            vote.save!

            ManagementNotificationsChannel.broadcast_to @meeting, { message: "new_vote" }
          end

          redirect_to participate_path() and return
        rescue => ex
          handle_exception(request, ex, _('Failed to create voting.'))
          redirect_to participate_path() and return
        end
      }
    end
  end

  private

  def get_participant
    @participant = Participant.find_by_id(session[:participant_id])
  end

  def get_meeting
    raise _('You are not signed in into a meeting.') if session[:meeting_id].blank?
    @meeting = Meeting.find_by_id(session[:meeting_id])
    if @meeting.nil? 
      session.delete(:meeting_id)
      flash[:warning] = _('Meeting not found.')
      not_found #redirect_to join_meeting_path() and return
    end
  end

  def get_participating_meeting
    @meeting = Meeting.find_by_id(session[:participating_meeting_id])
    if @meeting.nil?
      session.delete(:participating_meeting_id)
    end
  end

  def meeting_params
    params.require(:meeting).permit(:name, :start_time)
  end

  def participant_params
    params.require(:participant).permit(:name, :num_votes)
  end

  def vote_params
    params.require(:vote).permit(option_ids: [])
  end

end
