module ActionView
  module Helpers
    module FormHelper
      def label_with_ja(object_name, method, text = nil, options = {})
        if text.nil?
          text = I18n.t(method,              :default => method, :scope => [:activerecord, :attributes, object_name])
          text = I18n.t(method,              :default => method, :scope => [:activerecord, :attributes, "commons"])   if text.include?("translation missing:")
          text = I18n.t(method.to_s + "_id", :default => method, :scope => [:activerecord, :attributes, object_name]) if text.include?("translation missing:")
        end
        label_without_ja(object_name, method, text, options)
      end
      alias_method_chain :label, :ja  #:nodoc:
    end

    module DateHelper
      def date_select_with_options(object_name, method, options = {}, html_options = {})
        begin
          object = self.instance_variable_get("@#{object_name}")
          value = object.send(method)
          value = I18n.l(value)
        rescue
          value = nil
        end
        value = "" if value.blank?
        value = Date.today.strftime("%Y/%m/%d") if value.blank? && options[:today]
        options.merge!(:class     => 'ymd',
                       :size      => 14,
                       :maxlength => 10,
                       :readonly  => true,
                       :value     => value)
        text_field(object_name, method, options)
      end
      alias_method_chain :date_select, :options  #:nodoc:
    end
  end
end
