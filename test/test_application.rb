# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2009-2010, Sebastian Staudt

require 'test_helper'
require 'testapps'

class TestApplication < Test::Unit::TestCase

  context 'A Rubikon application\'s class' do

    setup do
      @app = TestApp.instance
    end

    should 'be a singleton' do
      assert_raise NoMethodError do
        TestApp.new
      end
    end

    should 'run it\'s instance for called methods' do
      assert_equal @app.run(%w{object_id}), TestApp.run(%w{object_id})
    end

  end

  context 'A Rubikon application' do

    setup do
      @app = TestApp
      @ostream = StringIO.new
      @app.set :ostream, @ostream
    end

    should 'exit gracefully' do
      @app.set :raise_errors, false
      begin
        @app.run(%w{unknown})
      rescue Exception => e
        assert_instance_of SystemExit, e
        assert_equal 1, e.status
      end
      @ostream.rewind
      assert_equal "Error:\n", @ostream.gets
      assert_equal "    Unknown command: unknown\n", @ostream.gets
      @app.set :raise_errors, true
    end

    should 'run its default command without arguments' do
      assert_equal 'default command', @app.run([])
    end

    should 'raise an exception when using an unknown command' do
      assert_raise UnknownCommandError do
        @app.run(%w{unknown})
      end
    end

    should 'raise an exception when run without arguments without default' do
      assert_raise NoDefaultCommandError do
        TestAppWithoutDefault.run([])
      end
    end

    should 'be able to handle user input' do
      @istream = StringIO.new
      @app.set :istream, @istream

      input_string = 'test'
      @istream.puts input_string
      @istream.rewind
      assert_equal input_string, @app.run(%w{input})
      @ostream.rewind
      assert_equal 'input: ', @ostream.gets
    end

    should "not break output while displaying a throbber or progress bar" do
      @app.run(%w{throbber})
      assert_equal " \b-\b\\\b|\b/\bdon't\nbreak\n", @ostream.string
      @ostream.rewind

      @app.run(%w{progressbar})
      assert_equal "#" * 20 << "\n" << "test\n" * 4, @ostream.string
    end

    should 'have working command aliases' do
      assert_equal @app.run(%w{alias_before}), @app.run(%w{object_id})
      assert_equal @app.run(%w{alias_after}), @app.run(%w{object_id})
    end

    should 'have a global debug flag' do
      @app.run(%w{--debug})
      assert $DEBUG
      $DEBUG = false
      @app.run(%w{-d})
      assert $DEBUG
      $DEBUG = false
    end

    should 'have a global verbose flag' do
      @app.run(%w{--verbose})
      assert $VERBOSE
      $VERBOSE = false
      @app.run(%w{-v})
      assert $VERBOSE
      $VERBOSE = false
    end

    should 'have working global options' do
      assert_equal 'test', @app.run(%w{globalopt --gopt test})
    end

    should 'have a working help command' do
      @app.run(%w{help})
      assert_match /Usage: [^ ]* \[--debug\|-d\] \[--gopt\|--go \.\.\.\] \[--verbose\|-v\] command \[args\]\n\nCommands:\n  globalopt      \n  help           Display this help screen\n  input          \n  object_id      \n  parameters     \n  progressbar    \n  sandbox        \n  throbber       \n/, @ostream.string
    end

    should 'have a working DSL for command parameters' do
      params = @app.run(%w{parameters}).values.uniq.sort { |a,b| a.name.to_s <=> b.name.to_s }
      assert_equal :flag, params[0].name
      assert_equal [:f], params[0].aliases
      assert_equal :option, params[1].name
      assert_equal [:o], params[1].aliases
    end

    should 'be protected by a sandbox' do
      %w{init parse_arguments run}.each do |method|
        assert_raise NoMethodError do
          @app.run(['sandbox', method])
        end
      end
    end

  end

end