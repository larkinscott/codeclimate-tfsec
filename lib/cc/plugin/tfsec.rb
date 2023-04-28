require 'yaml'
require 'json'
require 'open3'

module CC
  module Plugin
    class TFSec
      def initialize
        @config_file = ".codeclimate.yml"
        @config = read_config
        @exclude_patterns = @config.dig("plugins", "tfsec", "exclude_paths")
        @remediation_points = 50000
      end

      def read_config
        return {} unless File.exist?(@config_file)

        YAML.load_file(@config_file)
      end

      def exclude_flags
        @exclude_patterns.map { |pattern| "--exclude-path=#{pattern}" } unless @exclude_patterns.nil?
      end

      def run_tfsec
        stdout, stderr, status = Open3.capture3("tfsec", "--force-all-dirs", "-f", "json", *exclude_flags)

        JSON.parse(stdout).fetch("results")
      end

      def generate_issues(result)
        {
            type: "issue",
            check_name: result.fetch("long_id"),
            description: result.fetch("description"),
            categories: ["Security"],
            location: {
              path: result.dig("location", "filename").sub("#{Dir.pwd}/", ''),
              lines: {
                begin: result.dig("location", "start_line"),
                end: result.dig("location", "end_line"),
              }
            },
            severity: "info",
            remediation_points: @remediation_points,
            fingerprint: result.fetch("rule_id"),
            content: { body: render_content(result) },
          }
      end

      def process_results
        results = run_tfsec
        results.each do |result|
          issue = generate_issues(result)
          puts issue.to_json
          puts "\0"
        end
      end

      private

      def render_content(result)
        rule_description = result.fetch("rule_description")
        resolution = result.fetch("resolution")
        impact = result.fetch("impact")

        readup = <<~END
          ## Rule description ##
          #{rule_description}

          ## Resolution ##
          #{resolution}

          ## Impact ##
          #{impact}
        END
      end
    end
  end
end
