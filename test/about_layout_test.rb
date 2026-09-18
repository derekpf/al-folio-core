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

  def test_site_name_uses_matching_bold_markup
    about_layout = ROOT.join("_layouts/about.liquid").read
    header = ROOT.join("_includes/header.liquid").read
    footer = ROOT.join("_includes/footer.liquid").read

    assert_includes about_layout, '<span class="font-weight-bold">{{ site.first_name }}</span>'
    assert_includes about_layout, '<span class="font-weight-bold">{{ site.last_name }}</span>'
    assert_includes header, "<span class=\"font-weight-bold\">\n                {{- site.last_name -}}\n              </span>"
    assert_includes footer, '<span class="font-weight-bold">{{ site.first_name }}</span>'
    assert_includes footer, '<span class="font-weight-bold">{{ site.last_name }}</span>'
  end

  def test_previous_role_heading_links_to_experience_page
    layout = ROOT.join("_layouts/about.liquid").read

    assert_includes layout, '<a href="{{ \'/experience/\' | relative_url }}" style="color: inherit"><strong>previous role</strong></a>'
  end

  def test_right_profile_matches_project_spacing
    styles = ROOT.join("_sass/_components.scss").read

    assert_match(/\.profile\.float-right\s*\{\s*margin-left:\s*30px;\s*margin-top:\s*1rem;/, styles)
  end
end
