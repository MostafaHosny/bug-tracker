require "bunny"

::Rabbitmq_conn = Bunny.new(:host => "rabbit1")
		#start the connection 
Rabbitmq_conn.start
	