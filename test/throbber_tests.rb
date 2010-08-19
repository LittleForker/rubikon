# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2009-2010, Sebastian Staudt

require 'test_helper'

class ThrobberTests < Test::Unit::TestCase

  context 'A throbber' do

    should 'be a subclass of Thread' do
      assert_equal Thread, Throbber.superclass
    end

    should 'have default throbber strings' do
      unless RUBY_VERSION[0..2] == '1.9'
        consts = %w{SPINNER}
      else
        consts = [:SPINNER, :MUTEX_FOR_THREAD_EXCLUSIVE]
      end
      assert_equal consts, Throbber.constants
      assert_equal '-\|/', Throbber.const_get(:SPINNER)
    end

    should 'work correctly' do
      ostream = StringIO.new
      started_at  = Time.now
      finished_at = nil
      thread = Thread.new do
        sleep 1
        finished_at = Time.now
      end
      throbber = Throbber.new(ostream, thread)
      thread.join
      throbber.join

      spinner = Throbber.const_get(:SPINNER)
      check_throbber = ' '
      ((finished_at - started_at) / 0.25).floor.times do |char_index|
        check_throbber << "\b"
        check_throbber << spinner[char_index % 4]
      end
      check_throbber << "\b"
      assert_equal check_throbber, ostream.string
    end

  end

end