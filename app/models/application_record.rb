class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
	def self.get_channel
  		mq_channel = Rabbitmq_conn.create_channel   
  	end
end

