# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010, Sebastian Staudt

require 'test_parameter'

class TestOption < Test::Unit::TestCase

  include TestParameter

  context 'A Rubikon option' do

    should 'be a Parameter with arguments' do
      assert Option.included_modules.include?(Parameter)
      assert Option.included_modules.include?(HasArguments)
      assert Option.new(@app, :test).is_a?(Parameter)
    end

    should 'call its code block if it is activated' do
      block_run = false
      option = Option.new @app, :test do
        block_run = true
      end
      option.active!
      assert option.active?
      assert block_run
    end

  end

end