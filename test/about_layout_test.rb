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

  def test_site_identity_matches_section_heading_weight
    blog_styles = ROOT.join("_sass/_blog.scss").read
    navbar_styles = ROOT.join("_sass/_navbar.scss").read

    assert_includes blog_styles, ".post-title {"
    assert_includes blog_styles, "font-weight: 400;"
    assert_includes navbar_styles, ".font-weight-bold {\n        font-weight: 400;\n      }"
  end

  def test_navbar_brand_is_not_a_duplicate_about_link
    header = ROOT.join("_includes/header.liquid").read

    assert_includes header, '<span class="navbar-brand title font-weight-lighter">'
    refute_includes header, '<a class="navbar-brand title font-weight-lighter" href='
  end

  def test_about_navigation_uses_the_about_layout_identity
    header = ROOT.join("_includes/header.liquid").read

    assert_includes header, "{% if page.layout == 'about' %}"
    assert_includes header, "{% if p.layout == 'about' %}"
    assert_includes header, "{% assign about_url = p.url %}"
    refute_includes header, "page.permalink == '/'"
  end

  def test_navbar_brand_uses_the_section_link_hover_color
    navbar_styles = ROOT.join("_sass/_navbar.scss").read

    assert_match(
      /\.navbar-brand\s*\{.*?&\.title\s*\{.*?&:hover\s*\{\s*color: var\(--global-hover-color\);/m,
      navbar_styles
    )
  end

  def test_about_section_headings_use_the_increased_preceding_spacing
    layout = ROOT.join("_layouts/about.liquid").read
    blog_styles = ROOT.join("_sass/_blog.scss").read

    assert_equal 5, layout.scan('<section class="about-section">').length
    assert_equal 4, layout.scan('<h2 class="about-section-heading">').length
    assert_includes layout, '<h2 class="about-section-heading previous-role-heading">'
    assert_includes blog_styles, ".about-section {\n  display: flow-root;\n  padding-top: 3rem;\n}"
    assert_match(/\.about-section-heading \{\s+margin-top: 0;\s+text-transform: capitalize;/, blog_styles)
    refute_includes blog_styles, "project-highlights-heading"
  end

  def test_about_publication_sections_use_twice_the_paired_entry_gap
    blog_styles = ROOT.join("_sass/_blog.scss").read
    publication_styles = ROOT.join("_sass/_publications.scss").read

    assert_includes blog_styles, ".about-section > .about-section-heading + .publications {\n  margin-top: 22.5px;\n}"
    assert_includes publication_styles, "margin-bottom: 0;"
    assert_includes publication_styles, "& + li {\n        margin-top: 22.5px;\n      }"
    assert_includes publication_styles, "> figure {\n          margin-bottom: 0;\n        }"
    assert_includes publication_styles, "@media (min-width: 576px) {\n  .publications ol.bibliography li:not(:last-child) .description-border {\n    margin-bottom: 0.25rem;\n  }\n}"
  end

  def test_profile_moves_above_the_title_on_portrait_layouts
    component_styles = ROOT.join("_sass/_components.scss").read

    assert_includes component_styles, "@media (max-width: 575.98px)"
    assert_includes component_styles, ".post-header:has(> .profile) {\n    display: flex;\n    flex-direction: column;\n  }"
    assert_includes component_styles, ".post-header:has(> .profile) > .profile {\n    order: -1;\n    float: none !important;\n    margin: 0 0 1rem;\n  }"
  end

  def test_about_page_title_and_subtitle_use_requested_weight_and_scale
    blog_styles = ROOT.join("_sass/_blog.scss").read

    assert_includes blog_styles, "body:not(.non-home-page)"
    assert_includes blog_styles, ".post-title .font-weight-bold"
    assert_includes blog_styles, "font-weight: 400;"
    assert_includes blog_styles, ".desc {\n    font-weight: 300;\n    font-size: 1.2rem;\n  }"
  end

  def test_about_section_headings_use_the_section_link_color_animation
    blog_styles = ROOT.join("_sass/_blog.scss").read

    assert_includes blog_styles, "  transition: color 0.1s ease-in-out;"
    assert_includes blog_styles, "  a,\n  strong {\n    color: inherit;\n  }"
    assert_includes blog_styles, "  &:hover {\n    color: var(--global-hover-color);\n  }"
    assert_includes blog_styles, "@media (prefers-reduced-motion: reduce)"
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
