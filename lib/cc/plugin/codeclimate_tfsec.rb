#!/usr/bin/env ruby

require 'yaml'
require 'json'
require 'open3'

class CodeClimateTFSec
  def initialize
    @config_file = ".codeclimate.yml"
    @config = read_config
    @exclude_patterns = @config.fetch("exclude_patterns", nil)
    @remediation_points = 50000
  end

  def read_config
    return {} unless File.exist?(@config_file)

    YAML.load_file(@config_file)
  end

  def exclude_flags
    # this might not work as expected; ignoring for now
    @exclude_patterns.map { |pattern| "--exclude-path=#{pattern}" } unless @exclude_patterns.nil?
  end

  def run_tfsec
    stdout, stderr, status = Open3.capture3("tfsec", ".", "-f", "json", *exclude_flags)

    JSON.parse(stdout).fetch("results")
  end

  def generate_issues(result)
    {
        type: "issue",
        check_name: "tfsec/#{result.fetch("rule_id")}",
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
end

tfsec = CodeClimateTFSec.new
tfsec.process_results
