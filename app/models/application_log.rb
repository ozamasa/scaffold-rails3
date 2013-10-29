# encoding: utf-8
class ApplicationLog

  def create(log, atr, id)
    log.new(atr => id, :note => "新規作成").save!
  end

  def update(log, atr, data, model)
    data.changes.each do |k, v|
      unless k == "lock_version"
        unless v[0].blank? && v[1].blank?

          # Change id to name
          if k == "sample_id"
            v[0] = Sample.find(v[0]).name rescue nil
            v[1] = Sample.find(v[1]).name rescue nil
            end
          end

          log.new(atr => data.id, :note => "#{ApplicationController.helpers.hlabel(model, k)} の「#{v[0]}」を「#{v[1]}」に変更").save!
        end
      end
    end
  end

end
