module Api::V1
	class BugsController < ApiController

    	# GET /v1/bugs
    	def index
      		render json: Bug.all
    	end

    	def create
    		
    		STDOUT.sync = true
			conn = Bunny.new
			conn.start
			ch = conn.create_channel
			q  = ch.queue("insert_new_bug", :auto_delete => true)
			x  = ch.default_exchange
			q.subscribe do |delivery_info, metadata, payload| 
			  b,s = JSON.parse payload
			   Bug.insert_new_bug b , s
			end
            
			x.publish([bug_params , state_params ].to_json, :routing_key => q.name)

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