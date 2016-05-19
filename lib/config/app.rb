module Config
  module App
    SUPPORTED_TYPES = %w(likes groups)
    JOB_TIMEOUT = 600 # seconds, 10 minutes
    NOLIMIT_JOB_TIMEOUT = 9_000 # seconds, 150 minutes

    class << self
      def supported_types
        SUPPORTED_TYPES.join(', ')
      end

      def supported_type?(type)
        SUPPORTED_TYPES.include?(type)
      end
    end
  end
end
