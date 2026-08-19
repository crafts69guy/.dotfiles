function _tide_item_cargo_project
    command -q cargo; or return
    path is $_tide_parent_dirs/Cargo.toml; or return

    cargo --version | string match -qr "cargo (?<v>[\d.]+)"; or return
    _tide_print_item rustc $tide_rustc_icon' ' $v
end
