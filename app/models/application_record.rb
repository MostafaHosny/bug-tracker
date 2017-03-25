class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
	def self.get_channel
		rabbitmq_conn = Bunny.new(:host => "rabbit1" , :port => 5672)
		#start the connection 
		rabbitmq_conn.start
		# create new chanel with send data with diffrent quues 
		rabbitmq_channel = rabbitmq_conn.create_channel
  		mq_channel =rabbitmq_channel
  	end
end
