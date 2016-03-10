# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
EmailService::Application.config.secret_key_base = 'b51291bb246953bf8f149403fb57b22a41af60ff859f92a05e907e1302da78efb9b237742fcbf3df514e290b840908dd4aa15ef93abe8585f1c622a8c412adda'
