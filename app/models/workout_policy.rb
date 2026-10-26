# == Value Object Representation
#
# WorkoutPolicy represents workout policy choices as a dual bitmask:
# - values: bitmask storing boolean flags (1 = true, 0 = false)
# - mask: bitmask storing whether each flag is explicitly set/overridden (1 = set, 0 = inherit)
#
# Bitmask Layout (12 flags):
#  bit 0  (1):    hide_compilation_feedback_before_finish
#  bit 1  (2):    hide_feedback_before_finish
#  bit 2  (4):    hide_feedback_in_review_before_close
#  bit 3  (8):    hide_score_before_finish
#  bit 4  (16):   hide_score_in_review_before_close
#  bit 5  (32):   hide_thumbnails_before_start
#  bit 6  (64):   hide_thumbnails_in_review_before_close
#  bit 7  (128):  invisible_before_review
#  bit 8  (256):  no_faq
#  bit 9  (512):  no_hints
#  bit 10 (1024): no_review_before_close
#  bit 11 (2048): see_answers
#
class WorkoutPolicy
  FLAGS = {
    hide_compilation_feedback_before_finish: 1 << 0,
    hide_feedback_before_finish:             1 << 1,
    hide_feedback_in_review_before_close:    1 << 2,
    hide_score_before_finish:                1 << 3,
    hide_score_in_review_before_close:       1 << 4,
    hide_thumbnails_before_start:            1 << 5,
    hide_thumbnails_in_review_before_close:  1 << 6,
    invisible_before_review:                 1 << 7,
    no_faq:                                  1 << 8,
    no_hints:                                1 << 9,
    no_review_before_close:                  1 << 10,
    see_answers:                             1 << 11
  }.freeze

  ALL_FLAGS_MASK = (1 << FLAGS.size) - 1 # 4095
  DEFAULT_VALUES = FLAGS[:see_answers]   # 2048 (see_answers: true, others: false)
  DEFAULT_MASK   = ALL_FLAGS_MASK        # 4095

  attr_accessor :values, :mask

  # -------------------------------------------------------------
  def initialize(values_or_attrs = nil, mask = nil)
    if values_or_attrs.is_a?(Hash)
      @values = DEFAULT_VALUES
      @mask = DEFAULT_MASK
      update(values_or_attrs)
    elsif values_or_attrs.nil? && mask.nil?
      @values = DEFAULT_VALUES
      @mask = DEFAULT_MASK
    else
      @values = values_or_attrs.to_i
      @mask = mask.nil? ? DEFAULT_MASK : mask.to_i
    end
  end

  # -------------------------------------------------------------
  # Dynamic getters, setters, and predicates for each flag
  FLAGS.each do |name, bit|
    define_method(name) do
      if (@mask & bit) != 0
        (@values & bit) != 0
      else
        (DEFAULT_VALUES & bit) != 0
      end
    end

    define_method("#{name}?") do
      send(name)
    end

    define_method("#{name}=") do |val|
      if val.nil? || val == ''
        @mask &= ~bit
        @values &= ~bit
      else
        @mask |= bit
        if val == true || val == 1 || val == '1' || val == 'true' || val == :true
          @values |= bit
        else
          @values &= ~bit
        end
      end
    end
  end

  # -------------------------------------------------------------
  def overridden?(name)
    bit = FLAGS[name.to_sym]
    return false unless bit
    (@mask & bit) != 0
  end

  # -------------------------------------------------------------
  def raw_value(name)
    bit = FLAGS[name.to_sym]
    return nil unless bit && (@mask & bit) != 0
    (@values & bit) != 0
  end

  # -------------------------------------------------------------
  def update(attrs)
    return self unless attrs.is_a?(Hash)
    attrs.each do |k, v|
      setter = "#{k}="
      send(setter, v) if respond_to?(setter)
    end
    self
  end

  # -------------------------------------------------------------
  # Combine child overrides onto a parent policy
  def merge_child(child_values, child_mask)
    c_val = child_values.to_i
    c_msk = child_mask.to_i
    new_val = (c_val & c_msk) | (@values & ~c_msk)
    new_msk = @mask | c_msk
    WorkoutPolicy.new(new_val, new_msk)
  end

  # -------------------------------------------------------------
  def dup
    WorkoutPolicy.new(@values, @mask)
  end

  # -------------------------------------------------------------
  def ==(other)
    other.is_a?(WorkoutPolicy) && @values == other.values && @mask == other.mask
  end

  # -------------------------------------------------------------
  def to_h
    FLAGS.keys.each_with_object({}) do |flag, hash|
      hash[flag] = send(flag)
    end
  end

  # -------------------------------------------------------------
  def as_json(options = nil)
    to_h.stringify_keys
  end

  # -------------------------------------------------------------
  def persisted?
    true
  end

  # -------------------------------------------------------------
  def id
    nil
  end

  # -------------------------------------------------------------
  class << self
    def default
      new(DEFAULT_VALUES, DEFAULT_MASK)
    end

    def unconfigured
      new(0, 0)
    end

    def create!(attrs = {})
      policy = new
      policy.update(attrs) if attrs.present?
      policy
    end

    def find(*args)
      default
    end
  end
end
