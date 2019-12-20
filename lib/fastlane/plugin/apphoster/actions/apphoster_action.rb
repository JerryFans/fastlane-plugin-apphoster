require 'fastlane/action'
require_relative '../helper/apphoster_helper'
require 'rest-client'
require 'json'

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

        ipa_host = params[:ipa_host]
        if ipa_host.nil?
          ipa_host = ""
        end
        
        UI.message "Start upload #{build_file} to #{api_host}..."
        
        response = RestClient::Request.execute(
          method: :post, 
          url: api_host,
          payload: {
              token: token,
              plat_id: plat_id,
              :multipart => true,
              :file => File.new(build_file, 'rb')
          }, 
         )
        json = JSON.parse(response.body)
        error = json["error"]
        if error.nil?
            ipa_id = json["id"]
            name = json["name"]
            install_url = "#{ipa_host}/#{ipa_id}"
            if ipa_host.empty?
              UI.success "#{name} upload success install ipa_id is #{ipa_id}"
            else
              UI.success "#{name} upload success install url is #{install_url}"
            end
        else
            UI.user_error!("upload error : #{json["error"]}")
        end

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
          FastlaneCore::ConfigItem.new(key: :ipa_host,
                                                env_name: "Ipa_host",
                                             description: "ipa host to replace like xxx.com/ipa/pkgs/100 that is your install url",
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
