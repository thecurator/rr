dir = File.dirname(__FILE__)
require "#{dir}/test_helper"

class TestUnitBacktraceTest < Test::Unit::TestCase
  def setup
    super
    @subject = Object.new
  end

  def teardown
    super
  end

  def test_backtrace_tweaking
    old_result = @_result
    result = Test::Unit::TestResult.new

    error_display = nil
    result.add_listener(Test::Unit::TestResult::FAULT) do |f|
      error_display = f.long_display
    end
    test_case = self.class.new(:backtrace_tweaking)
    test_case.run(result) {}

    assert !error_display.include?("lib/rr")
  end

  def backtrace_tweaking
    mock(@subject).foobar
    RR::Space::instance.verify_scenario(@subject, :foobar)
  end
end