require 'rails_helper'

RSpec.describe("Order Fullfillment") do
  it "merchant employee can fulfill an order" do
    user = create(:user)
    user.role = 1

    mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
    meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)

    MerchantEmployee.create!(user: user, merchant: mike)

    tire = meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 2, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
    paper = mike.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 3)
    pencil = mike.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 2)
    highlighter = mike.items.create(name: "Pink Highlighter", description: "all the color!", price: 1, image: "http://t0.gstatic.com/images?q=tbn%3AANd9GcTJXpxn5ri-bUeoz3mQ9On7c2PfvL3Ku-ilDUAJ0gv4_0HkUFJBQuriTsUw2yxofI0bSGLbXN4O&usqp=CAc", inventory: 2)

    order = Order.create!(name: "Kelly", address: "2233 Nothing st", city: "Nowhere", state: "NO", zip: "12345")

    order.items << tire
    order.items << paper
    order.items << pencil
    order.items << highlighter
    order.items << highlighter
    order.items << highlighter

    visit "/merchant/orders/#{order.id}"

    #someone elses shop
    within "#item-#{tire.id}" do
      expect(page).to_not have_link("Fulfill Item")
    end

    #already fulfilled
    within "#item-#{pencil.id}" do
      expect(page).to_not have_link("Fulfill Item")
      expect(page).to have_content('Fulfilled')
    end

    # ordered more than current inventory
    within "#item-#{highlighter.id}" do
      expect(page).to_not have_link("Fulfill Item")
    end

    #can be fulfilled
    within "#item-#{paper.id}" do
      click_on("Fulfill Item")
    end

    expect(current_path).to eq("/merchant/orders/#{order.id}")

    #order is now fulfilled
    within "#item-#{paper.id}" do
      expect(page).to_not have_link("Fulfill Item")
      expect(page).to have_content('Fulfilled')
    end

    expect(page).to have_content("#{paper.name} on order #{order.id} is now fulfilled")

    expect(pencil.inventory).to eq(1)
  end

# #   it "changes order status to packaged when all orders have been fulfilled" do
    # @mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
    # @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
    # @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
    # @paper = @mike.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 3)
    # @pencil = @mike.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)
    #
    # visit "/items/#{@paper.id}"
    # click_on "Add To Cart"
    # visit "/items/#{@paper.id}"
    # click_on "Add To Cart"
    # visit "/items/#{@tire.id}"
    # click_on "Add To Cart"
    # visit "/items/#{@pencil.id}"
    # click_on "Add To Cart"
    #
    # visit "/cart"
    #
    # click_on "Checkout"
    #
    # fill_in :name, with: "Cassie"
    # fill_in :address, with: "1234 nothing st"
    # fill_in :city, with: "Nowhere"
    # fill_in :state, with: "BA"
    # fill_in :zip, with: "89874"
    # click_on("Create Order")
#
#
# #     When all items in an order have been "fulfilled" by their merchants
# # The order status changes from "pending" to "packaged"
#   end
end
