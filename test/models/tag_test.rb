require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "validators" do
    tag = Tag.new
    assert_not tag.valid?, "Valid when it should be invalid."
    assert_equal [
      "Account must exist",
      "Name can't be blank",
      "Taggable must exist"
    ], tag.errors.full_messages.sort
  end
end
