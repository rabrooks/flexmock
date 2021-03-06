require 'flexmock/test_unit'

class TestSimple < Test::Unit::TestCase

  # Simple stubbing of some methods

  def test_simple_mock
    m = flexmock(:pi => 3.1416, :e => 2.71)
    assert_equal 3.1416, m.pi
    assert_equal 2.71, m.e
  end
end


class TestUndefined < Test::Unit::TestCase

  # Create a mock object that returns an undefined object for method calls

  def test_undefined_values
    m = flexmock("mock")
    m.should_receive(:divide_by).with(0).
      and_return_undefined
    assert_equal FlexMock.undefined, m.divide_by(0)
  end
end

class TestDb < Test::Unit::TestCase

  # Expect multiple queries and a single update

  # Multiple calls to the query method will be allows, and calls may
  # have any argument list. Each call to query will return the three
  # element array [1, 2, 3]. The call to update must have a specific
  # argument of 5.

  def test_db
    db = flexmock('db')
    db.should_receive(:query).and_return([1,2,3])
    db.should_receive(:update).with(5).and_return(nil).once

    # Test Code

    db.query
    db.update(5)
  end
end

class TestOrdered < Test::Unit::TestCase

  # Expect all queries before any updates

  # All the query message must occur before any of the update
  # messages.

  def test_query_and_update
    db = flexmock('db')
    db.should_receive(:query).and_return([1,2,3]).ordered
    db.should_receive(:update).and_return(nil).ordered

    # test code here

    db.query
    db.update
  end
end

class MoreOrdered < Test::Unit::TestCase

  # Expect several queries with different parameters

  # The queries should happen after startup but before finish. The
  # queries themselves may happen in any order (because they are in
  # the same order group). The first two queries should happen exactly
  # once, but the third query (which matches any query call with a
  # four character parameter) may be called multiple times (but at
  # least once). Startup and finish must also happen exactly once.

  # Also note that we use the <code>with</code> method to match
  # different argument values to figure out what value to return.

  def test_ordered_queries
    db = flexmock('db')
    db.should_receive(:startup).once.ordered
    db.should_receive(:query).with("CPWR").and_return(12.3).
      once.ordered(:queries)
    db.should_receive(:query).with("MSFT").and_return(10.0).
      once.ordered(:queries)
    db.should_receive(:query).with(/^....$/).and_return(3.3).
      at_least.once.ordered(:queries)
    db.should_receive(:finish).once.ordered

    # Test Code

    db.startup
    db.query("MSFT")
    db.query("XYZY")
    db.query("CPWR")
    db.finish
  end
end

class EvenMoreOrderedTest < Test::Unit::TestCase

  # Same as above, but using the Record Mode interface

  # The record mode interface offers much the same features as the
  # <code>should_receive</code> interface introduced so far, but it
  # allows the messages to be sent directly to a recording object
  # rather than be specified indirectly using a symbol.


  def test_ordered_queries_in_record_mode
    db = flexmock('db')
    db.should_expect do |rec|
      rec.startup.once.ordered
      rec.query("CPWR") { 12.3 }.once.ordered(:queries)
      rec.query("MSFT") { 10.0 }.once.ordered(:queries)
      rec.query(/^....$/) { 3.3 }.at_least.once.ordered(:queries)
      rec.finish.once.ordered
    end

    # Test Code

    db.startup
    db.query("MSFT")
    db.query("XYZY")
    db.query("CPWR")
    db.finish
  end
end

class RecordedTest < Test::Unit::TestCase

  # Using Record Mode to record a known, good algorithm for testing

  # Record mode is nice when you have a known, good algorithm that can
  # use a recording mock object to record the steps. Then you compare
  # the execution of a new algorithm to behavior of the old using the
  # recorded expectations in the mock. For this you probably want to
  # put the recorder in _strict_ mode so that the recorded
  # expectations use exact matching on argument lists, and strict
  # ordering of the method calls.

  # <b>Note:</b> This is most useful when there are no queries on the
  # mock objects, because the query responses cannot be programmed
  # into the recorder object.

  def test_build_xml
    builder = flexmock('builder')
    builder.should_expect do |rec|
      rec.should_be_strict
      known_good_way_to_build_xml(rec)  # record the messages
    end
    new_way_to_build_xml(builder)       # compare to new way
  end

  def known_good_way_to_build_xml(builder)
    builder.person
  end

  def new_way_to_build_xml(builder)
    builder.person
  end

end

class MultipleReturnValueTest < Test::Unit::TestCase

  # Expect multiple calls, returning a different value each time

  # Sometimes you need to return different values for each call to a
  # mocked method. This example shifts values out of a list for this
  # effect.

  def test_multiple_gets
    file = flexmock('file')
    file.should_receive(:gets).with_no_args.
      and_return("line 1\n", "line 2\n")

    # test code here

    file.gets                   # returns "line 1"
    file.gets                   # returns "line 2"
  end
end

class IgnoreUnimportantMessages < Test::Unit::TestCase

  # Ignore uninteresting messages

  # Generally you need to mock only those methods that return an
  # interesting value or wish to assert were sent in a particular
  # manner. Use the <code>should_ignore_missing</code> method to turn
  # on missing method ignoring.

  def test_an_important_message
    m = flexmock('m')
    m.should_receive(:an_important_message).and_return(1).once
    m.should_ignore_missing

    # Test Code

    m.an_important_message
    m.an_unimportant_message
  end

  # When <code>should_ignore_missing</code> is enabled, ignored
  # missing methods will return an undefined object. Any operation on
  # the undefined object will return the undefined object.

end

class PartialMockTest < Test::Unit::TestCase

  # Mock just one method on an existing object

  # The Portfolio class calculate the value of a set of stocks by
  # talking to a quote service via a web service. Since we don't want
  # to use a real web service in our unit tests, we will mock the
  # quote service.

  def test_portfolio_value
    flexmock(QuoteService).new_instances do |m|
      m.should_receive(:quote).and_return(100)
    end
    port = Portfolio.new
    value = port.value     # Portfolio calls QuoteService.quote
    assert_equal 100, value
  end

  class QuoteService
  end

  class Portfolio
    def value
      qs = QuoteService.new
      qs.quote
    end
  end
end
