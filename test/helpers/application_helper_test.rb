require 'test_helper'

SimpleCov.command_name "test:helpers"

class ApplicationHelperTest < ActionView::TestCase
  test "should show date" do
    date = Date.today + 5.days
    assert_equal date.strftime("%b %d"), simple_date(date)
  end

  test "should show date today" do
    date = Date.today
    assert_equal 'Today', simple_date(date)
  end

  test "should show date yesterday" do
    date = Date.today - 1.day
    assert_equal 'Yesterday', simple_date(date)
  end

  test "should show date tomorrow" do
    date = Date.today + 1.day
    assert_equal 'Tomorrow', simple_date(date)
  end

  test "should show full date from last year" do
    date = Date.today - 1.year
    assert_equal date.strftime("%b %d, %Y"), simple_date(date)
  end

  test "should show time" do
    time = Time.now
    assert_equal time.strftime("<b>Today</b> at %I:%M %p"), simple_time(time)
  end

  test "should show full time from yesterday" do
    time = Time.now - 1.day
    time += 2.days if time.year != Time.now.year # Test would fail if run on Jan 1st otherwise
    assert_equal time.strftime("on %b %d at %I:%M %p"), simple_time(time)
  end

  test "should show full time from last year" do
    time = Time.now - 1.year
    assert_equal time.strftime("on %b %d, %Y at %I:%M %p"), simple_time(time)
  end

  test "should show recent activity" do
    assert recent_activity(nil).kind_of?(String)
    assert recent_activity('').kind_of?(String)
    assert recent_activity(Time.now).kind_of?(String)
    assert recent_activity(Time.now - 12.hours).kind_of?(String)
    assert recent_activity(Time.now - 1.day).kind_of?(String)
    assert recent_activity(Time.now - 2.days).kind_of?(String)
    assert recent_activity(Time.now - 1.week).kind_of?(String)
    assert recent_activity(Time.now - 1.month).kind_of?(String)
    assert recent_activity(Time.now - 6.month).kind_of?(String)
    assert recent_activity(Time.now - 1.year).kind_of?(String)
    assert recent_activity(Time.now - 2.year).kind_of?(String)
  end

  test "should mark javascript url as unsafe" do
    assert_equal false, safe_url?("javascript:;")
  end

  test "should mark blank url as unsafe" do
    assert_equal false, safe_url?("")
    assert_equal false, safe_url?(nil)
  end

  test "should mark known schemes for urls as safe" do
    assert_equal true, safe_url?("http://www.example.com")
    assert_equal true, safe_url?("https://www.example.com")
    assert_equal true, safe_url?("ftp://ftp.example.com")
    assert_equal true, safe_url?("mailto:valid@example.com")
  end

  test "should escape leading numbers in description" do
    assert_equal "<p>&#53;. This is my description with a leading five.</p>\n", simple_markdown("5. This is my description with a leading five.")
  end

end
