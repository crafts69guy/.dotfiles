# Show only the toolchain versions relevant to the current project.
set -g tide_left_prompt_items \
    os pwd git node cargo_project ruby gem_project newline character

# Avoid rendering Tide's project-scoped variants a second time on the right.
set -l tide_right_items
for item in $tide_right_prompt_items
    contains -- $item node rustc ruby; or set -a tide_right_items $item
end
set -g tide_right_prompt_items $tide_right_items
