class SellersController < ApplicationController
    before_action :set_sellers

    def index
    end

    def show
        @seller = @sellers.find { |s| s[:name] == params[:id] }
    end


    private 

    def set_sellers
        @sellers = [
            { name: "TechStore", location: "New York", rating: 4.5 },
            { name: "AudioWorld", location: "Los Angeles", rating: 4.0 },
            { name: "KeyMasters", location: "Chicago", rating: 4.2 },
            { name: "MouseMakers", location: "Houston", rating: 3.8 },
            { name: "DisplayTech", location: "San Francisco", rating: 4.7 }
        ]
    end

end