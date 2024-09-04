# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Admin.create!(email: "admin@admin.com", password: "123123", password_confirmation: "123123")
User.create!(email: "matheus@user.com", password: "123123", password_confirmation: "123123")
User.create!(email: "marcos@user.com", password: "123123", password_confirmation: "123123")
User.create!(email: "lucas@user.com", password: "123123", password_confirmation: "123123")
User.create!(email: "joao@user.com", password: "123123", password_confirmation: "123123")
User.create!(email: "pedro@user.com", password: "123123", password_confirmation: "123123")
User.create!(email: "paulo@user.com", password: "123123", password_confirmation: "123123")
User.create!(email: "thiago@user.com", password: "123123", password_confirmation: "123123")
