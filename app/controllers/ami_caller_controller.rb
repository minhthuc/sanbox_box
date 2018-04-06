class AmiCallerController < ApplicationController
    before_action :init_ami, only: :show
    def show
        byebug
    end

    private
        def init_ami
            @client = Ari::Client.new(
                url: 'http://27.118.16.210:8088/ari',
                api_key: 'zammad:secret5',
                app: 'hello-world'
            )
        end
end
