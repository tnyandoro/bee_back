# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order
    fixtures :all

    # Generate auth token for user in tests
    def generate_token_for(user)
      user.auth_token || "mock_token_#{user.id}"
    end

    # Mock ActionCable to prevent real broadcasts in tests
    module ActionCable
      module Channel
        class Base
          def self.broadcast_to(*_args)
            # No-op in test environment
          end
        end
      end
    end

    # Mock ActionMailer to prevent real email deliveries in tests
    module ActionMailer
      class MessageDelivery
        def deliver_later
          # No-op in test environment
        end
        def deliver_now
          # No-op in test environment
        end
      end
    end

    # Mock Notification.create! to prevent real database writes in tests
    class Notification
      def self.create!(*_args)
        # Simulate successful creation without hitting the database
        OpenStruct.new(id: rand(1..1000), **_args.first)
      end
    end

    # Mock Ticket.update! to prevent real database updates in tests
    class Ticket
      def update!(*_args)
        # Simulate successful update
        self
      end
    end
  end
end