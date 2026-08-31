require 'spec_helper'

describe ApplicationHelper, type: :helper do
  describe "#embedded_lti_launch?" do
    it "returns false when lti_launch is not present" do
      expect(helper.embedded_lti_launch?).to be_falsey
    end

    it "returns true when lti_launch is present and document_target is iframe" do
      controller.params[:lti_launch] = 'true'
      controller.params[:launch_presentation_document_target] = 'iframe'
      expect(helper.embedded_lti_launch?).to be true
    end

    it "returns true by default when lti_launch is present and document_target is not specified" do
      controller.params[:lti_launch] = 'true'
      expect(helper.embedded_lti_launch?).to be true
    end

    it "returns false when lti_launch is present and document_target is window (loaded in a new tab)" do
      controller.params[:lti_launch] = 'true'
      controller.params[:launch_presentation_document_target] = 'window'
      expect(helper.embedded_lti_launch?).to be false
    end

    it "checks session[:lti_document_target] as a fallback" do
      controller.params[:lti_launch] = 'true'
      session[:lti_document_target] = 'window'
      expect(helper.embedded_lti_launch?).to be false
    end
  end
end
