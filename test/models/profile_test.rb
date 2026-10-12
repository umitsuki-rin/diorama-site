require "test_helper"

class ProfileTest < ActiveSupport::TestCase
  test "実績は1行1件で空行を除く" do
    profile = Profile.new(achievements: "一つ目\r\n\r\n 二つ目 \n")
    assert_equal [ "一つ目", "二つ目" ], profile.achievement_list
  end

  test "SNS の URL は http(s) のみ許可" do
    assert_not Profile.new(x_url: "x.com/diorama").valid?
  end
end
