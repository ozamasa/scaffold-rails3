# encoding: utf-8
class ApplicationSearch # < ActiveRecord::Base

  def initialize(params, options = {})
    @param_keyword = params[:keyword]
    @param_sort    = params[:sort]
    @param_order   = params[:order]

    @keyword       = '%' + @param_keyword.to_s.gsub('%', '\%').gsub('_', '\_').strip + '%'

    @keywords      = @param_keyword.to_s.gsub('%', '\%').gsub('_', '\_').gsub('　', ' ').strip.split(" ")
    @keywords.each_with_index{|keyword, i|
      @keywords[i] = "%#{keyword}%"
    }

    @sort          = 'id'
    @sort          = @param_sort unless @param_sort.blank?
    @order         = 'desc'
    @order         = 'asc' if @param_order == 'asc'

    @tag_sort      = @sort
    @tag_order     = @order
  end

  attr_accessor :param_keyword
  attr_accessor :param_sort
  attr_accessor :param_order

  attr_accessor :form
  attr_accessor :keyword
  attr_accessor :orderby

  attr_accessor :keywords
  attr_accessor :query
  attr_accessor :condition_query
  attr_accessor :condition_keyword
  attr_accessor :conditions

  attr_accessor :tag_sort
  attr_accessor :tag_order

  #attr_accessor :sort
  def sort
    @sort
  end
  def sort=(val)
    @sort = val  if val
    @orderby = "#{@sort.to_s} is null #{@order.to_s}, #{@sort.to_s} = '' #{@order.to_s}, #{@sort.to_s} #{@order.to_s}"
#    @orderby = @sort.to_s + ' ' + @order.to_s
  end

  #attr_accessor :order
  def order
    @order
  end
  def order=(val)
    @order = val if val
    @orderby = "#{@sort.to_s} is null #{@order.to_s}, #{@sort.to_s} = '' #{@order.to_s}, #{@sort.to_s} #{@order.to_s}"
#    @orderby = @sort.to_s + ' ' + @order.to_s
  end

  #attr_accessor :default_sort
  def default_sort
    @default_sort
  end
  def default_sort=(val)
    @default_sort = val if val
    @sort  = @tag_sort  = @default_sort  if @param_sort.blank?
  end

  #attr_accessor :default_order
  def default_order
    @default_order
  end
  def default_order=(val)
    @default_order = val if val
    @order = @tag_order = @default_order if @param_order.blank?
  end

  def sort(val, val2)
    self.sort = val2 if val == @sort
  end

  def default(sort, order)
    self.default_sort  = sort
    self.default_order = order
  end

  #attr_accessor :query
  def query
    @query
  end
  def query=(val)
    @query = val if val

    self.condition_query = ""
    self.condition_keyword = Array.new
    self.keywords.each{|keyword|
      self.condition_query += " and " unless self.condition_query.blank?
      self.condition_query += "(#{val})"
      self.query.count("?").times{
        self.condition_keyword << keyword
      }
    }

    self.conditions = Array.new
    self.conditions << self.condition_query
    self.conditions += self.condition_keyword
  end

end
