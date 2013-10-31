# encoding: utf-8
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  require 'active_support_csv'
  require 'will_paginate/array'
  require "will_paginate-bootstrap"

  before_filter :authorize

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

#  rescue_from Exception, :with => :error

protected
  def error(e)
    logger.error(e)
    flash[:error] = t(:error_default, :message => e)
    begin
      if action_name == :index.to_s
        reset_session
        redirect_to(login_url)
        return
      end
      redirect_to(:action => :index)
    rescue
      redirect_to(top_url)
    end
  end

  def authorize
    begin
      raise unless session[:user_id]
      @app_user = User.find(session[:user_id])
      raise unless @app_user
      @app_search = ApplicationSearch.new(params) if action_name == :index.to_s
    rescue => e
      logger.error(e.message)
      flash[:notice] = t(:error_authorize)
      session_reset
      redirect_to(root_url)
    end
  end

  def session_reset
    session[:user_id] = nil
    reset_session
  end
end
