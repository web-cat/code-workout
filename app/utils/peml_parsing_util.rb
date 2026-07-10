require 'peml'
require 'dottie/ext'
require 'net/http'
require 'uri'

class PemlParsingUtil
  def parse (text_representation, error_msgs)
    parse_result = Peml.parse(PARSER_PARAMS.merge({
      peml: text_representation
    }))
    peml = parse_result[:value]
    error_msgs.concat(parse_result[:diagnostics])
    convert_peml(peml, error_msgs)
  end

    # Convert the parsed peml hash into a hash corresponding to exercise data model
  def convert_peml(hash, error_msgs)
    hash.dottie!
        #starting with three compulsory peml keys
    new_hash = {
      'external_id' => hash['exercise_id'],
      'name' => hash['title']
    }
    new_hash.dottie!
    content = hash['difficulty']
    new_hash['experience'] = content if content
    content = hash['tags.topics']
    new_hash['tag_list'] = content.to_s if content

    # PEML does not have an is_public equivalent so we put this value
    # under a key of the same name
    # new_hash["is_public"] = hash["is_public"]

    # PEML is designed to handle programming assignments and 'code writing'
    # is the equivalent in code-workout
    new_hash['style_list'] = hash['tags.style'].to_s || 'code writing'

    prompt = {
      'position' => 1,
      'question' => hash['instructions']
    }
    systems = hash['systems']
    if systems
      system = systems.first.dottie
      language = system['language']
      new_hash['language_list'] = language
      # Rails.logger.debug 'system:'
      # Rails.logger.debug system.to_yaml 
          # assets should be under the system, so try to grab them here first
      # Rails.logger.debug 'get_file_content(system[\'assets.code.starter\'])'
      content = get_file_content(system['assets.code.starter'])
      prompt['starter_code'] = content if content
      # Rails.logger.debug 'get_file_content(system[\'assets.code.wrapper\'])'
      content = get_file_content(system['assets.code.wrapper'])
      prompt['wrapper_code'] = content if content
      # Rails.logger.debug 'get_test_file_content(prompt, system[\'assets.test\'])'
      get_test_file_content(prompt, language, system['assets.test'])
    end

    new_hash['current_version'] = {}
    new_hash['current_version.version'] = hash['version.id'] if hash['version.id']
    new_hash['current_version.creator'] = get_author_email(hash)
    new_hash['current_version.prompts'] = []

    #-----------------------------------------------------------------------
    # PEML assets might be at the global level, if they apply to all
    # systems, so fill in missing assets here
    # Rails.logger.debug 'assets:'
    # Rails.logger.debug hash['assets'].to_yaml
    if !prompt['starter_code']
      # Rails.logger.debug 'get_file_content(hash[\'assets.code.starter\'])'
      prompt['starter_code'] = get_file_content(hash['assets.code.starter'])
    end
    if !prompt['wrapper_code']
      # Rails.logger.debug 'get_file_content(hash[\'assets.code.wrapper\'])'
      prompt['wrapper_code'] =  get_file_content(hash['assets.code.wrapper'])
    end
    # Rails.logger.debug 'get_test_file_content(prompt, language, hash[\'assets.test\'])'
    get_test_file_content(prompt, language, hash['assets.test'])
    # FIXME: give error if missing tests
    #-----------------------------------------------------------------------

    # Again, PEML is designed for coding problems and thus, 'coding_prompt'
    new_hash['current_version.prompts'] << { 'coding_prompt' => prompt }
    Rails.logger.debug 'new hash:'
    Rails.logger.debug new_hash.to_yaml
    new_hash
  end


  #-----------------------------------------------------------------------
  # Tries to find the email of the author from the given hash.
  #
  # First, it tries to find it in the 'author.email' key, then in the
  # 'license.owner.email' key. If neither works and the 'authors' key
  # exists, it takes the email from the first author.
  #
  # @param hash [Hash] the hash to search for the author's email
  # @return [String, nil] the author's email if found, otherwise nil
  def get_author_email(hash)
    creator = hash['author.email'] || hash['license.owner.email']
    if !creator and hash.key?('authors')
      creator = hash['authors[0].email']
    end
    Rails.logger.debug "get_author_email() = '#{creator}'"
    creator
  end


  #-----------------------------------------------------------------------
  def get_test_file_content(prompt, language, files)
    Rails.logger.debug '=========='
    Rails.logger.debug 'get_test_file_content(prompt, files), prompt:'
    Rails.logger.debug '=========='
    Rails.logger.debug prompt.to_yaml
    Rails.logger.debug '=========='
    Rails.logger.debug 'get_test_file_content(prompt, files), files:'
    Rails.logger.debug '=========='
    Rails.logger.debug files.to_yaml
    Rails.logger.debug files.pretty_inspect
    if files and !prompt['tests']
      file = files['files'][0]
      Rails.logger.debug '=========='
      Rails.logger.debug 'get_test_file_content(prompt, files), file:'
      Rails.logger.debug '=========='
      Rails.logger.debug file.to_yaml
      Rails.logger.debug file.pretty_inspect
      file.dottie!

      # copy class and method names from file pattern properties, if present
      class_name = prompt['class_name'] || file['pattern.class_name']
      if class_name.blank? && !prompt['starter_code'].blank?
        if language == 'Java' || language == 'java' || language == 'C++' || language == 'c++' || language == 'cpp'
          class_name = prompt['starter_code'][/\bclass\s+(\w+)/, 1]
        elsif language == 'Python' || language == 'python' || language == 'Ruby' || language == 'ruby'
          class_name = prompt['starter_code'][/\bclass\s+(\w+)/, 1]
        end
      end
      if class_name.blank?
        class_name = 'Answer'
      end
      prompt['class_name'] = class_name
      

      method_name = prompt['method_name'] || file['pattern.method_name']
      if method_name.blank?
        pattern_method_invocation = file['pattern.method_invocation']
        if pattern_method_invocation.blank?
          pattern_actual = file['pattern.actual'] || file['pattern_actual']
          if !pattern_actual.blank?
            Rails.logger.debug "pattern_actual = '#{pattern_actual}'"
            # pattern.actual: subject.oneFinder({{nums}})
            method_name = pattern_actual.sub(/^.*subject\.(\w+)\s*\(.*$/, '\1')
          end
        else
          Rails.logger.debug "pattern_method_invocation = '#{pattern_method_invocation}'"
          # pattern.method_invocation: subject.oneFinder({{nums}})
          method_name = pattern_method_invocation.sub(/^\s*(\w+)\s*\(.*$/, '\1')
        end
        Rails.logger.debug "extracted method name = '#{method_name}'"
      end
      if method_name.blank?
        method_name = 'answer'
      end
      prompt['method_name'] = method_name

      # Extract file content
      if prompt['tests'].blank?
        prompt['tests'] = get_file_content(file)
      end
    end
    Rails.logger.debug '=========='
    Rails.logger.debug 'get_test_file_content(prompt, files) => prompt:'
    Rails.logger.debug '=========='
    Rails.logger.debug prompt.to_yaml
  end

  #-----------------------------------------------------------------------
  # Retrieves the content from the first file description in a PEML files
  # array.
  #
  # - If the file content is a string and matches a URL pattern, it fetches
  #   the content from the URL.
  # - If the file is a hash, it retrieves the 'content' key's value.
  #
  # Logs detailed information about the files and content retrieval process
  # for debugging.
  #
  # @param files [Hash] A hash containing file information, expected to have
  # a 'files' key.
  # @return [String, nil] The content of the file, or nil if content cannot
  # be retrieved.
  def get_file_content(files)
    content = nil
    # Rails.logger.debug '=========='
    # Rails.logger.debug 'get_file_content(files), files:'
    # Rails.logger.debug '=========='
    # Rails.logger.debug files.to_yaml
    # Rails.logger.debug files.pretty_inspect
    file = files
    if file and files['files']
      file = files['files'][0]
    end
    # Rails.logger.debug '=========='
    # Rails.logger.debug 'get_file_content(files), file:'
    # Rails.logger.debug '=========='
    # Rails.logger.debug file.to_yaml
    # Rails.logger.debug file.pretty_inspect
    if file.is_a? String
      file.strip!
      if file.sub!(/^url\((.*)\)$/, '\1')
        uri = URI.parse(file)
        if uri.is_a?(URI::HTTP) && !uri.host.nil?
          content = Net::HTTP.get(uri)
        end
      else
        # FIXME: is this an error?
        content = file
      end

      # FIXME: add error checking if URL not parsable/readable
    elsif file.is_a? Hash
      content = file['content']
    else
      # FIXME: add error checking if not a hash
    end
    content
  end

#       def get_content(asset_child)
#         asset_collection = []
#         if asset_child.is_a? String
#           begin
#             uri = URI.parse(asset_child)
#             if uri.is_a?(URI::HTTP) && !uri.host.nil?
#               asset_collection << Net::HTTP.get(uri)
#             end
#           rescue URI::InvalidURIError
#             # asset_collection << ""
#             # FIXME: Needs error message generation
#           end
#         elsif asset_child.is_a? Array
#           asset_child.each do |asset_file|
#             asset_collection << asset_file["files"]["content"]
#           end
#         end
#         asset_collection.join(',')
#       end


  #~ Private instance methods .................................................
  private

  PARSER_PARAMS = {
    render_tests: true,

    # global template overrides
    # language-specific template overrides
    render_tests_params: {
      'parse_descriptions' => true,
      pattern: {
        'description' => '{% include "method_call" %} -> {% include "expected_template" %}',
        'description_annotation' => <<~DESCRIPTION_ANNOTATION
        Description: {% show_yaml %}{% include 'description' %}{% endshow_yaml %}
        DESCRIPTION_ANNOTATION
      },

      'java' => {
        'pattern' => {
          'description_annotation' => <<~JAVA_DESCRIPTION_ANNOTATION
          {% show_yaml %}@Description({% capture desc_out %}{% include 'description' %}{% endcapture %}{{ desc_out | string_literal }}){% endshow_yaml %}
          JAVA_DESCRIPTION_ANNOTATION
        }
      },
      'python' => {
      },
      'ruby' => {
      },
      'cpp' => {
      }
    }
  }
end
