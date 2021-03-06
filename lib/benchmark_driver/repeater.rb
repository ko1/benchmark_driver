module BenchmarkDriver
  # Repeat calling block and return desired result: "best", "worst" or "average".
  module Repeater
    VALID_TYPES = %w[best worst average]

    class << self
      # `block.call` can return multiple objects, but the first one is used for sort.
      # When `config.repeat_result == 'average'`, how to deal with rest objects is decided
      # by `:rest_on_average` option.
      def with_repeat(config:, larger_better:, rest_on_average: :first, &block)
        values = config.repeat_count.times.map { block.call }

        case config.repeat_result
        when 'best'
          best_result(values, larger_better)
        when 'worst'
          best_result(values, !larger_better)
        when 'average'
          average_result(values, rest_on_average)
        else
          raise "unexpected repeat_result #{config.repeat_result.inspect}"
        end
      end

      private

      def best_result(values, larger_better)
        values.sort_by do |value, *|
          larger_better ? value : -value
        end.last
      end

      def average_result(values, rest_on_average)
        unless values.first.is_a?(Array)
          return values.inject(&:+) / values.size.to_f
        end

        case rest_on_average
        when :first
          rest = values.first[1..-1]
          [values.map { |v| v[0] }.inject(&:+) / values.size.to_f, *rest]
        when :average
          values.first.size.times.map do |index|
            values.map { |v| v[index] }.inject(&:+) / values.first.size.to_f
          end
        else
          raise "unexpected rest_on_average #{rest_on_average.inspect}"
        end
      end
    end
  end
end
