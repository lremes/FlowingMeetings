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
        get_meeting()
      }
    end
  end

  def admin_login
    respond_to do |format|
      format.html {
        begin
          @meeting = Meeting.find_by_admin_password(params[:meeting_password])
          session[:meeting_id] = @meeting.id

          redirect_to manage_meeting_path()
        rescue => ex
          handle_exception(request, ex, _('Failed to login.'))
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
        end

        redirect_to manage_meeting_path() and return
      }
    end
  end

  def stop_voting
    respond_to do |format|
      format.html {
        get_meeting()
        @meeting.active_voting = nil
        @meeting.save!
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

  def join
    respond_to do |format|
      format.html {
        begin
          flash.clear
          if params[:meeting_code].present?
            @meeting = Meeting.where(passcode: params[:meeting_code]).first
            session[:participating_meeting_id] = @meeting.id
           redirect_to new_participant_path() and return
          end
        rescue => ex
          handle_exception(request, ex, _('Failed to join meeting.'))
          flash[:warning] = _('Invalid meeting code')
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
          @participant.meeting = @meeting
          @participant.generate_identifier
          @participant.save!

          session[:participant_id] = @participant.id

          redirect_to identify_participant_path()
        rescue => ex
          handle_exception(request, ex, _('Failed to create voting.'))
          render action: 'new_participant' and return
        end
      }
    end
  end

  def identify_participant
    respond_to do |format|
      format.html {
        get_participant()
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
          get_participant()
        rescue => ex
          handle_exception(request, ex, _('Failed to create voting.'))
          redirect_to manage_meeting_path() and return
        end
      }
    end
  end

  def leave
    respond_to do |format|
      format.html {
        begin
          get_participating_meeting()
          get_participant()
          @participant.time_of_leaving = Time.now
          @participant.save!
        rescue => ex
          handle_exception(request, ex, _('Failed to create voting.'))
          redirect_to manage_meeting_path() and return
        end
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
            unless @meeting.active_voting.anonymous?
              vote.ballot = ballot
            end # else we leave the ballot empty since this was an anonymous vote
            vote.voting_options << @voting.voting_options.where(id: vote_params[:option_ids])
            vote.save!
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
    @meeting = Meeting.find_by_id(session[:meeting_id])
  end

  def get_participating_meeting
    @meeting = Meeting.find_by_id(session[:participating_meeting_id])
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
