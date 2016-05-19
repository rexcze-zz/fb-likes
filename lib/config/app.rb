module Config
  module App
    SUPPORTED_TYPES = %w(likes groups)
    JOB_TIMEOUT = 600 # seconds

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
