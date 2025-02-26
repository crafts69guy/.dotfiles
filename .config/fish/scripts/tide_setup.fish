#!/usr/bin/env fish

# Run Tide configuration with specified options
tide configure --auto \
    --style=Rainbow \
    --prompt_colors='True color' \
    --show_time='24-hour format' \
    --rainbow_prompt_separators=Angled \
    --powerline_prompt_heads=Sharp \
    --powerline_prompt_tails=Sharp \
    --powerline_prompt_style='Two lines, character and frame' \
    --prompt_connection=Dotted \
    --powerline_right_prompt_frame=No \
    --prompt_connection_andor_frame_color=Dark \
    --prompt_spacing=Compact \
    --icons='Many icons' \
    --transient=Yes

# Print a log message after execution
echo "✅ Tide configuration applied successfully! Restart your shell or run 'exec fish' to apply changes."
