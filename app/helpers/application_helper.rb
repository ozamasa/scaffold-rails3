# encoding: utf-8
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # 改行⇒<br>
  def hbr(str)
    return if str.blank?
    str = html_escape(str)
    str = hbr_without_escape(str)
  end

  # 改行⇒<br>
  def hbr_without_escape(str)
    return if str.blank?
    str.gsub(/\r\n|\r|\n/, "<br />\n")
  end

  # 名称表示
  def hname(obj)
    unless obj.blank?
      begin
        return raw obj.name_with_id
      rescue
        return raw obj.name
      end
    end
  end

  # 日付表示
  def hdate(obj, options = {})
    format = "%Y/%m/%d" #:default
    format = options[:format] unless options[:format].blank?
    I18n.l obj, :format => format unless obj.blank?
  end

  # 日時表示
  def hdatetime(obj, options = {})
    format = "%Y/%m/%d %H:%M:%S"
    format = options[:format] unless options[:format].blank?
    hdate(obj, :format => format)
  end

  # 金額表示
  def hmoney(obj, options = {})
    number_to_currency obj unless obj.blank?
  end

  # ラベル表示
  def hlabel(obj, method, options = {})
    label_tag method, I18n.t(method, :scope => [:activerecord, :attributes, obj]), class: options[:class]
  end

  # タイトル表示
  def htitle(method)
    I18n.t(method, :scope => [:activerecord, :models])
  end

  # ラジオ表示
  def hradio(obj, method, value, datas)
    str = ""
    datas.each {|o|
      str += "<label>" + obj.radio_button(method, o.id, {:checked => (o.id == value)}) + o.name +  "</label>&nbsp;&nbsp;"
    }
    str
  end

  # 年コンボ表示
  def hselect_year(method)
    thisyear = Date.today()
    fromyear = thisyear << 60
    toyear   = thisyear >> 60

    y = Hash.new()
    (fromyear.year..toyear.year).each do |i|
      y[i] = i;
    end
    year = y.sort

    value = params[:selectyear]
    str  = select_tag(:selectyear,  "<option value=''></option>" + options_from_collection_for_select(year,  :first, :last , value.to_i), :onchange => sanitize("javascript:submit('#{method}', this.form, 'GET')"))
    str += "&nbsp;&nbsp;年&nbsp;&nbsp;"
    str
  end

  # 月コンボ表示
  def hselect_month(method)
    m = Hash.new()
    (1..12).each do |i|
      m[i] = i
    end
    month = m.sort

    value = params[:selectmonth]
    p value
    str  = select_tag(:selectmonth, "<option value=''></option>" + options_from_collection_for_select(month, :first, :last , value.to_i), :onchange => sanitize("javascript:submit('#{method}', this.form, 'GET')"))
    str += "&nbsp;&nbsp;月&nbsp;&nbsp;"
    str
  end

  # 時間コンボ表示
  def hselect_hour(obj, method, value)
    h = Hash.new()
    (0..23).each do |i|
      h[i] = i
    end
    hour = h.sort

    str  = obj.select method, hour, {:include_blank => true}
    str += " 時"
    str
  end

  # Suggest
  def suggest_field_tag(f, field, values, options = {})
    size = options[:size] unless options[:size].blank?

    str  = ""
    str += f.text_field field, {:autocomplete => 'off', :size => size}
    str += "\n  <div id='#{field}_suggest' class='suggest' style='display:none;'></div>\n"

    list = ""
    values.each_with_index do |value, i|
      list += (i==0 ? "":",") + "\"#{value}\""
    end

