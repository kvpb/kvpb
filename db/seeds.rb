#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its
#	documentation for any purpose and without fee is hereby granted, provided that
#	the above copyright notice appear in all copies and that both that copyright
#	notice and this permission notice appear in supporting documentation, and that
#	the name of Karl Vincent Pierre Bertin not be used in advertising or publicity
#	pertaining to distribution of the software without specific, written prior
#	permission. Karl Vincent Pierre Bertin makes no representations about the
#	suitability of this software for any purpose.  It is provided "as is" without
#	express or implied warranty.

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

setting = Setting.current
setting.regenerate_login_token if setting.login_token.blank?
puts "Sign-in URL: #{Rails.application.routes.url_helpers.new_session_url( token: setting.login_token, host: Rails.application.config.action_mailer.default_url_options&.dig( :host ) || "localhost:3000" )}"

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

user = User.find_or_initialize_by( email_address: superuser_credentials[ :email_address ] )
user.username = superuser_credentials[ :username ]
user.password = superuser_credentials[ :password ] if user.new_record?
user.superuser = true
user.save!

#	seeds.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
