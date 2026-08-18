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

profile_photo_path = Rails.root.join( "db", "seed_assets", "profile_photo.jpg" )
if profile_photo_path.exist? && !setting.profile_photo.attached?
  setting.profile_photo.attach( io: File.open( profile_photo_path ), filename: "profile_photo.jpg", content_type: "image/jpeg" )
end

# Milestones aren't seeded: the timeline stays empty and hidden until Karl adds real ones himself
# through the (unlinked, superuser-only) milestones controller.

# Temporary placeholder content for inspecting the journal and print layouts while they're under
# construction. Remove both once the real design work on /read and /see/prints is done.
unless Article.exists?( headline: "Placeholder headline for layout testing" )
  Article.create!(
    kicker: "Placeholder kicker",
    headline: "Placeholder headline for layout testing",
    subheadline: "A placeholder subheadline sits here to check wrapping and spacing.",
    lede: "This lede is placeholder text, standing in for real copy so the journal typography can be inspected end to end.",
    body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n\nUt enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.\n\nExcepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
    published_at: Time.current
  )
end

print_sample_path = Rails.root.join( "db", "seed_assets", "print_sample.jpg" )
if print_sample_path.exist? && !Print.exists?( title: "Placeholder title for layout testing" )
  print = Print.create!( title: "Placeholder title for layout testing", published_at: Time.current )
  print.image.attach( io: File.open( print_sample_path ), filename: "print_sample.jpg", content_type: "image/jpeg" )
end

#	seeds.rb
#	kvpb.fr
#
#	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
#	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
#	local-part@domain
#
#	Copyright 2026 by Karl Vincent Pierre Bertin
#
#	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
