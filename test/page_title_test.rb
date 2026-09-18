# frozen_string_literal: true

require_relative "test_helper"

class PageTitleTest < Minitest::Test
  def test_non_home_pages_are_marked_for_shared_title_styling
    default_layout = ROOT.join("_layouts/default.liquid").read
    distill_layout = ROOT.join("_layouts/distill.liquid").read
    styles = ROOT.join("_sass/_blog.scss").read

    assert_includes default_layout, '{% if page.url != \'/\' %}non-home-page {% endif %}'
    assert_includes distill_layout, '{% if page.url != \'/\' %}non-home-page {% endif %}'
    assert_includes distill_layout, '<h1 class="post-title">{{ page.title }}</h1>'
    assert_includes styles, "body.non-home-page .post-title {\n  font-weight: 400;\n}"
  end
end
