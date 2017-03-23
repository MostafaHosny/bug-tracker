class Bug < ApplicationRecord
  has_one :state , dependent: :destroy

  #---------------------------------- Enums -----------------------------------
    STATUS = ['new' ,'In-progress', 'closed']
    enum priority: [:minor , :major , :critical]

    validates :number, uniqueness: { scope: :application_token }

  scope :with_token, ->(application_token) { where(application_token: application_token) }

    def self.insert_new_bug (bug_params , state_params ,application_token)
      bug = Bug.new(bug_params)
      bug.application_token = application_token
      bug.state = State.new(state_params)
      bug.number = (Bug.where(application_token: application_token ).maximum(:number) ||0) +1
      unless bug.save
        bug.increment(:number) 
        bug.save 
      end
        bug
    end

end