content_for :head do
concat <<"EOS"
function start_#{field}_suggest() {
var suggest =  new Suggest.Local(
    "#{f.object_name}_#{field}",
    "#{field}_suggest",
    [#{list}],
    {dispMax: 10, highlight: true});
}
window.addEventListener ? window.addEventListener('load', start_#{field}_suggest, false) : window.attachEvent('onload', start_#{field}_suggest);
EOS
end

    return raw str
  end

  # Ajax
  def remote(controller, action, options = {})
    position = options[:position] unless options[:position].blank?
    with = options[:with] unless options[:with].blank?
    with = "''" if with.blank?
js = <<"EOS"
var with_param = '';
if(obj != null){
  with_param += 'id=' + obj.options[obj.selectedIndex].value;
}
with_param += #{with};
EOS
    js + remote_function(:url => {:controller => controller, :action => action }, :with => "with_param", :update => (controller.to_s + "_" + action.to_s), :position => position)
  end

  # ページタイトル
  def pagetitle(options = {})
    title = options[:title] || htitle(controller.controller_name.singularize.to_sym)

    str =<<"EOS"
<div class="page-header">
  <div class="row">
    <div class="col-lg-12">
    <h1>#{title}</h1>
    </div>
  </div>
</div>
EOS
    return raw str
  end

  # タブ
  def tab_tag(tab_id)
    current_path = url_for(:controller => :tab, :action => :index)

    jsstr =<<"EOS"
function change_tab(val){
  ref('#{current_path}?tab=' + val);
}
EOS

    content_for :head do
      jsstr
    end

    str = "<div id=\"tab\"><ul>"
    Tab.all.each{|obj|
      current = ""
      current = "current" if obj.id.to_s == tab_id.to_s
      path = link_to(raw("<span>" + obj.name.to_s + "</span>"), raw("javascript:change_tab('" + obj.id.to_s + "');"))
      str += "<li class=\"" + current + "\">" + path + "</li>"
    }

    str += "</ul></div>"

    return raw str
  end

  # 必須マーク
  def required
    return if show?
    "required"
  end

  # 必須入力メッセージ文言
  def required_notice_tag(options = {})
    return if show?

    str =<<"EOS"
<p><font color="red">*</font>印のついた項目は、必ず入力してください。</p>
EOS
    return raw str
  end

  # フラッシュ
  def flash_tag
    unless flash[:error].blank?
    e =<<"EOS"
<div class="row">
<div class="col-lg-12">
  <button type="button" class="close" data-dismiss="alert">&times;</button>
  <div class="alert alert-dismissable alert-warning">
  #{hbr(flash[:error])}
  </div>
</div>
</div>
EOS
    end

    unless flash[:notice].blank?
    n =<<"EOS"
<div class="row">
<div class="col-lg-12">
  <button type="button" class="close" data-dismiss="alert">&times;</button>
  <div class="alert alert-dismissable alert-info">
  #{hbr(flash[:notice])}
  </div>
</div>
</div>
EOS
    end

    flash.clear
    return raw "#{e}#{n}"
  end

  # ワーニング
  def warning_tag(obj)
    if obj.errors.any?
    str =<<"EOS"
<div class="row">
<div class="col-lg-12">
  <button type="button" class="close" data-dismiss="alert">&times;</button>
  <div class="alert alert-dismissable alert-danger">
    <strong>次の項目を確認してください。</strong>
    <ul>
    #{obj.errors.full_messages.join("<br>")}
    </ul>
  </div>
</div>
</div>
EOS
    end

    return raw str
  end

  # 検索
  def search_tag(options = {})
    text_keyword  = text_field_tag(:keyword, params[:keyword], :class => 'form-control')
    hidden_sort   = hidden_field_tag(:sort,  params[:sort])
    hidden_order  = hidden_field_tag(:order, params[:order])
    other_tag     = options[:other] unless options[:other].blank?
    tab           = tab_tag(options[:tab]) unless options[:tab].blank?

    controller    = options[:controller] || controller_name
    action        = options[:action]     || "index"

    search_form   = 'form_search'
    search_path   = url_for(:controller => controller, :action => action)
    search_button = link_to button_tag('検索', :class=>'btn btn-primary'), sanitize("javascript:submit('#{search_path}', '#{search_form}', 'GET')")

    str =<<"EOS"
  <div class="well">
  <form name="#{search_form}" class="form-search">
    <fieldset>
    <div class="form-group">
    #{tab}
    </div>
    <div class="form-group">
      <div class="input-group">
      #{text_keyword}
      #{hidden_sort}
      #{hidden_order}
      <span class="input-group-btn">
      #{search_button}
      #{refrech_button_tag}
      #{other_tag}
      </span>
      </div>
    </div>
    </fieldset>
  </form>
  </div>
EOS
    return raw str
  end

  # 検索用プルダウンタグ
  def search_select_tag(name, object, path)
    select_tag(name, "<option value=''></option>" + options_from_collection_for_select(object.all, :id, :name, params[name].to_i), :onchange => "javascript:submit('#{path}', this.form, 'GET')")
  end

  # 検索用チェックボックスタグ
  def search_check_tag(name, path, label)
    "&nbsp;&nbsp;" + check_box_tag(name, 1, params[name].to_i==1, :onclick => "javascript:submit('#{path}', this.form, 'GET')") + label + "&nbsp;&nbsp;"
  end

  # ソート
  def sort_tag(key)
    asc  = ! (!@app_search.blank? && @app_search.tag_sort == key && @app_search.tag_order == 'asc' )
    desc = ! (!@app_search.blank? && @app_search.tag_sort == key && @app_search.tag_order == 'desc')
    sort_asc  = link_to_if asc,  '▲', sanitize("javascript:sort('#{key}','asc' );")
    sort_desc = link_to_if desc, '▼', sanitize("javascript:sort('#{key}','desc');")
    return raw sort_asc + ' ' + sort_desc
  end

  # 総件数
  def counter_tag(options = {})
    size = (options[:size] || @counter).to_i

    str =<<"EOS"
<ul class="pagination pagination"><li><span>#{size}件</span></li></ul>
EOS
    return raw str
  end

  # 一覧ページネートボタン
  def paginate_tag(obj)
    will_paginate obj, :previous_label => "&laquo;", :next_label => "&raquo;", renderer: BootstrapPagination::Rails
  end

  # アップロード
  def upload_tag(options = {})
    str =<<"EOS"
<div class="row">
  <div class="col-lg-12">
    <div class="well">
    <h4>#{hlabel(:commons, :upload_file)}</h4>
#{form_tag :action => :upload, :multipart => true, :method => :post, :class=>"form-horizontal"}
    <fieldset>
      <p class="help-block">
      インポートするファイルは「CSV出力」で出力したファイルを編集してください。<br>
      データを新規登録する場合は「ID」列を空白にしてください。<br>
      </p>
      <div class="form-group">
      <div class="input-group">
#{file_field_tag(:file)}
      <span class="input-group-btn">
#{link_to button_tag("インポート", :type => :submit, :class=> "btn btn-primary", :confirm => "インポートしますか？")}
      </span>
      </div>
      </div>
    </fieldset>
</form>
    </div>
  </div>
</div>
EOS
    return raw str
  end

  # 参照画面？
  def show?
    return action_name == :show.to_s
  end

  # リセットボタン
  def refrech_button_tag
    link_to button_tag('戻す', class: "btn btn-default", type: :button), {action: :index}
  end

  # 新規作成ボタン
  def new_button_tag(options = {})
    value      = options[:value]      || "新規作成"
    controller = options[:controller] || controller_name
    action     = options[:action]     || :new
    params     = options[:params]

    link_to button_tag(value, class: "btn btn-primary pull-right", style: "margin: 21px  1px", type: :button ), {controller: controller, action: action}
  end

  # 編集ボタン
  def edit_button_tag(options = {})
    value      = options[:value]      || "編集"
    controller = options[:controller] || controller_name
    action     = options[:action]     || :edit

    link_to button_tag(value, class: "btn btn-primary", type: :button ), {controller: controller, action: action, id: params[:id]}
  end

  # 削除ボタン
  def delete_button_tag(obj, options = {})
    value      = options[:value]      || "削除"
    controller = options[:controller] || controller_name
    confirm    = options[:conf] || "削除してもよろしいですか？"

    link_to button_tag(value, class: "btn btn-alert pull-right"), obj, {controller: controller, method: :delete}, {confirm: confirm}
  end

  # 一覧ボタン
  def index_button_tag(options = {})
    value      = options[:value]      || "戻る"
    controller = options[:controller] || controller_name
    action     = options[:action]     || :index
    confirm    = options[:confirm]

    link_to button_tag(value, class: "btn btn-default", type: :button ), {controller: controller, action: action}, {confirm: confirm}
  end

  # 送信ボタン
  def submit_button_tag(options = {})
    return edit_button_tag if show?
    value = "作成する" if action_name == :check.to_s
    value = "作成する" if action_name == :new.to_s
    value = "作成する" if action_name == :create.to_s
    value = "修正する" if action_name == :confirm.to_s
    value = "修正する" if action_name == :edit.to_s
    value = "修正する" if action_name == :update.to_s
    value    ||= options[:value]      || "修正する"
    controller = options[:controller] || controller_name
    confirm    = options[:confirm]

    button_tag(value, class: "btn btn-primary", type: :submit ,confirm: confirm)
  end

  # ポップ
  def pop_button_tag(path, size, elm, type, options = {})
    link_to button_tag("検索", class: "btn btn-default"), "javascript:popSearch('" + path + "','" + size.to_s + "','" + elm + "','','" + type + "');"
  end

  # 検索ポップアップ
  def pop_search_tag(elm, type)
    pop_button_tag('/search', 750, elm, type)
  end

  # CSV出力ボタン
  def csv_button_tag(options = {})
    out = false
    return unless options[:out].blank?

    value      = options[:value]      || "CSV出力"
    controller = options[:controller] || controller_name
    action     = options[:action]     || :index
    confirm    = options[:confirm]    || "CSVを出力しますか？"

    url = url_for(params.merge(params))
    url = url_for(params.merge(:format => :csv))
    link_to button_tag(value, class: "btn btn-default pull-right", style: "margin: 21px 1px"), url, {confirm: confirm, target: '_blank'}
  end

  # 帳票出力ボタン
  def report_button_tag(options = {})
    out = false
    return unless options[:out].blank?

    value      = options[:value]      || "帳票出力"
    controller = options[:controller] || controller_name
    action     = options[:action]     || :index
    confirm    = options[:confirm]    || "帳票を出力しますか？"

    url = url_for(params.merge(params))
    link_to button_tag(value, class: "btn btn-default pull-right", style: "margin: 21px 1px"), url, {confirm: confirm, target: '_blank'}
  end

  # 閉じるボタン
  def close_button_tag(options = {})
    link_to button_tag("閉じる", class: "btn btn-default"), "javascript:windowClose()"
  end

  # カレンダー選択値クリアボタン
  def clear_cal_button_tag(options = {})
    button_to_function("クリア", "showCalClearBtn(this)", :class => "clearCalBtn")
  end
end
