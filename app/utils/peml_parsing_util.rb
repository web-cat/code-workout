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
        #starting with three compulsory peml keys
        new_hash = {"external_id" => hash["exercise_id"], "name" => hash["title"]}.dottie!
        new_hash["experience"] = hash["difficulty"]
        new_hash["tag_list"] = hash["tag"].to_s

        # PEML does not have an is_public equivalent so we put this value under a key of the same name
        new_hash["is_public"] = hash["is_public"]

        # PEML is designed to handle programming assignments and 'code writing' is the equivalent in code-workout
        new_hash["style_list"] = "code writing" 

        new_hash["language_list"] = ""
        hash["systems"].each do |system|
          new_hash["language_list"]+=system["language"]
        end

        new_hash["current_version"] = {}
        new_hash["current_version.version"] = hash["version.id"]
        new_hash["current_version.creator"] = get_author(hash)
        new_hash["current_version.prompts"] = []
        prompt = {"position" => 1, "question" => hash["instructions"], "class_name" => "", "method_name" => ""}
  
        #-------------------------------------------------------------------------------------------
        # PEML assets are either remote URLs or array of files which have different keys. 
        # We try to fetch content from the files.
        prompt["starter_code"] = get_content(hash["assets.code.starter"]) 
        prompt["wrapper_code"] =  get_content(hash["assets.code.wrapper"])
        prompt["tests"] =  get_content(hash["assets.test"])
        #-------------------------------------------------------------------------------------------
  
        #Again, PEML is designed for coding problems and thus, 'coding_prompt'
        new_hash["current_version.prompts"]<<{"coding_prompt" => prompt}
        new_hash
      end

      def get_author(hash)
        creator = ""
        if hash.key?("authors")
            hash["authors"].each do |author|
                if author.is_a? String
                    creator += author
                else 
                    creator += author.key?("email") ? author["email"] : author["name"]
                end
                creator += ","
            end
            creator.delete_suffix!(",")
        elsif(hash.key?("author"))
            if hash["author"].is_a? String
                creator = hash["author"]
            else 
                creator = hash["author"].key?("email") ? hash["author.email"] : hash["author.name"]
            end
        elsif(hash.key?("license"))
            creator = hash["license.owner"]
        end
        creator
      end

      def get_content(asset_child)
        asset_collection = []
        if asset_child.is_a? String
            begin
                uri = URI.parse(asset_child)
                if uri.is_a?(URI::HTTP) && !uri.host.nil?
                    asset_collection << Net::HTTP.get(uri)
                end
            rescue URI::InvalidURIError
                asset_collection << ""
            end
        elsif asset_child.is_a? Array
            asset_child.each do |asset_file|
                asset_collection << asset_file["files"]["content"]
            end
        end
        asset_collection.join(',')
      end
end