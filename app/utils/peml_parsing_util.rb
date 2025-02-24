require 'peml'
require 'dottie/ext'
require 'net/http'
require 'uri'

class PemlParsingUtil
  def parse (text_representation, error_msgs)
    peml = Peml::Loader.new.load(text_representation).dottie!
    error_msgs.concat(Peml::validate(peml))
    convert_peml(peml, error_msgs)
  end

    # Convert the parsed peml hash into a hash corresponding to exercise data model
  def convert_peml(hash, error_msgs)
    hash = Dottie(hash)
        #starting with three compulsory peml keys
    new_hash = {
      'external_id' => hash['exercise_id'],
      'name' => hash['title']
    }.dottie!
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
      system = systems.first
      new_hash['language_list'] = system['language']
          # assets should be under the system, so try to grab them here first
      Rails.logger.debug 'get_file_content(system[\'assets.code.starter\'])'
      content = get_file_content(system['assets.code.starter'])
      prompt['starter_code'] = content if content
      Rails.logger.debug 'get_file_content(system[\'assets.code.wrapper\'])'
      content = get_file_content(system['assets.code.wrapper'])
      prompt['wrapper_code'] = content if content
      Rails.logger.debug 'get_test_file_content(prompt, system[\'assets.test\'])'
      get_test_file_content(prompt, system['assets.test'])
    end

    new_hash['current_version'] = {}
    new_hash['current_version.version'] = hash['version.id'] if hash['version.id']
    new_hash['current_version.creator'] = get_author_email(hash)
    new_hash['current_version.prompts'] = []

    #-----------------------------------------------------------------------
    # PEML assets might be at the global level, if they apply to all
    # systems, so fill in missing assets here
    Rails.logger.debug 'assets:'
    Rails.logger.debug hash['assets'].to_yaml
    if !prompt['starter_code']
      Rails.logger.debug 'get_file_content(hash[\'assets.code.starter\'])'
      prompt['starter_code'] = get_file_content(hash['assets.code.starter'])
    end
    if !prompt['wrapper_code']
      Rails.logger.debug 'get_file_content(hash[\'assets.code.wrapper\'])'
      prompt['wrapper_code'] =  get_file_content(hash['assets.code.wrapper'])
    end
    Rails.logger.debug 'get_test_file_content(prompt, hash[\'assets.test\'])'
    get_test_file_content(prompt, hash['assets.test'])
    # FIXME: give error if missing tests
    #-----------------------------------------------------------------------
    if !prompt['class_name']
      prompt['class_name'] = 'Answer'
    end
    if !prompt['method_name']
      prompt['method_name'] = 'answer'
    end

    # Again, PEML is designed for coding problems and thus, 'coding_prompt'
    new_hash['current_version.prompts'] << { 'coding_prompt' => prompt }
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
  def get_test_file_content(prompt, files)
    Rails.logger.debug '=========='
    Rails.logger.debug 'get_test_file_content(prompt, files), prompt:'
    Rails.logger.debug '=========='
    Rails.logger.debug prompt.to_yaml
    Rails.logger.debug '=========='
    Rails.logger.debug 'get_test_file_content(prompt, files), files:'
    Rails.logger.debug '=========='
    Rails.logger.debug files.to_yaml
    Rails.logger.debug files.inspect
    if files and !prompt['tests']
      file = files['files'][0]
      Rails.logger.debug '=========='
      Rails.logger.debug 'get_test_file_content(prompt, files), file:'
      Rails.logger.debug '=========='
      Rails.logger.debug file.to_yaml
      Rails.logger.debug file.inspect
      file.dottie!

      # copy class and method names from file pattern properties, if present
      class_name = file['pattern.class_name']
      prompt['class_name'] = class_name if class_name
      method_name = file['pattern.method_name']
      prompt['method_name'] = method_name if method_name

      pattern_actual = file['pattern.actual'] || file['pattern_actual']

      if !prompt['method_name'] && pattern_actual
        Rails.logger.debug "pattern_actual = '#{pattern_actual}'"
        # pattern.actual: subject.oneFinder({{nums}})
        method_name = pattern_actual.sub(/^.*subject\.(\w+)\(.*$/, '\1')
        Rails.logger.debug "extracted method name = '#{method_name}'"
        prompt['method_name'] = method_name if method_name
      end

      # Extract file content
      content = get_file_content(file)

      if content
        # format: text/csv-unquoted
        # Need to handle this

        # format: text/csv
        # Need to handle this
        # Drop first line of colum headers
        content = content.lines[1..-1].join if content

        # Need to re-assemble straight CSV from either format
        prompt['tests'] = content
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
    Rails.logger.debug '=========='
    Rails.logger.debug 'get_file_content(files), files:'
    Rails.logger.debug '=========='
    Rails.logger.debug files.to_yaml
    Rails.logger.debug files.inspect
    file = files
    if file and files['files']
      file = files['files'][0]
    end
    Rails.logger.debug '=========='
    Rails.logger.debug 'get_file_content(files), file:'
    Rails.logger.debug '=========='
    Rails.logger.debug file.to_yaml
    Rails.logger.debug file.inspect
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
end
