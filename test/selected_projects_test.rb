# frozen_string_literal: true

require_relative "test_helper"
require "fileutils"
require "jekyll"
require "tmpdir"

class SelectedProjectsSocialLinksTag < Liquid::Tag
  def render(_context)
    ""
  end
end

Liquid::Template.register_tag("social_links", SelectedProjectsSocialLinksTag)

# Exercise the about layout and selected-project include together in a minimal Jekyll site.
# This keeps the contract covered without coupling the core gem to the starter's full fixture.
class SelectedProjectsTest < Minitest::Test
  def render_page(selected_projects: :omitted)
    Dir.mktmpdir("al-folio-selected-projects-") do |source|
      destination = File.join(source, "_site")
      FileUtils.mkdir_p(File.join(source, "_layouts"))
      FileUtils.mkdir_p(File.join(source, "_includes"))
      FileUtils.mkdir_p(File.join(source, "_projects"))

      FileUtils.cp(ROOT.join("_layouts", "about.liquid"), File.join(source, "_layouts", "about.liquid"))
      FileUtils.cp(ROOT.join("_includes", "selected_projects.liquid"), File.join(source, "_includes", "selected_projects.liquid"))

      File.write(File.join(source, "_config.yml"), <<~YAML)
        collections:
          projects:
            output: false
        baseurl: /al-folio
        url: https://example.com
      YAML
      File.write(File.join(source, "_layouts", "default.liquid"), "<!doctype html><body>{{ content }}</body>\n")
      File.write(File.join(source, "_includes", "figure.liquid"), <<~LIQUID)
        <figure data-path="{{ include.path }}" data-sizes="{{ include.sizes }}" data-class="{{ include.class }}" data-zoomable="{{ include.zoomable }}" data-avoid-scaling="{{ include.avoid_scaling }}" data-alt="{{ include.alt }}"></figure>
      LIQUID
      File.write(File.join(source, "_includes", "selected_papers.liquid"), "<div class=\"selected-publication\">selected publication</div>\n")

      write_project(source, "alpha", "Alpha Project", "alpha tagline", 0, "assets/img/alpha.png")
      write_project(source, "beta", "Beta Project", "beta tagline", 1, "assets/img/beta.png")

      selection = if selected_projects == :omitted
                   ""
                 elsif selected_projects.empty?
                   "selected_projects: []\n"
                 else
                   "selected_projects:\n#{selected_projects.map { |slug| "  - #{slug}" }.join("\n")}\n"
                 end
      File.write(File.join(source, "index.md"), <<~MARKDOWN)
        ---
        layout: about
        title: About
        permalink: /
        selected_papers: true
        #{selection}---
        Biography.
      MARKDOWN

      config = Jekyll.configuration(
        "source" => source,
        "destination" => destination,
        "quiet" => true,
        "trace" => true,
      )
      Jekyll::Site.new(config).process
      File.read(File.join(destination, "index.html"), encoding: "UTF-8")
    end
  end

  def write_project(source, slug, title, tagline, importance, image)
    File.write(File.join(source, "_projects", "#{slug}.md"), <<~MARKDOWN)
      ---
      layout: page
      title: #{title}
      importance: #{importance}
      img: #{image}
      tagline: #{tagline}
      ---
    MARKDOWN
  end

  def test_projects_follow_configured_order_and_preserve_image_handling
    html = render_page(selected_projects: %w[beta alpha missing])

    assert_includes html, '<a href="/al-folio/projects/" style="color: inherit">selected projects</a>'
    assert_operator html.index("Beta Project"), :<, html.index("Alpha Project")
    assert_includes html, "beta tagline"
    refute_includes html, "beta description"
    refute_includes html, "Missing Project"
    assert_includes html, 'data-path="assets/img/beta.png"'
    assert_includes html, 'data-sizes="200px"'
    assert_includes html, 'data-class="preview z-depth-1 rounded"'
    assert_includes html, 'data-zoomable="true"'
    assert_includes html, 'data-avoid-scaling="true"'
  end

  def test_selected_projects_are_before_selected_publications
    html = render_page(selected_projects: ["beta"])

    assert_operator html.index("Beta Project"), :<, html.index("selected publication")
  end

  def test_absent_or_empty_selection_renders_no_project_section
    [:omitted, []].each do |selection|
      html = render_page(selected_projects: selection)

      refute_includes html, "selected projects"
      refute_includes html, "Beta Project"
      assert_includes html, "selected publication"
    end
  end
end
