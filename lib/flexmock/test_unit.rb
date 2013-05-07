#!/usr/bin/env ruby

#---
# Copyright 2003-2012 by Jim Weirich (jim.weirich@gmail.com).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require 'flexmock/test_unit_integration'

if defined?(MiniTest)
  require 'flexmock/minitest_testcase_extensions'
else
  require 'flexmock/testunit_testcase_extensions'
end
