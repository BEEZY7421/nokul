# frozen_string_literal: true

require 'test_helper'

module Nokul
  module Support
    module Codification
      class CoderTest < ActiveSupport::TestCase # rubocop:disable Metrics/ClassLength
        module TestSimpleCode
          class SimpleCode < Code
            protected

            def take_in(value)
              value.must_be_any_of! [String]
            end

            def take_out(value)
              value
            end
          end
        end

        test 'simple case should work' do
          coder = Coder.new TestSimpleCode::SimpleCode.new(%w[foo bar baz])
          assert_equal 'foo', coder.run
          assert_equal 'bar', coder.run
          assert_equal 'baz', coder.run
          assert_raise(StopIteration) { coder.run }
        end

        test 'simple case with memory should work' do
          memory = SimpleMemory.new
          memory.remember 'bar'

          coder = Coder.new TestSimpleCode::SimpleCode.new(%w[foo bar baz]), memory: memory

          produced = []
          loop do
            produced << coder.run
          end

          assert_equal %w[foo baz], produced
          assert_raise(StopIteration) { coder.run }
        end

        test 'post processes should work as predicator' do
          memory = SimpleMemory.new
          memory.remember 'bar'

          custom_process = proc do |string|
            Processor.skip string, string != 'baz'
          end

          coder = Coder.new TestSimpleCode::SimpleCode.new(%w[foo bar baz]),
                            memory: memory,
                            post_process: custom_process

          produced = []
          loop do
            produced << coder.run
          end

          assert_equal %w[foo], produced
          assert_raise(StopIteration) { coder.run }
        end

        test 'post processes should work as transformer' do
          memory = SimpleMemory.new
          memory.remember 'bar.xxx'

          custom_process = proc do |string|
            string + '.xxx'
          end

          coder = Coder.new TestSimpleCode::SimpleCode.new(%w[foo bar baz]),
                            memory: memory,
                            post_process: custom_process

          produced = []
          loop do
            produced << coder.run
          end

          assert_equal %w[foo.xxx baz.xxx], produced
          assert_raise(StopIteration) { coder.run }
        end

        test 'regexp post process should work' do
          coder = Coder.new TestSimpleCode::SimpleCode.new(%w[foo bar baz]), post_process: /^b/

          produced = []
          loop do
            produced << coder.run
          end

          assert_equal %w[bar baz], produced
        end

        test 'builtin post process should work' do
          coder = Coder.new TestSimpleCode::SimpleCode.new(%w[foo salak baz]), post_process: :safe?

          produced = []
          loop do
            produced << coder.run
          end

          assert_equal %w[foo baz], produced
        end

        test 'post process array should work' do
          coder = Coder.new TestSimpleCode::SimpleCode.new(%w[foo bar baz]), post_process: [
            /^b/,
            proc { |string| string + '.xxx' }
          ]

          produced = []
          loop do
            produced << coder.run
          end

          assert_equal %w[bar.xxx baz.xxx], produced
        end

        module TestDummy
          class Foo < Coder
            setup foo: 13
          end

          class Bar < Foo
            setup foo: 19, bar: 23
          end
        end

        test 'default options should be duplicated' do
          assert_equal 13, TestDummy::Foo.default_options[:foo]
          assert_nil       TestDummy::Foo.default_options[:bar]
          assert_equal 19, TestDummy::Bar.default_options[:foo]
          assert_equal 23, TestDummy::Bar.default_options[:bar]
        end

        test 'only codes should be accepted' do
          assert_raise(TypeError) { Coder.new 13 }
        end

        module TestBogus
          class Bogus < Code
            protected

            def take_in(source)
              source
            end

            def take_out(*)
              'same'
            end
          end
        end

        test 'loop guard works' do
          coder = Coder.new TestBogus::Bogus.new(0..Float::INFINITY)

          coder.run
          err = assert_raise(Error) { coder.run }
          assert err.message.include? 'many tries'
        end

        test 'dry run should work' do
          coder = Codification.sequential_numeric_codes '0013'..'9999'
          assert_equal '0013', coder.run
          assert_equal '0014', coder.dry
          assert_equal '0014', coder.run
        end
      end
    end
  end
end
