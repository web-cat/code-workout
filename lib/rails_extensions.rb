# =============================================================================
module CodeWorkoutActiveRecordExtensions

  extend ActiveSupport::Concern

  # -------------------------------------------------------------
  def url_part_safe(value)
    value.downcase.gsub(/[^[:alnum:]]+/, '-').gsub(/-+$/, '')
  end

end

ActiveRecord::Base.send(:include, CodeWorkoutActiveRecordExtensions)

# =============================================================================
# Found at http://gist.github.com/3149393, modified for use here
class ChangeableValidator < ActiveModel::EachValidator
  # Enforce/prevent attribute change
  #
  # Example: Make attribute immutable once saved
  # validates :attribute, changeable: false, on: :update
  #
  # Example: Force attribute change on every save
  # validates :attribute, changeable: true

  def initialize(options)
    options[:changeable] = !(options[:with] === false)
    super
  end

  def validate_each(record, attribute, value)
    unless record.public_send(:"#{attribute}_changed?") == options[:changeable]
      record.errors.add(attribute,
        "#{options[:changeable] ? 'must' : 'cannot'} be modified")
    end
  end
end


# =============================================================================
# A wrapper for the <=> operator that handles nil arguments correctly,
# ordering them before non-nil objects.
def nil_safe_compare(a, b)
  if a.nil? && b.nil?
    0
  elsif a.nil?
    -1
  elsif b.nil?
    1
  else
    a <=> b
  end
end
