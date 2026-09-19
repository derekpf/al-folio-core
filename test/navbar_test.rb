# frozen_string_literal: true

require_relative "test_helper"

class NavbarTest < Minitest::Test
  def test_social_and_theme_controls_share_one_nav_item
    header = ROOT.join("_includes/header.liquid").read

    assert_includes header, "{% if site.enable_navbar_social or site.enable_darkmode %}"
    assert_includes header, '<li class="navbar-social-links" role="group" aria-label="Social links and theme">'
    assert_includes header, "{% social_links %}"
    assert_includes header, '<button id="light-toggle" type="button"'
    refute_includes header, 'class="toggle-container"'
  end

  def test_shared_controls_use_section_link_spacing
    styles = ROOT.join("_sass/_navbar.scss").read

    assert_includes styles, ".navbar-social-links {"
    assert_includes styles, "gap: 1rem;"
    assert_includes styles, "padding: 0.5rem 0;"
    assert_includes styles, "margin-left: 0;"
    assert_includes styles, "margin-right: 0;"
    assert_includes styles, "margin-left: 0.5rem;"
    assert_includes styles, "margin-right: 0.5rem;"
    assert_includes styles, "padding: 0;"
    assert_includes styles, "justify-content: flex-start;"
    refute_includes styles, "transform: translateY(4px);"
  end
end
