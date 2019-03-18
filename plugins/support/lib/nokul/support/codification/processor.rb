# frozen_string_literal: true

module Nokul
  module Support
    module Codification
      class Processor
        class_attribute :processors, instance_writer: false, default: {}

        def self.inherited(base)
          dup = processors.dup
          base.processors = dup.each { |k, v| dup[k] = v.dup }
          super
        end

        def self.define(name, &block)
          processors[name] = block
        end

        define :non_offensive? do |string|
          !string.inside_offensives?
        end

        define :non_reserved? do |string|
          !string.inside_reserved?
        end

        define :safe? do |string|
          !string.inside_offensives? && !string.inside_reserved?
        end

        DEFAULT_RANDOM_RANGE = (0..999).freeze
        DEFAULT_RANDOM_SEP   = '.'

        define :random_suffix do |string, **options|
          @_random_coder ||= options[:random] || Codification.random_numeric_codes(DEFAULT_RANDOM_RANGE)
          @_random_sep   ||= options[:random_sep] || DEFAULT_RANDOM_SEP

          string + @_random_sep + @_random_coder.run
        rescue Consumed
          raise Skip, string
        end

        def initialize(**options)
          @processors = build options.dup.extract!(:builtin_post_process, :post_process).values.flatten
        end

        def process(instance, string, **options)
          processors.inject(string) { |result, processor| instance.instance_exec(result, **options, &processor) }
        end

        def skip(string, expr)
          expr ? string : raise(Skip, string)
        end

        protected

        attr_reader :processors

        def build(args)
          args.map do |arg|
            arg.must_be_any_of! Regexp, Proc, Symbol, String

            case arg
            when Regexp         then processor_regexp(arg)
            when Proc           then arg
            when Symbol, String then processor_builtin(arg.to_s)
            end
          end
        end

        def processor_predicate
          processor = self
          proc do |string, *args|
            processor.skip string, yield(string, *args)
          end
        end

        def processor_regexp(pattern)
          processor_predicate { |string, _| string.match?(pattern) }
        end

        def processor_builtin(builtin)
          raise Error, "No such processor: #{builtin}" unless (processor = Processor.processors[builtin.to_sym])

          builtin.end_with?('?') ? processor_predicate(&processor) : processor
        end
      end
    end
  end
end
