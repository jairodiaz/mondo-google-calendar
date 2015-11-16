# Mondo Hackathon

This example application loads your bank transactions into your Google Calendar.

## Screen shot

![Bank Transactions on Google Calendar](screen_shot.png?raw=true "Bank Transactions")

## Pre-requisites

1. Get a Mondo account so that you have a user name and password.
   Download the application from the Apple Store (once is published) and register.

2. Contact Mondo to get an OAuth client ID and secret for staging.

   Once you have the client id and secret, you can obtain an access token for a given user and password like this:
   ```
    http --form POST "https://api.getmondo.co.uk/oauth2/token"
        "grant_type=password"
        "client_id=$client_id"
        "client_secret=$client_secret"
        "username=$user_email"
        "password=$user_password"
    ```


    The access token should be configured in the .env file

3. To connect to Google Apps a special setup is required.
   Follow the guidelines from the Google Developer documentation:

   https://developers.google.com/google-apps/calendar/quickstart/ruby

   From the 'Google Developers console' download the client_secret.json file. The console is at:

   https://console.developers.google.com/

## Instructions

1. bundle install
2. ruby calendar_with_transactions

