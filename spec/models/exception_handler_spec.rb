# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ExceptionHandler::Exception, type: :model do
  let(:host) { 'codeworkout.org' }

  def build_exception(raised_exception, path_info: '/404', referrer: nil, host: 'codeworkout.org')
    raised_exception.set_backtrace(caller) unless raised_exception.backtrace
    req = ActionDispatch::TestRequest.create
    req.env['action_dispatch.exception'] = raised_exception
    req.env['PATH_INFO'] = path_info
    req.env['HTTP_REFERER'] = referrer if referrer.present?
    req.host = host
    ExceptionHandler::Exception.new(request: req)
  end

  describe 'validation for 404 and routing errors' do
    let(:routing_error) do
      ActionController::RoutingError.new('No route matches [GET] "/api/v1/courses/uncc/tabs"')
    end

    it 'is invalid when a 404 routing error has no referrer (direct/bot probe)' do
      record = build_exception(routing_error, path_info: '/404', referrer: nil)
      expect(record).not_to be_valid
      expect(record.errors[:base]).to include('External or missing referrer on 4xx client error')
    end

    it 'is invalid when a 404 routing error has an external referrer' do
      record = build_exception(routing_error, path_info: '/404', referrer: 'https://malicious-scanner.com/attack')
      expect(record).not_to be_valid
      expect(record.errors[:base]).to include('External or missing referrer on 4xx client error')
    end

    it 'is valid when a 404 routing error has an internal absolute referrer' do
      record = build_exception(routing_error, path_info: '/404', referrer: "http://#{host}/gym/workouts")
      expect(record).to be_valid
    end

    it 'is valid when a 404 routing error has an internal relative referrer' do
      record = build_exception(routing_error, path_info: '/404', referrer: '/gym/workouts')
      expect(record).to be_valid
    end
  end

  describe 'validation for 406 and format errors' do
    let(:unknown_format_error) do
      ActionController::UnknownFormat.new('HomeController#new_course_modal is missing a template for this request format')
    end

    it 'is invalid when a 406 unknown format error has no referrer (direct HTML visit/probe)' do
      record = build_exception(unknown_format_error, path_info: '/406', referrer: nil)
      expect(record).not_to be_valid
      expect(record.errors[:base]).to include('External or missing referrer on 4xx client error')
    end

    it 'is invalid when a 406 unknown format error has an external referrer' do
      record = build_exception(unknown_format_error, path_info: '/406', referrer: 'https://external-crawler.com')
      expect(record).not_to be_valid
      expect(record.errors[:base]).to include('External or missing referrer on 4xx client error')
    end

    it 'is valid when a 406 format error has an internal referrer' do
      record = build_exception(unknown_format_error, path_info: '/406', referrer: "http://#{host}/home")
      expect(record).to be_valid
    end
  end

  describe 'validation for 500 and other server errors' do
    let(:server_error) do
      ZeroDivisionError.new('divided by 0')
    end

    it 'is valid when a 500 error has no referrer' do
      record = build_exception(server_error, path_info: '/500', referrer: nil)
      expect(record).to be_valid
    end

    it 'is valid when a 500 error has an external referrer' do
      record = build_exception(server_error, path_info: '/500', referrer: 'https://external-site.com')
      expect(record).to be_valid
    end
  end
end
