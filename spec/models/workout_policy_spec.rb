require 'spec_helper'

describe WorkoutPolicy do
  describe 'constants and flags' do
    it 'defines all 12 flags in FLAGS' do
      expected_flags = [
        :hide_compilation_feedback_before_finish,
        :hide_feedback_before_finish,
        :hide_feedback_in_review_before_close,
        :hide_score_before_finish,
        :hide_score_in_review_before_close,
        :hide_thumbnails_before_start,
        :hide_thumbnails_in_review_before_close,
        :invisible_before_review,
        :no_faq,
        :no_hints,
        :no_review_before_close,
        :see_answers
      ]
      expect(described_class::FLAGS.keys).to match_array(expected_flags)
    end

    it 'assigns unique powers of 2 for each flag' do
      bits = described_class::FLAGS.values
      expect(bits.size).to eq(12)
      expect(bits.uniq.size).to eq(12)
      bits.each do |b|
        expect(b & (b - 1)).to eq(0) # power of 2
      end
    end
  end

  describe 'defaults' do
    let(:policy) { described_class.new }

    it 'defaults see_answers to true and all other flags to false' do
      expect(policy.see_answers).to be true
      expect(policy.see_answers?).to be true
      expect(policy.invisible_before_review).to be false
      expect(policy.hide_feedback_before_finish).to be false
      expect(policy.no_review_before_close).to be false
    end

    it 'has default values 2048 and default mask 4095' do
      expect(policy.values).to eq(2048)
      expect(policy.mask).to eq(4095)
    end
  end

  describe 'flag setters and bit updates' do
    let(:policy) { described_class.new }

    it 'updates values and sets mask bit when turning a flag true' do
      policy.invisible_before_review = true
      expect(policy.invisible_before_review).to be true
      expect(policy.invisible_before_review?).to be true
      expect(policy.values & described_class::FLAGS[:invisible_before_review]).not_to eq(0)
      expect(policy.mask & described_class::FLAGS[:invisible_before_review]).not_to eq(0)
    end

    it 'updates values and sets mask bit when turning a flag false' do
      policy.see_answers = false
      expect(policy.see_answers).to be false
      expect(policy.values & described_class::FLAGS[:see_answers]).to eq(0)
      expect(policy.mask & described_class::FLAGS[:see_answers]).not_to eq(0)
    end

    it 'clears mask bit when setting to nil (unconfigured/inherit)' do
      policy.see_answers = nil
      expect(policy.overridden?(:see_answers)).to be false
      expect(policy.raw_value(:see_answers)).to be_nil
      # When unmasked, reading see_answers falls back to default true
      expect(policy.see_answers).to be true
    end

    it 'accepts string boolean values like "1" and "0"' do
      policy.hide_feedback_before_finish = '1'
      expect(policy.hide_feedback_before_finish).to be true
      policy.hide_feedback_before_finish = '0'
      expect(policy.hide_feedback_before_finish).to be false
    end
  end

  describe '#update' do
    let(:policy) { described_class.new }

    it 'updates multiple flags from a hash with string or symbol keys' do
      policy.update({
        'hide_feedback_before_finish' => true,
        no_review_before_close: true,
        see_answers: false
      })
      expect(policy.hide_feedback_before_finish).to be true
      expect(policy.no_review_before_close).to be true
      expect(policy.see_answers).to be false
    end
  end

  describe '#merge_child (inheritance resolution)' do
    let(:parent) do
      # Parent has invisible_before_review = true, see_answers = true
      p = described_class.new
      p.invisible_before_review = true
      p.see_answers = true
      p
    end

    it 'applies child overrides while inheriting unmasked parent flags' do
      # Child overrides see_answers to false, leaves invisible_before_review unmasked (nil)
      child_values = 0
      child_mask = described_class::FLAGS[:see_answers] # only see_answers overridden

      effective = parent.merge_child(child_values, child_mask)
      expect(effective.see_answers).to be false # overridden by child
      expect(effective.invisible_before_review).to be true # inherited from parent
    end
  end

  describe '#dup and #==' do
    let(:policy) { described_class.new }

    it 'dups independent values and mask' do
      policy.invisible_before_review = true
      copy = policy.dup
      expect(copy).to eq(policy)
      copy.invisible_before_review = false
      expect(copy.invisible_before_review).to be false
      expect(policy.invisible_before_review).to be true
    end
  end

  describe '#to_h and #as_json' do
    let(:policy) { described_class.new }

    it 'returns a complete hash of all 12 flags' do
      h = policy.to_h
      expect(h.keys.size).to eq(12)
      expect(h[:see_answers]).to be true
      expect(h[:invisible_before_review]).to be false
    end
  end
end
