require 'fastlane/action'
require_relative '../helper/apphoster_helper'

module Fastlane
  module Actions
    class ApphosterAction < Action
      def self.run(params)
        UI.message("The apphoster plugin is working!")

        api_host = params[:api_host]
        token  = params[:token]
        plat_id  = params[:plat_id]
        
        build_file = [
          params[:ipa]
        ].detect { |e| !e.to_s.empty? }

        if build_file.nil?
          UI.user_error!("You have to provide a build file")
        end
         
        UI.message "build_file: #{build_file}"

        file_nick_name = params[:file_nick_name]
        if file_nick_name.nil?
          file_nick_name = ""
        end
        
        run_script = "curl --form plat_id=36  --form token=#{token} --form file=@#{build_file} #{api_host}"
        if file_nick_name != 0
          run_script = "curl --form plat_id=36 --form file_nick_name=#{file_nick_name} --form token=#{token} --form file=@#{build_file} #{api_host}"  
        end
        
        UI.message "Begin run script #{run_script}"
        UI.message "Start upload #{build_file} to #{api_host}..."

        system(run_script)
        # response = JSON.parse(info)
        # if response['error'] != 0
        #   UI.user_error!("Apphost Plugin Error: #{response['error']}")
        # end
        UI.success "Upload process finish"

      end

      def self.description
        "A simple plugin to upload your ipa file to AppHost Server in fastlane."
      end

      def self.authors
        ["JerryFans"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      # def self.details
      #   # Optional:
      #   "A simple plugin to upload your ipa file to AppHost Server in fastlane."
      # end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_host,
                                  env_name: "Api_host",
                               description: "Your sever https domain name",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :token,
                                      env_name: "Token",
                                   description: "Your apphost token",
                                      optional: false,
                                          type: String),
          FastlaneCore::ConfigItem.new(key: :plat_id,
                                      env_name: "Plat_id",
                                   description: "Your apphost plat_id ,identify of your app",
                                      optional: false,
                                          type: String),
          FastlaneCore::ConfigItem.new(key: :file_nick_name,
                                          env_name: "File_nick_name",
                                       description: "Your file nick name",
                                          optional: true,
                                              type: String),
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: "AppHost_IPA",
                                       description: "Path to your IPA file",
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find ipa file at path '#{value}'") unless File.exist?(value)
                                       end,
                                       conflicting_options: [:apk],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You can't use 'ipa' and '#{value.key}' options in one run")
                                       end),
                                      
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
