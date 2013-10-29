# encoding: utf-8
class TabController < ApplicationController
  # GET /tab
  def index
    case params[:tab].to_i
    when 1
    when 2
    end
  end
end
