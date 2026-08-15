# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

Setting.current

superuser_credentials = Rails.application.credentials.superuser

if superuser_credentials.blank?
  raise <<~MESSAGE
    Missing `superuser` credentials. Add them with:

      bin/rails credentials:edit

    and include:

      superuser:
        username: your_username
        email_address: you@example.com
        password: a-strong-password
  MESSAGE
end

user = User.find_or_initialize_by(email_address: superuser_credentials[:email_address])
user.username = superuser_credentials[:username]
user.password = superuser_credentials[:password] if user.new_record?
user.superuser = true
user.save!
