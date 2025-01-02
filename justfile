# List all the just commands
default:
  @just --list

# Run mdbook live server
run:
  nix run .#serve

# Do link checks on docs
check:
    nix run .#linkCheck
