class CreateInitialModels < ActiveRecord::Migration[6.1]
  def change
    create_table :meetings do |t|
      t.string :name, index: true
      t.text :meeting_information, index: true
      t.integer :retention_time_days, index: true
      t.string :admin_password
      t.string :passcode
      t.integer :active_voting_id, index: true, null: true
      t.timestamps
    end

    create_table :participants do |t|
      t.string :name, index: true
      t.integer :meeting_id, foreign_key: true, index: true
      t.string :token
      t.boolean :permitted, default: false, index: true
      t.integer :num_votes, default: 1, index: true
      t.datetime :time_of_leaving, null: true
      t.timestamps
    end

    create_table :votings do |t|
      t.text    :text, index: true
      t.boolean :secret, default: false, index: true
      t.integer :meeting_id, foreign_key: true, index: true
      t.integer :voting_type, null: false, default: 0, index: true
      t.time    :start_time 
      t.time    :end_time 
      t.timestamps
    end

    create_table :voting_options do |t|
      t.string  :text, index: true
      t.integer :voting_id, foreign_key: true, index: true
      t.timestamps
    end

    create_table :ballots do |t|
      t.integer :participant_id, foreign_key: true, null: false
      t.integer :voting_id, foreign_key: true, null: false
      t.boolean :submitted, default: false, null: false, index: true
      t.timestamps
    end

    create_table :votes do |t|
      t.integer :voting_id, foreign_key: true, null: false
      t.integer :ballot_id, foreign_key: true, null: true # for secret ballots
      t.integer :amount, default: 1, index: true
      t.timestamps
    end

    create_table :votes_voting_options do |t|
      t.integer :vote_id, foreign_key: true, null: false
      t.integer :voting_option_id, foreign_key: true, null: false
      t.timestamps
    end

  end
end
