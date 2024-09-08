# frozen_string_literal: true

class SubscriptionMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.subscription_mailer.payment_failed.subject
  #
  def payment_failed
    @user = params[:user]

    mail to: @user.email, subject: "Hi #{@user.profile.first_name || @user.email}, your payment attempt failed"
  end

  def subscription_created
    @user = params[:user]

    mail to: @user.email, subject: "Your subscription is active"
  end
end
