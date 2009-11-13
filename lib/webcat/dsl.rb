module Webcat
  class << self
    attr_writer :default_driver, :current_driver

    attr_accessor :app

    def default_driver
      @default_driver || :rack_test
    end

    def current_driver
      @current_driver || default_driver 
    end
    alias_method :mode, :current_driver

    def use_default_driver
      @current_driver = nil 
    end

    def current_session
      session_pool["#{current_driver}#{app.object_id}"] ||= Webcat::Session.new(current_driver, app)
    end

  private

    def session_pool
      @session_pool ||= {}
    end
  end

  extend(self)


  SESSION_METHODS = [
    :visit, :body, :click_link, :click_button, :fill_in, :choose,
    :set_hidden_field, :check, :uncheck, :attach_file, :select
  ]
  SESSION_METHODS.each do |method|
    class_eval <<-RUBY, __FILE__, __LINE__+1
      def #{method}(*args, &block)
        Webcat.current_session.#{method}(*args, &block)
      end
    RUBY
  end

end