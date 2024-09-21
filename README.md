# README (Work in progress)

- Create/update products OK
- Create/update/cancel subscriptions OK
- User management OK
- Admin management OK

# Spec
* Ruby version
ruby 3.2.2 (2023-03-30 revision e51014f9c0) [x86_64-darwin17]
Rails 7.2.1

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Render
- Go to your web service page, find the Settings link. Go to "Custom Domains" section and type your custom domain.
- Follow the instructions to very your domain, this includes adding ALIAS and CNAME to your domain provider. Once you have this figured out, click on "verify" button.



## Emails
Devise send transaction emails (e.g reset your password) so you need to configure an email provider for production and a local SMTP server for development. Let's start with development environment.
#### Development environment
Install [Mailcatcher](https://mailcatcher.me/) to run a local SMTP server and catch all emails send to localhost.

1) install mailcatcher `gem install mailtacher`
2) run mailtcatcher on terminal by typing `mailtcatcher`
3) go to [http://127.0.0.1:1080/](http://127.0.0.1:1080/) so you can see emails sent through your local smtp server.

By default mailcatcher starts the SMTP server at `smtp://127.0.0.1:1025`. That port and address are already configured in `config/environments/development.rb`. Take a look:
```ruby

 config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
 config.action_mailer.delivery_method = :smtp
 config.action_mailer.smtp_settings = {
    address: "127.0.0.1",
    port: 1025
  }

```

Dont forget to change this values if you start mailcatcher with other configurations.

#### Production environment

#### Pre requisites:
- Have a domain. You can buy a domain on GoDaddy or other domain registry services.
- Choose an email provider like Mailgun, Postmark, Sendgrid yor any other you like. I suggest that you use [Resend](https://resend.com) because they have a fat free tier and is developer friendly.

Once you have a domain and a email provider, you need to link these two. To achieve this just follow the steps provided by your email provider.

The steps usually is to include records into your domain's DNS settings.

Once your domain is verified whitin your email provider, you need to find these informations: **SMTP address**, **SMTP port**, **username**, **password**, then add as enviroment variables to your webservice.

The environment variables should have the respective names:

```
SMTP_ADDRESS
SMTP_PORT
SMTP_USER_NAME
SMTP_PASSWORD
```

You also need to set a variable named `SMTP_DEFAULT_URL_HOST` with your domain. In my case, the domain is `sideprojectstarter.dev.br`. You should set to a domain that you own.

These environment variables are used in `config/environments/production.rb`. Take a look:
```ruby
 config.action_mailer.default_url_options = { host: ENV["SMTP_DEFAULT_URL_HOST"] }
 config.action_mailer.smtp_settings = {
    authentication: :plain,
    address: ENV["SMTP_ADDRESS"],
    port: ENV["SMTP_PORT"],
    user_name: ENV["SMTP_USER_NAME"],
    password: ENV["SMTP_PASSWORD"]
  }
```
If you are using [Render](https://render.com) to host your app, go to your web service dashboard, click on Environment link (left menu) and add the variables above. Don't forget to restart your server after this.

And if you are using another host, just find where to set environment variables.
