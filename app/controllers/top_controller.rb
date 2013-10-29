# encoding: utf-8
class TopController < ApplicationController
  def index
    redirect_to samples_path
  end
end
