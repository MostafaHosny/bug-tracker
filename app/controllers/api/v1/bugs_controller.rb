module Api::V1
  class BugsController < ApiController
        before_action :set_token, only: [:create , :show]
      # GET /v1/bugs
      
      def create
      mq_channel = ApplicationRecord.get_channel
            bug_queue  = mq_channel.queue("insert_new_bug", :auto_delete => true)
            exchange = mq_channel.default_exchange
            bug_queue.subscribe do |delivery_info, metadata, payload| 
              bug_params, state_params , app_token = JSON.parse payload
              @bug = Bug.insert_new_bug bug_params , state_params , app_token
            end
      exchange.publish([bug_params , state_params , @application_token ].to_json, :routing_key => 'insert_new_bug')
      render status: 201
      end

      def show
        bug = Bug.with_token(@application_token).find_by(number: params[:id])
        if bug
          render json: {bug: bug } , status: :ok
        else 
          render json: { error: 'not_found' }, status: 404
        end
      end


        def set_token
            @application_token = request.headers["token"]
            p @application_token 
            render json: { error: 'application token is missing' }, status: 422 unless @application_token
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