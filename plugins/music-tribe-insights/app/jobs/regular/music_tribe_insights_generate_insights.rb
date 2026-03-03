# frozen_string_literal: true

module Jobs
  class MusicTribeInsightsGenerateInsights < ::Jobs::Base
    sidekiq_options retry: 2

    def execute(_args = nil)
      return unless SiteSetting.music_tribe_insights_enabled
      require "aws-sdk-bedrockruntime" unless defined?(Aws::BedrockRuntime::Client)
      MusicTribeInsights::BedrockAnalyzer.call
    end
  end
end
