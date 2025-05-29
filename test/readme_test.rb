# frozen_string_literal: true

require_relative "test_helper"

describe "README.md" do
  it "contains the up-to-date content of examples/mcp-compose.yml" do
    readme_content = File.read(File.expand_path("../README.md", __dir__))
    example_file_content = File.read(File.expand_path("../examples/mcp-compose.yml", __dir__))

    example_section = extract_example_from_readme(readme_content)

    expected_example_section = <<~MD.strip
      ```yaml
      #{example_file_content.strip}
      ```
    MD
    value(example_section).must_equal expected_example_section,
      "The example in README.md should match the content of examples/mcp-compose.yml"
  end

  private

  def extract_example_from_readme(readme_content)
    example_begin_marker = "<!-- examples/mcp-compose.yml begin -->"
    example_end_marker = "<!-- examples/mcp-compose.yml end -->"

    example_section_match = readme_content.match(/#{Regexp.escape(example_begin_marker)}(.*?)#{Regexp.escape(example_end_marker)}/m)
    value(example_section_match).wont_be_nil "README.md should contain example markers"

    example_section_match[1].strip
  end
end
