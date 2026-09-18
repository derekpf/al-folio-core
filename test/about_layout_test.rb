# frozen_string_literal: true

require_relative "test_helper"

class AboutLayoutTest < Minitest::Test
  def test_profile_float_is_placed_at_subtitle_start
    layout = ROOT.join("_layouts/about.liquid").read

    title_end = layout.index("</h1>")
    profile_start = layout.index('<div class="profile')
    subtitle_start = layout.index('<p class="desc">')
    article_start = layout.index("<article>")

    refute_nil title_end
    refute_nil profile_start
    refute_nil subtitle_start
    refute_nil article_start
    assert_operator title_end, :<, profile_start
    assert_operator profile_start, :<, subtitle_start
    assert_operator subtitle_start, :<, article_start
  end
end
