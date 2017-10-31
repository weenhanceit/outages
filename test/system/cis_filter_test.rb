require "application_system_test_case"

class CisFilterTest < ApplicationSystemTestCase # rubocop:disable Metrics/ClassLength, Metrics/LineLength
  test "text filter" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 10, 17, 21) do
        sign_in_for_system_tests(users(:edit_ci_outages_d))
        current_window.maximize
        visit cis_url
        assert_selector "tbody tr", count: 2
        @account.cis.each do |ci|
          assert_text ci.name
        end

        fill_in "Text", with: "B\n"
        assert_no_text "Server AA"

        click_link "Outages"
        assert_text "Outage"
        click_link "Services"
        assert_selector "h1", text: "Services"
        assert_no_text "Server AA"
        assert_field "Text", with: "B"
        assert_text "Server BB"
      end
    end
  end

  test "watching filter" do
    Time.use_zone(ActiveSupport::TimeZone["Samoa"]) do
      travel_to Time.zone.local(2017, 07, 28, 10, 17, 21) do
        sign_in_for_system_tests(users(:edit_ci_outages_d))
        current_window.maximize
        visit cis_url
        assert_selector "tbody tr", count: 2
        @account.cis.each do |ci|
          assert_text ci.name
        end

        choose "cis_watching_Of_interest_to_me"
        assert_no_text "Server BB"
        assert_text "Server AA"

        click_link "Outages"
        assert_text "Outage"
        click_link "Services"
        assert_selector "h1", text: "Services"
        assert_checked_field "cis_watching_Of_interest_to_me"
        assert_no_text "Server BB"
        assert_text "Server AA"
      end
    end
  end

  private

  def setup
    @account = Account.find_by(name: "Company D")
  end
end
