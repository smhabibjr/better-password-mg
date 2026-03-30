class ProductsController < ApplicationController
  before_action :set_products

  def index
  end

  def show
    @product = @products[params[:id].to_i]
  end

  private

  def set_products
    @products = [
      { name: "Laptop",      price: 999.99, stock: 5,  made_in: "USA"         , seller: "TechStore", seller_id: 0 },
      { name: "Headphones",  price: 79.99,  stock: 12, made_in: "Japan"       , seller: "AudioWorld", seller_id: 1 },
      { name: "Keyboard",    price: 49.99,  stock: 8,  made_in: "China"       , seller: "KeyMasters", seller_id: 2 },
      { name: "Mouse",       price: 29.99,  stock: 15, made_in: "Taiwan"      , seller: "MouseMakers", seller_id: 3 },
      { name: "Monitor",     price: 299.99, stock: 3,  made_in: "South Korea" , seller: "DisplayTech", seller_id: 4 }
    ]
  end
end
