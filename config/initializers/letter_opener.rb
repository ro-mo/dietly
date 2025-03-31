# Configure letter_opener to use the default Windows browser
if Rails.env.development?
  Launchy.configure do |config|
    config.browser = :default
    config.application = "cmd.exe /c start"
  end
end 