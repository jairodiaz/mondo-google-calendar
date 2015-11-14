require 'dotenv'
Dotenv.load
require 'mondo'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'google/api_client/auth/storage'
require 'google/api_client/auth/storages/file_store'
require 'fileutils'
require 'pry'

# Mondo Initialization

mondo = Mondo::Client.new(
  token: ENV['MONDO_ACCOUNT_TOKEN']
)

mondo.api_url = "https://staging-api.gmon.io"

# Google Calendar Initialization

APPLICATION_NAME = 'mondo-google-calendar-client'
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "calendar-ruby-quickstart.json")
SCOPE = 'https://www.googleapis.com/auth/calendar'

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization request via InstalledAppFlow.
# If authorization is required, the user's default browser will be launched
# to approve the request.
#
# @return [Signet::OAuth2::Client] OAuth2 credentials
def authorize
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

  file_store = Google::APIClient::FileStore.new(CREDENTIALS_PATH)
  storage = Google::APIClient::Storage.new(file_store)
  auth = storage.authorize

  if auth.nil? || (auth.expired? && auth.refresh_token.nil?)
    app_info = Google::APIClient::ClientSecrets.load(CLIENT_SECRETS_PATH)
    flow = Google::APIClient::InstalledAppFlow.new({
      :client_id => app_info.client_id,
      :client_secret => app_info.client_secret,
      :scope => SCOPE})
    auth = flow.authorize(storage)
    puts "Credentials saved to #{CREDENTIALS_PATH}" unless auth.nil?
  end
  auth
end

# Initialize the API
client = Google::APIClient.new(:application_name => APPLICATION_NAME)
client.authorization = authorize
calendar_api = client.discovered_api('calendar', 'v3')

# Read transactions from the bank account and add to the calendar

mondo.transactions.each do |t|
  event_description = "#{t.description} for #{t.amount} #{t.currency}"
  event = {
    'summary' => event_description,
    'start' => {
      'dateTime' => t.created.to_s
    },
    'end' => {
      'dateTime' => (t.created + 0.01).to_s
    }
  }
  results = client.execute!(
    :api_method => calendar_api.events.insert,
    :parameters => {
      :calendarId => 'primary'},
    :body_object => event)
  event = results.data
  puts "Event created: #{event.inspect} #{event.htmlLink}"
end

puts 'Import of transactions to calendar events finalised'
