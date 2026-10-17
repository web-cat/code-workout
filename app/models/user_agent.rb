# == Schema Information
#
# Table name: user_agents
#
#  id              :bigint           not null, primary key
#  raw_user_agent  :text             not null
#  user_agent_hash :string(64)       not null
#  browser_family  :string(255)
#  browser_version :string(255)
#  os_family       :string(255)
#  is_lockdown     :boolean          default(FALSE), not null
#  is_seb          :boolean          default(FALSE), not null
#  is_suspicious   :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_user_agents_on_browser_family   (browser_family)
#  index_user_agents_on_is_lockdown      (is_lockdown)
#  index_user_agents_on_is_seb           (is_seb)
#  index_user_agents_on_is_suspicious    (is_suspicious)
#  index_user_agents_on_os_family        (os_family)
#  index_user_agents_on_user_agent_hash  (user_agent_hash) UNIQUE
#
class UserAgent < ApplicationRecord
  # Cache mapping hash => UserAgent record in process memory to minimize DB reads
  cattr_accessor :memory_cache do
    {}
  end

  has_many :activity_logs, dependent: :nullify
  has_many :attempts, dependent: :nullify
  has_many :workout_scores, foreign_key: 'last_user_agent_id', dependent: :nullify
  has_many :logged_errors, class_name: 'Error', foreign_key: 'user_agent_id', dependent: :nullify

  validates :raw_user_agent, presence: true
  validates :user_agent_hash, presence: true, uniqueness: true

  before_validation :compute_hash_and_classify

  scope :lockdown, -> { where(is_lockdown: true) }
  scope :seb, -> { where(is_seb: true) }
  scope :suspicious, -> { where(is_suspicious: true) }
  scope :by_browser, ->(family) { where(browser_family: family) }
  scope :by_os, ->(family) { where(os_family: family) }

  def to_s
    raw_user_agent.to_s
  end

  # Resolves or creates a UserAgent instance for the given raw string.
  # Utilizes in-memory caching for sub-millisecond repeated lookups.
  def self.find_or_create_by_raw(raw_string)
    return nil if raw_string.blank?

    clean_str = raw_string.to_s.strip
    hash = Digest::SHA256.hexdigest(clean_str)

    if (cached = memory_cache[hash])
      return cached
    end

    record = find_by(user_agent_hash: hash) || create!(raw_user_agent: clean_str)
    memory_cache[hash] = record
    record
  rescue ActiveRecord::RecordNotUnique
    record = find_by!(user_agent_hash: hash)
    memory_cache[hash] = record
    record
  end

  def self.clear_memory_cache!
    self.memory_cache = {}
  end

  # Returns a human-friendly short summary of browser + OS
  def display_name
    parts = []
    parts << browser_family if browser_family.present? && browser_family != 'Other'
    parts << browser_version if browser_version.present?
    label = parts.join(' ')
    label += " (#{os_family})" if os_family.present? && os_family != 'Unknown'
    label.presence || raw_user_agent.to_s.truncate(50)
  end

  def compute_hash_and_classify
    clean_ua = raw_user_agent.to_s.strip
    return if clean_ua.blank?

    self.user_agent_hash ||= Digest::SHA256.hexdigest(clean_ua)
    classify!(clean_ua)
  end

  def classify!(clean_ua = raw_user_agent.to_s.strip)
    # Check LockDown and SEB patterns
    lockdown_regex = %r{\b(LockDown(\s+Browser)?|CLDB|CMAC|LDB|Respondus)\b}i
    seb_regex      = %r{\b(SEB|SafeExamBrowser|Safe\s+Exam\s+Browser)\b}i
    suspicious_regex = %r{\b(Claude/\d+|Honorlock|curl|python|requests|Wget|Postman|HTTPie|aiohttp|Go-http-client)\b|Classroom personal-study import}i

    self.is_lockdown = !(clean_ua =~ lockdown_regex).nil?
    self.is_seb      = !(clean_ua =~ seb_regex).nil?
    self.is_suspicious = !(clean_ua =~ suspicious_regex).nil? || (clean_ua.length < 10 && !is_lockdown && !is_seb)

    # OS family
    self.os_family =
      case clean_ua
      when /Windows|Win64|WOW64|Win32/i then 'Windows'
      when /iPhone|iPod/i then 'iOS'
      when /iPad/i then 'iPadOS'
      when /Macintosh|Mac OS X|macOS/i then 'macOS'
      when /Android/i then 'Android'
      when /CrOS/i then 'ChromeOS'
      when /Linux|X11/i then 'Linux'
      else 'Unknown'
      end

    # Browser family & version
    if is_lockdown
      self.browser_family = 'LockDown Browser'
      self.browser_version =
        if clean_ua =~ /\b(?:CLDB|CMAC|LockDown Browser|LockDown|LDB)[\/ ]([0-9.]+)/i
          $1
        end
    elsif is_seb
      self.browser_family = 'Safe Exam Browser'
      self.browser_version =
        if clean_ua =~ /\b(?:SEB|SafeExamBrowser|Safe Exam Browser)[\/ ]([0-9.]+)/i
          $1
        end
    elsif clean_ua =~ /\bClaude\/([0-9.]+)/i
      self.browser_family = 'Claude Desktop'
      self.browser_version = $1
    elsif clean_ua =~ /\bHonorlock\b/i
      self.browser_family = 'Honorlock'
    elsif clean_ua =~ /\bEdg(?:e)?\/([0-9.]+)/i
      self.browser_family = 'Edge'
      self.browser_version = $1
    elsif clean_ua =~ /\bOPR\/([0-9.]+)/i
      self.browser_family = 'Opera'
      self.browser_version = $1
    elsif clean_ua =~ /\bChrome\/([0-9.]+)/i || clean_ua =~ /\bCriOS\/([0-9.]+)/i
      self.browser_family = 'Chrome'
      self.browser_version = $1
    elsif clean_ua =~ /\bFirefox\/([0-9.]+)/i || clean_ua =~ /\bFxiOS\/([0-9.]+)/i
      self.browser_family = 'Firefox'
      self.browser_version = $1
    elsif clean_ua =~ /\bVersion\/([0-9.]+).*Safari/i
      self.browser_family = 'Safari'
      self.browser_version = $1
    elsif clean_ua =~ /\bSafari\/([0-9.]+)/i
      self.browser_family = 'Safari'
      self.browser_version = $1
    elsif clean_ua =~ /\bBrave\b/i
      self.browser_family = 'Brave'
    elsif clean_ua =~ /\bGSA\/([0-9.]+)/i
      self.browser_family = 'Google Search App'
      self.browser_version = $1
    elsif clean_ua =~ /Classroom personal-study import/i
      self.browser_family = 'Classroom Import Script'
    else
      self.browser_family = 'Other'
    end
  end
end
