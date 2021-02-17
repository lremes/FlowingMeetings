Rails.application.routes.draw do
  get    '/', to: "meetings#join", as: 'join_meeting'
  post   'meetings/join', to: "meetings#join", as: 'enter_meeting'
  get    'meetings/participants/new', to: "meetings#new_participant", as: 'new_participant'
  post   'meetings/participants/', to: "meetings#add_participant", as: 'add_participant'
  get    'meetings/participants/identify', to: "meetings#identify_participant", as: 'identify_participant'
  patch  'meetings/participants/:participant_id', to: "meetings#update_participant", as: 'update_participant'
  get    'meetings/participate', to: "meetings#participate", as: 'participate'
  delete 'meetings/participants', to: "meetings#leave", as: 'leave_meeting'

  post   'meetings/participate/voting/submit', to: "meetings#submit_vote", as: 'submit_vote'

  get    '/', to: "meetings#vote", as: 'vote'

  get    'admin/', to: "meetings#new", as: 'new_meeting'
  post   'admin/login', to: "meetings#admin_login", as: 'admin_login'
  get    'admin/logout', to: "meetings#admin_logout", as: 'admin_logout'
  post   'admin/', to: "meetings#create", as: 'create_meeting'
  get    'admin/manage', to: "meetings#manage", as: 'manage_meeting'
  patch  'admin/', to: "meetings#update", as: 'update_meeting'
  delete 'admin', to: "meetings#destroy", as: 'destroy_meeting'
  get    'admin/participants/list', to: "meetings#participants", as: 'meeting_participants_list', constraints: { format: 'js' }
  get    'admin/votings/list', to: "meetings#votings", as: 'meeting_votings_list', constraints: { format: 'js' }

  get    'admin/voting/:voting_id/start', to: "meetings#start_voting", as: 'start_voting'
  get    'admin/voting/stop', to: "meetings#stop_voting", as: 'stop_voting'

  get    'admin/participants/:participant_id/permit', to: "meetings#permit_participant", as: 'permit_participant'
  delete 'admin/participants/:participant_id', to: "meetings#destroy_participant", as: 'destroy_participant'

  get    'admin/votings/new', to: "votings#new", as: 'new_voting'
  get   'admin/votings/:voting_id/votes', to: "votings#votes", as: 'votes'
  post   'admin/votings', to: "votings#create", as: 'create_voting'
  get    'admin/votings/:voting_id/edit', to: "votings#edit", as: 'edit_voting'
  patch  'admin/votings/:voting_id', to: "votings#update", as: 'update_voting'
  delete 'admin/votings/:voting_id', to: "votings#destroy", as: 'destroy_voting'

  post   'admin/votings/:voting_id/options', to: "votings#create_option", as: 'create_voting_option'
  patch  'admin/votings/:voting_id/options/:option_id', to: "votings#update_option", as: 'update_voting_option'
  delete 'admin/votings/:voting_id/options/:option_id', to: "votings#destroy_option", as: 'destroy_voting_option'

  get    'favicon.ico', to: 'assets#favicon'
	get    'favicon', to: 'assets#favicon'
	get    'robots.txt', to: 'assets#robots'
	get    'robots', to: 'assets#robots'

  get    'errors/not_found'
	get    'errors/internal_server_error'
	get    'errors/unauthorized', as: 'unauthorized'
	get    'errors/forbidden', as: 'forbidden'

  match "/404", :to => "errors#not_found", :via => :all
	match "/500", :to => "errors#internal_server_error", :via => :all
	match "/422", :to => "errors#unacceptable", :via => :all
	match "/401", :to => "errors#unauthorized", :via => :all
	match "/403", :to => "errors#forbidden", :via => :all

  root to: "meetings#join"
end
