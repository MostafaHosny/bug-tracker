class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
	def self.get_channel
  		mq_channel =Rails.application.config.rabbitmq_channel
  	end
end
