module ActiveRecord::ConnectionAdapters
  module Jdbc
    # ActiveRecord connection pool callbacks for JDBC.
    # @see ActiveRecord::ConnectionAdapters::Jdbc::JndiConnectionPoolCallbacks
    module ConnectionPoolCallbacks

      def self.included(base)
        if base.respond_to?(:set_callback) # Rails 3 callbacks
          base.set_callback :checkin, :after, :on_checkin
          base.set_callback :checkout, :before, :on_checkout
        else
          base.checkin :on_checkin
          base.checkout :on_checkout
        end
      end

      def on_checkin
        # default implementation does nothing
      end

      def on_checkout
        # default implementation does nothing
      end

    end
    # JNDI specific connection pool callbacks that make sure the JNDI connection
    # is disconnected on check-in and looked up (re-connected) on-checkout.
    module JndiConnectionPoolCallbacks

      def self.prepare(adapter, connection)
        if adapter.is_a?(ConnectionPoolCallbacks) && connection.jndi?
          adapter.extend self # extend JndiConnectionPoolCallbacks
          #connection.disconnect! #if connection.open? # close initial (JNDI) connection
          connection.disconnect! if connection.open? # close initial (JNDI) connection
        end
      end

      def on_checkin
        puts "on_checkin\n  #{caller.join("\n  ")}"
        disconnect!
      end

      def on_checkout
        puts "on_checkout\n  #{caller.join("\n  ")}"
        reconnect!
      end
    end

  end
  # @deprecated use {ActiveRecord::ConnectionAdapters::Jdbc::ConnectionPoolCallbacks}
  JdbcConnectionPoolCallbacks = Jdbc::ConnectionPoolCallbacks
  # @deprecated use {ActiveRecord::ConnectionAdapters::Jdbc::JndiConnectionPoolCallbacks}
  JndiConnectionPoolCallbacks = Jdbc::JndiConnectionPoolCallbacks
end
