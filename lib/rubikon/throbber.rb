# This code is free software; you can redistribute it and/or modify it under the
# terms of the new BSD License.
#
# Copyright (c) 2009, Sebastian Staudt

module Rubikon

  # A class for displaying and managing throbbers
  class Throbber

    THROBBER_SPINNER = '-\|/'

    # Returns a block that outputs to the given IO while the given thread is
    # alive
    #
    # The returned Proc has the following parameters:
    #
    # +ostream+:: The IO stream the throbber should be written to
    # +thread+::  The thread that should be watched
    def self.block
      return Proc.new do |ostream, thread|
          step = 0
          ostream.putc 32
          while thread.alive?
            ostream << "\b#{THROBBER_SPINNER[step].chr}"
            ostream.flush
            step = (step + 1) % 4
            sleep 0.25
          end
        ostream.putc 8
      end
    end

  end

end
