# encoding: utf-8
class ApplicationUpload

  require 'csv'
  require 'kconv'

  attr_accessor :filename
  attr_accessor :content_type
  attr_accessor :size
  attr_accessor :data

  attr_accessor :ccnt
  attr_accessor :ucnt
  attr_accessor :ecnt
  attr_accessor :import_msg
  attr_accessor :error_msg
  attr_accessor :flag_new

  def initialize(file)
    if file
      begin
        @filename = file.original_filename.gsub(/[^\w!\#$%&()=^~|@`\[\]\{\};+,.-]/u, '')
        @content_type = file.content_type.gsub(/[^\w.+;=_\/-]/n, '')
        @size = file.size
        @data = file.read
      rescue
      end
    end
  end


  def to_a
    arrs = []
    begin
      CSV.parse(@data){|line|
        row = []
        line.each_with_index{|col,j|
          row << col
        }
        arrs << row
      }
    rescue
    end
    return arrs
  end


  def import(instance, instance2 = {}, instance3 = {})
    @ecnt = 0
    @ccnt = 0
    @ucnt = 0
    @error_msg = ""
    upload_msga  = []
    self.to_a.each_with_index{|row,i|
      if i > 0
        if row[1].blank?
          upload_msga << "[#{i}]" + "データが空白のためスキップしました。"
        else
          id = import_row(instance, row, i)
          upload_msga << @import_msg unless @import_msg.blank?
        end
      end
    }

#    upload_msgs = "\n" + upload_msga.join("\n") + "\n"
    upload_msgs = "#{@ccnt}件を追加しました。#{@ucnt}件を更新しました。#{@ecnt}件のエラーがありました。" + @error_msg
    Rails.logger.info "\nCSV import error (#{instance.name}):\n  #{@error_msg}\n\n" if @ecnt > 0
    return upload_msgs
  end

  def import_row(instance, row, i)
    upload_cols  = instance.columns
    exclude_cols = ["id", "lock_version", "created_at", "updated_at", "hashed_password", "salt"]

    id = 0
    @flag_new = false
    object = nil
    row.each_with_index{|data,j|
      data = data.to_s.kconv(Kconv::UTF8, Kconv::SJIS)
      if j == 0
        begin
          id = data.to_i
          object = instance.find(id)
        rescue
          id = 0
          @flag_new = true
          object = instance.new
          upload_cols.each{|col|
            if exclude_cols.index(col.name).blank?
              object[col.name] = ""
              object[col.name] = 0  if col.type.to_s == "integer"
            end
          }
        end

      else
        begin
          if exclude_cols.index(upload_cols[j].name).blank?
            begin
              object[upload_cols[j].name] = data
            rescue
              object[upload_cols[j].name] = ""
            end
          end
        rescue
        end

        if j == (upload_cols.size - 1) or j == (row.size - 1)
          if object.invalid?
            @error_msg += "\n[#{i}] #{object.errors.full_messages.to_s}"
            @ecnt += 1
          end

          if object.save
            id = object.id
            begin
              object_name = object.name_with_id
            rescue
              begin
                object_name = sprintf("%s : %s", object.id, object.name)
              rescue
                object_name = object.id.to_s
              end
            end
            @import_msg = "[#{i}]" + object_name + (@flag_new ? "を追加しました。" : "を更新しました。")
            @ccnt += 1 if     @flag_new
            @ucnt += 1 unless @flag_new
          end
        end
      end
    }
    return id
  end

  def import_by_sql(table)
    msg = []
    col = []
    sql_header = ""
    sql = ""
    exd = ["id", "lock_version", "created_at", "updated_at"]

    self.to_a.each_with_index{|row,i|
      if i == 0
        sql_header = "insert into #{table} ("
        row.each_with_index{|data,j|
          if exd.index(data).blank?
            col << data
            sql_header += data  + ","
          end
        }
        sql_header = sql_header.slice(0, sql_header.size - 1)
        sql_header += ") values ("

      elsif i > 0
        sql = sql_header
        row.each_with_index{|data,j|
          if exd.index(data).blank?
            data = Kconv.toutf8(data.to_s)
            sql += "'" + data.gsub("'", " ") + "',"
          end
        }
        sql = sql.slice(0, sql.size - 1)
        sql += ")"

        begin
          ActiveRecord::Base.connection.execute(sql)
        rescue => e
          p e
        end

      end
    }
    return msg
  end

end
