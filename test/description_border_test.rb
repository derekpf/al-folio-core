# frozen_string_literal: true

require_relative "test_helper"

class DescriptionBorderTest < Minitest::Test
  PROJECT_TEMPLATES = %w[
    _includes/project_highlights.liquid
    _includes/projects.liquid
    _includes/projects_horizontal.liquid
  ].freeze

  def test_description_border_is_a_shrink_wrapped_entry_border
    styles = ROOT.join("_sass/_utilities.scss").read
    declaration = styles[/\.description-border\s*\{(.*?)\n\}/m, 1]

    refute_nil declaration
    assert_includes declaration, "border-top: 1px solid var(--global-divider-color);"
    assert_includes declaration, "border-right: 1px solid var(--global-divider-color);"
    assert_includes declaration, "border-bottom: 1px solid var(--global-divider-color);"
    assert_includes declaration, "border-left: 1px solid var(--global-divider-color);"
    assert_includes declaration, "padding: calc(0.25rem + 5px) 0.5rem;"
    assert_includes declaration, "margin-top: -0.25rem;"
    assert_includes declaration, "display: inline-block;"
    assert_includes declaration, "width: fit-content;"
    assert_includes declaration, "max-width: 100%;"
    assert_includes declaration, "box-sizing: border-box;"
    assert_includes declaration, "0 2px 5px 0 rgba(0, 0, 0, 0.16),"
    assert_includes declaration, "0 2px 10px 0 rgba(0, 0, 0, 0.12);"
    assert_includes declaration, "border-color 0.2s ease,"
    assert_includes declaration, "box-shadow 0.2s ease;"

    assert_includes styles, ".description-border > :last-child"
    assert_includes styles, "margin-bottom: 0;"
    assert_includes styles, "padding-bottom: 0;"
  end

  def test_description_border_has_theme_aware_hover_and_reduced_motion_contracts
    styles = ROOT.join("_sass/_utilities.scss").read

    assert_includes styles, ".description-border:hover"
    assert_includes styles, ".description-border:focus-within"
    assert_includes styles, "border-color: var(--global-hover-color);"
    assert_includes styles, "color-mix(in srgb, var(--global-hover-color) 18%, transparent)"
    assert_includes styles, "@media (prefers-reduced-motion: reduce)"
    assert_includes styles, "transition: none;"
    assert_includes styles, "html.transition .description-border"
  end

  def test_description_titles_share_the_border_color_animation
    styles = ROOT.join("_sass/_utilities.scss").read

    assert_includes styles, ".description-border .description-title"
    assert_includes styles, "font-weight: 500 !important;"
    assert_includes styles, "transition: color 0.2s ease;"
    assert_includes styles, ".description-border:hover .description-title"
    assert_includes styles, ".description-border:focus-within .description-title"
    assert_includes styles, "html.transition .description-border .description-title"

    assert_includes ROOT.join("_layouts/bib.liquid").read, 'class="title description-title"'
    PROJECT_TEMPLATES.each do |template_name|
      assert_includes ROOT.join(template_name).read, "description-title"
    end
  end

  def test_images_use_the_same_depth_border_and_theme_aware_hover_glow
    styles = ROOT.join("_sass/_utilities.scss").read
    image_declaration = styles[/^img\s*\{(.*?)\n\}/m, 1]

    refute_nil image_declaration
    assert_includes image_declaration, "border: 1px solid var(--global-divider-color);"
    assert_includes image_declaration, "box-sizing: border-box;"
    assert_includes image_declaration, "0 2px 5px 0 rgba(0, 0, 0, 0.16),"
    assert_includes image_declaration, "0 2px 10px 0 rgba(0, 0, 0, 0.12);"
    assert_includes image_declaration, "border-color 0.2s ease,"
    assert_includes image_declaration, "box-shadow 0.2s ease;"
    hover_declaration = styles[/\.description-border:hover,\n\.description-border:focus-within,\nimg:hover,\nimg:focus-visible,\n\.bibsearch-form-input:hover,\n\.bibsearch-form-input:focus-visible \{(.*?)\n\}/m, 1]

    refute_nil hover_declaration
    assert_includes hover_declaration, "border-color: var(--global-hover-color);"
    assert_includes styles, "img:hover"
    assert_includes styles, "img:focus-visible"
    assert_includes styles, ".bibsearch-form-input:hover"
    assert_includes styles, ".bibsearch-form-input:focus-visible"
    assert_includes styles, "html.transition img"
    assert_includes styles, "html.transition .bibsearch-form-input"
  end

  def test_profile_images_keep_their_base_border_and_shadow_on_hover
    styles = ROOT.join("_sass/_utilities.scss").read

    assert_includes styles, ".profile img:hover"
    assert_includes styles, ".profile img:focus-visible"
    assert_includes styles, "border-color: var(--global-divider-color);"
    assert_includes styles, "0 2px 5px 0 rgba(0, 0, 0, 0.16),"
    assert_includes styles, "0 2px 10px 0 rgba(0, 0, 0, 0.12);"
  end

  def test_publication_search_uses_the_description_depth_and_hover_contract
    styles = ROOT.join("_sass/_utilities.scss").read
    search_declaration = styles.scan(/^\.bibsearch-form-input\s*\{(.*?)\n\}/m).last&.first

    refute_nil search_declaration
    assert_includes search_declaration, "background-color: var(--global-bg-color);"
    assert_includes search_declaration, "border: 1px solid var(--global-divider-color);"
    assert_includes search_declaration, "0 2px 5px 0 rgba(0, 0, 0, 0.16),"
    assert_includes search_declaration, "0 2px 10px 0 rgba(0, 0, 0, 0.12);"
    assert_includes search_declaration, "border-color 0.2s ease,"
    assert_includes search_declaration, "box-shadow 0.2s ease;"
    assert_includes ROOT.join("_includes/bib_search.liquid").read, 'class="search bibsearch-form-input"'
  end

  def test_publication_and_project_renderers_use_the_shared_wrapper
    assert_includes ROOT.join("_layouts/bib.liquid").read, 'class="description-border"'

    PROJECT_TEMPLATES.each do |template_name|
      template = ROOT.join(template_name).read
      assert_includes template, 'class="description-border"', "#{template_name} should use the shared wrapper"
    end
  end

  def test_publication_wrapper_contains_the_text_column_content
    template = ROOT.join("_layouts/bib.liquid").read
    wrapper_start = template.index('<div class="description-border">')

    assert_operator wrapper_start, :<, template.index('<!-- Title -->', wrapper_start)
    assert_operator wrapper_start, :<, template.index('<div class="links">', wrapper_start)
    assert_operator template.rindex('</div>'), :>, template.index('<div class="links">', wrapper_start)
  end
end
