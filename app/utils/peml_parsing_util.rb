require 'peml'
require 'dottie/ext'
require 'net/http'
require 'uri'

class PemlParsingUtil
  def parse (text_representation)
    convert_peml(Peml::Loader.new.load(text_representation).dottie!)
  end

    # Convert the parsed peml hash into a hash corresponding to exercise data model
  def convert_peml(hash)
    hash = Dottie(hash)
        #starting with three compulsory peml keys
    new_hash = {
      'external_id' => hash['exercise_id'],
      'name' => hash['title']
    }.dottie!
    new_hash['experience'] = hash['difficulty'] if hash['difficulty']
    new_hash['tag_list'] = hash['tags.topics'].to_s if hash['tags.topics']

    # PEML does not have an is_public equivalent so we put this value
    # under a key of the same name
    # new_hash["is_public"] = hash["is_public"]

    # PEML is designed to handle programming assignments and 'code writing'
    # is the equivalent in code-workout
    new_hash['style_list'] = hash['tags.style'].to_s || 'code writing'

    starter_code = nil
    wrapper_code = nil
    tests = nil
    systems = hash['systems']
    if systems
      system = systems.first
      new_hash['language_list'] = system['language']
          # assets should be under the system, so try to grab them here first
      Rails.logger.debug 'get_file_content(system[\'assets.code.starter\'])'
      starter_code = get_file_content(system['assets.code.starter'])
      Rails.logger.debug 'get_file_content(system[\'assets.code.wrapper\'])'
      wrapper_code =  get_file_content(system['assets.code.wrapper'])
      Rails.logger.debug 'get_file_content(system[\'assets.test\'])'
      tests =  get_file_content(system['assets.test'])
    end

    new_hash['current_version'] = {}
    new_hash['current_version.version'] = hash['version.id'] if hash['version.id']
    new_hash['current_version.creator'] = get_author_email(hash)
    new_hash['current_version.prompts'] = []
    prompt = {
      'position' => 1,
      'question' => hash['instructions'],
      'class_name' => 'Answer',
      'method_name' => 'answer'
    }

    #-----------------------------------------------------------------------
    # PEML assets might be at the global level, if they apply to all
    # systems, so fill in missing assets here
    Rails.logger.debug 'assets:'
    Rails.logger.debug hash['assets'].to_yaml
    Rails.logger.debug 'get_file_content(hash[\'assets.code.starter\'])'
    starter_code ||= get_file_content(hash['assets.code.starter'])
    prompt['starter_code'] = starter_code if starter_code
    Rails.logger.debug 'get_file_content(hash[\'assets.code.wrapper\'])'
    wrapper_code ||=  get_file_content(hash['assets.code.wrapper'])
    prompt['wrapper_code'] = wrapper_code if wrapper_code
    Rails.logger.debug 'get_file_content(hash[\'assets.test\'])'
    tests ||=  get_file_content(hash['assets.test'])
    # FIXME: give error if missing tests
    prompt['tests'] = tests if tests
    #-----------------------------------------------------------------------

    # Again, PEML is designed for coding problems and thus, 'coding_prompt'
    new_hash['current_version.prompts'] << { 'coding_prompt' => prompt }
    new_hash
  end

  def get_author_email(hash)
    creator = hash['author.email'] || hash['license.owner.email']
    if !creator and hash.key?('authors')
      creator = hash['authors[0].email']
    end
    Rails.logger.debug "get_author_email() = '#{creator}'"
    creator
  end

  def get_file_content(files)
    content = nil
    file = nil
    Rails.logger.debug '=========='
    Rails.logger.debug 'get_file_content(files), files:'
    Rails.logger.debug '=========='
    Rails.logger.debug files.to_yaml
    Rails.logger.debug files.inspect
    if files
      file = files['files'][0]
      Rails.logger.debug '=========='
      Rails.logger.debug 'get_file_content(files), file:'
      Rails.logger.debug '=========='
      Rails.logger.debug file.to_yaml
      Rails.logger.debug file.inspect
    end
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
