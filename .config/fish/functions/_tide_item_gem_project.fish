function _tide_item_gem_project
    command -q gem; or return
    path is $_tide_parent_dirs/{*.gemspec,Gemfile,Rakefile,.ruby-version}; or return

    gem --version | string match -qr "(?<v>[\d.]+)"; or return
    _tide_print_item ruby $tide_ruby_icon' gem ' $v
end
