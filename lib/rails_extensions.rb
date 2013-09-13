module PythyActiveRecordExtensions

  extend ActiveSupport::Concern

  # -------------------------------------------------------------
  def url_part_safe(value)
    value.downcase.gsub(/[^[:alnum:]]+/, '-').gsub(/-+$/, '')
  end

end

ActiveRecord::Base.send(:include, PythyActiveRecordExtensions)
