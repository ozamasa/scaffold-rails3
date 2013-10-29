# encoding: utf-8
class ApplicationCsv

  def write(alls, instance, options = {})
    require 'csv'
    require 'kconv'

    o_keys  = []
    o_names = []
    o_types = []

#    config = YAML.load_file("#{Rails.root}/config/database.yml")
#    case config[Rails.env]['adapter']
#    when 'sqlite3'
#    instance.columns.each{|column|
#      o_keys  << column.name
#      name = I18n.t(column.name, :scope => [:activerecord, :attributes, instance.to_s.singularize])   #ApplicationController.helpers.hlabel(:order, column.name)
#      name = I18n.t(column.name, :scope => [:activerecord, :attributes, :commons]) if name.index("translation missing") && name.index("translation missing").to_i >= 0
#      name = column.name if name.index("translation missing") && name.index("translation missing").to_i >= 0
#      o_names << name
#      o_types << column.type
#    }
#    when 'mysql'
    instance.columns.each{|column|
      o_keys  << column.name
      name = I18n.t(column.name, :scope => [:activerecord, :attributes, instance.table_name.singularize])   #ApplicationController.helpers.hlabel(:order, column.name)
      name = I18n.t(column.name, :scope => [:activerecord, :attributes, :commons]) if name.index("translation missing") && name.index("translation missing").to_i >= 0
      name = column.name if name.index("translation missing") && name.index("translation missing").to_i >= 0
      o_names << name
      o_types << column.type
    }
#    end

    CSV::Writer.generate(output = ""){|csv|
      alls.each_with_index{|all, i|
        if i == 0
          names = o_names unless o_names.blank?
          names = o_keys  if names.blank? and !o_keys.blank?
          names = all.attribute_names if names.blank?

          a0 = []
          names.each_with_index{|name, j|
            a0 << escape(name)
          }

          csv << a0
        end


        keys = o_keys unless o_keys.blank?
        keys = all.attribute_names if keys.blank?

        a1 = []
        keys.each_with_index{|key,j|
          s = ""
          begin
            s = escape(all.read_attribute(key), o_types[j])
            a1 << s
          rescue
            a1 << ""
          end
        }

        csv << a1
      }
    }
    output
  end

  def escape(s, type = :string)
    begin
      s = s.gsub(/\r\n|\r|\n/, " ")
      s = s.gsub('"', '""')
      s = Kconv.tosjis(s)
      s = '"' + s + '"' if s.index(",").blank?
    rescue
    end
    return s
  end

end
