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
      ActionController::RoutingError.new('No route matches [GET] "/courses/uncc/missing_page"')
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

    it 'is invalid when a routing error matches /api/v1/* even with an internal referrer' do
      api_routing_error = ActionController::RoutingError.new('No route matches [GET] "/api/v1/features/environment"')
      record = build_exception(api_routing_error, path_info: '/404', referrer: "http://#{host}/courses/uncc/itsc2214/fall-2026/14374/982")
      expect(record).not_to be_valid
      expect(record.errors[:base]).to include('Ignored third-party or API routing error')
    end

    describe 'numeric IP filtering' do
      let(:ip_host) { '128.173.236.42' }

      it 'is invalid when the target host is a numeric IPv4 address' do
        record = build_exception(routing_error, path_info: '/404', host: ip_host, referrer: nil)
        expect(record).not_to be_valid
        expect(record.errors[:base]).to include('Direct numeric IP scan probe')
      end

      it 'is invalid when the target host is a bracketed IPv6 address' do
        record = build_exception(routing_error, path_info: '/404', host: '[2001:db8::1]', referrer: nil)
        expect(record).not_to be_valid
        expect(record.errors[:base]).to include('Direct numeric IP scan probe')
      end

      it 'is invalid when the target host and referrer are matching numeric IPs' do
        record = build_exception(routing_error, path_info: '/404', host: ip_host, referrer: "http://#{ip_host}/gym/workouts")
        expect(record).not_to be_valid
        expect(record.errors[:base]).to include('Direct numeric IP scan probe')
      end

      it 'is invalid when the referrer is relative but target host is a numeric IP' do
        record = build_exception(routing_error, path_info: '/404', host: ip_host, referrer: '/gym/workouts')
        expect(record).not_to be_valid
        expect(record.errors[:base]).to include('Direct numeric IP scan probe')
      end

      it 'is invalid when the referrer host is a numeric IP even if target host is a domain' do
        record = build_exception(routing_error, path_info: '/404', host: host, referrer: "http://#{ip_host}/gym/workouts")
        expect(record).not_to be_valid
        expect(record.errors[:base]).to include('Direct numeric IP scan probe')
      end
    end

    describe 'PHP and CMS probing patterns' do
      it 'is invalid for PHP script probing even with an internal referrer' do
        [
          '/phpinfo.php',
          '/_profiler/phpinfo.php',
          '/app_dev.php/_profiler/phpinfo',
          '/pi.php',
          '/test.php',
          '/test.php5'
        ].each do |path|
          err = ActionController::RoutingError.new("No route matches [GET] \"#{path}\"")
          record = build_exception(err, path_info: '/404', referrer: "http://#{host}/gym/workouts")
          expect(record).not_to be_valid
          expect(record.errors[:base]).to include('Ignored third-party or API routing error')
        end
      end

      it 'is invalid for PHP backup and editor temporary files' do
        [
          '/wp-config.php.bak',
          '/wp-config.php.old',
          '/wp-config.php.swp',
          '/index.php~'
        ].each do |path|
          err = ActionController::RoutingError.new("No route matches [GET] \"#{path}\"")
          record = build_exception(err, path_info: '/404', referrer: "http://#{host}/gym/workouts")
          expect(record).not_to be_valid
          expect(record.errors[:base]).to include('Ignored third-party or API routing error')
        end
      end

      it 'is invalid for WordPress and common CMS routes' do
        [
          '/wp-admin',
          '/wp-login.php',
          '/wp-content/plugins/test/',
          '/wp-includes/wlwmanifest.xml',
          '/xmlrpc.php',
          '/wordpress/',
          '/phpmyadmin/scripts/setup.php'
        ].each do |path|
          err = ActionController::RoutingError.new("No route matches [GET] \"#{path}\"")
          record = build_exception(err, path_info: '/404', referrer: "http://#{host}/gym/workouts")
          expect(record).not_to be_valid
          expect(record.errors[:base]).to include('Ignored third-party or API routing error')
        end
      end

      it 'is invalid for environment files and configuration backup probes' do
        [
          '/.env',
          '/.git/config',
          '/docker-compose.yml.save',
          '/config.json.swp',
          '/terraform.tfstate.old',
          '/application.yml.1',
          '/serverless.yml~'
        ].each do |path|
          err = ActionController::RoutingError.new("No route matches [GET] \"#{path}\"")
          record = build_exception(err, path_info: '/404', referrer: "http://#{host}/gym/workouts")
          expect(record).not_to be_valid
          expect(record.errors[:base]).to include('Ignored third-party or API routing error')
        end
      end
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
