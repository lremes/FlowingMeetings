class VotingsController < ApplicationController
  def new
    respond_to do |format|
      format.html {
        @voting = Voting.new
      }
    end
  end

  def create
    respond_to do |format|
      format.html {
        begin
          get_meeting()
          @voting = Voting.new(voting_params)
          @voting.meeting_id = @meeting.id
          @voting.save!

          redirect_to edit_voting_path(@voting.id)
        rescue => ex
          handle_exception(request, ex, _('Failed to create voting.'))
          render action: 'new' and return
        end
      }
    end
  end

  def edit
    respond_to do |format|
      format.html {
        get_voting()
        @voting_option = VotingOption.new
      }
    end
  end

  def update
    respond_to do |format|
      format.html {
        get_voting()
        @voting.update!(voting_params)
        @voting_option = VotingOption.new
        render action: 'edit' and return
      }
    end
  end

  def add_default_options
    respond_to do |format|
      format.html {
        begin
          get_voting()
          [ N_('For'), N_('Against'), N_('Abstain') ].each do |opt_name|
            voting_option = VotingOption.new(text: _(opt_name))
            voting_option.voting = @voting
            voting_option.save!
          end

          redirect_to edit_voting_path(@voting.id) and return
        rescue => ex
          handle_exception(request, ex, _('Failed to create voting.'))
          render action: 'edit' and return
        end
      }
    end
  end

  def destroy
    respond_to do |format|
      format.js {
        get_voting()
        @voting.destroy! if @voting.present?
      }
    end
  end

  def destroy_option
    respond_to do |format|
      format.js {
        get_voting()
        get_voting_option()
        @voting_option.destroy! if @voting_option.present?
      }
    end
  end

  def create_option
    respond_to do |format|
      format.html {
        begin
          get_voting()
          @voting_option = VotingOption.new(voting_option_params)
          @voting_option.voting = @voting
          @voting_option.save!

          redirect_to edit_voting_path(@voting.id)
        rescue => ex
          handle_exception(request, ex, _('Failed to create voting.'))
          render action: 'edit' and return
        end
      }
    end
  end

  def votes
    respond_to do |format|
      format.html {
        begin
          get_voting()
        rescue => ex
          handle_exception(request, ex, _('Failed to show cast votes.'))
          redirect_to manage_meeting_path()
        end
      }
    end
  end

  private

  def get_meeting
    @meeting = Meeting.find_by_id(session[:meeting_id])
  end

  def get_voting
    get_meeting()
    @voting = @meeting.votings.where(id: params[:voting_id]).first
  end

  def get_voting_option
    @voting_option = @voting.voting_options.where(id: params[:option_id]).first
  end

  def voting_params
    params.require(:voting).permit(:text, :voting_type, :secret)
  end

  def voting_option_params
    params.require(:voting_option).permit(:text)
  end
end
