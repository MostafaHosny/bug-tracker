module Api::V1
	class BugsController < ApiController

    	# GET /v1/bugs
    	def index
      		render json: Bug.all
    	end

    	def create
			mq_channel = ApplicationRecord.get_channel
            bug_queue  = mq_channel.queue("insert_new_bug", :auto_delete => true)
            exchange = mq_channel.default_exchange
            bug_queue.subscribe do |delivery_info, metadata, payload| 
              b,s = JSON.parse payload
              @bug = Bug.insert_new_bug b , s
            end
			exchange.publish([bug_params , state_params ].to_json, :routing_key => 'insert_new_bug')
			render status: :ok
    	end

    	def show
    		bug = Bug.with_token(params[:application_token]).find_by(number: params[:id])
    		if bug
    			render json: {bug: bug } , status: :ok
    		else 
    			render json: { error: 'not_found' }, status: 404
    		end
    	end

    	def bug_params
        params.require(:bug).permit(:application_token,
        	:status, :priority , :comment)
      	end
    	
    	def state_params
    		params.require(:state).permit(:device, :os, :storage, :memory)
  		end
  	end
end