# frozen_string_literal: true

# Load the Rails application.
require_relative "application"
Rails.logger = Logger.new($stdout)
# Initialize the Rails application.
Rails.application.initialize!
