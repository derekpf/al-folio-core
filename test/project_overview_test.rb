# frozen_string_literal: true

require_relative "test_helper"
require "fileutils"
require "jekyll"
require "tmpdir"

class ProjectOverviewTest < Minitest::Test
  CARD_INCLUDES = %w[projects.liquid projects_horizontal.liquid].freeze
  PROJECT_OVERVIEW_INCLUDES = (CARD_INCLUDES + ["selected_projects.liquid"]).freeze

  def render_overviews
    Dir.mktmpdir("al-folio-project-overviews-") do |source|
      destination = File.join(source, "_site")
      FileUtils.mkdir_p(File.join(source, "_layouts"))
      FileUtils.mkdir_p(File.join(source, "_includes"))
      FileUtils.mkdir_p(File.join(source, "_projects"))

      CARD_INCLUDES.each do |include_name|
        FileUtils.cp(ROOT.join("_includes", include_name), File.join(source, "_includes", include_name))
      end

      File.write(File.join(source, "_config.yml"), <<~YAML)
        collections:
          projects:
            output: false
        baseurl: /al-folio
        url: https://example.com
      YAML
      File.write(File.join(source, "_layouts", "default.liquid"), "<!doctype html><body>{{ content }}</body>\n")
      File.write(File.join(source, "_projects", "example.md"), <<~MARKDOWN)
        ---
        title: Example Project
        tagline: Short project overview
        description: Legacy project description
        ---
      MARKDOWN
      File.write(File.join(source, "index.md"), <<~MARKDOWN)
        ---
        layout: default
        permalink: /
        ---
        {% assign project = site.projects | first %}
        {% include projects.liquid %}
        {% include projects_horizontal.liquid %}
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

  def test_grid_and_horizontal_project_cards_render_the_tagline
    html = render_overviews

    assert_equal 2, html.scan("Short project overview").length
    refute_includes html, "Legacy project description"
  end

  def test_project_overview_templates_use_tagline_without_a_description_fallback
    PROJECT_OVERVIEW_INCLUDES.each do |include_name|
      template = ROOT.join("_includes", include_name).read

      assert_includes template, "project.tagline"
      refute_includes template, "project.description"
    end
  end
end
