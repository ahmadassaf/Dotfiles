# Exit if Homebrew is not installed.
[[ ! "$(type -P brew)" ]] && e_error "Brew casks need Homebrew to install." && return 1

# Tap Homebrew kegs.
function brew_tap_kegs() {
  kegs=($(setdiff "${kegs[*]}" "$(brew tap)"))
  if (( ${#kegs[@]} > 0 )); then
    echo "Tapping Homebrew kegs: ${kegs[*]}"
    for keg in "${kegs[@]}"; do
      brew tap $keg
    done
  fi
}

# Ensure the cask keg and recipe are installed.
kegs=(caskroom/cask)
brew_tap_kegs

# Exit if, for some reason, cask is not installed.
[[ ! "$(brew ls --versions brew-cask)" ]] && e_error "Brew-cask failed to install." && return 1

# Hack to show the first-run brew-cask password prompt immediately.
brew cask info this-is-somewhat-annoying 2>/dev/null

# Homebrew casks
casks=(
  # Applications
  a-better-finder-rename
  bettertouchtool
  charles
  dropbox
  fastscripts
  firefox
  google-chrome
  gyazo
  hex-fiend
  iterm2
  launchbar
  macvim
  spotify
  steam
  the-unarchiver
  todoist
  tower
  transmission-remote-gui
  vlc
  sublime-text-3
  imagealpha
	imageoptim
  # Quick Look plugins
  betterzipql
  qlcolorcode
  qlmarkdown
  qlprettypatch
  qlstephen
  quicklook-csv
  quicklook-json
  quicknfo
  suspicious-package
  webp-quicklook
  # Color pickers
  colorpicker-developer
  colorpicker-skalacolor
)

# Install Homebrew casks.
casks=($(setdiff "${casks[*]}" "$(brew cask list 2>/dev/null)"))
if (( ${#casks[@]} > 0 )); then
  echo "Installing Homebrew casks: ${casks[*]}"
  for cask in "${casks[@]}"; do
    brew cask install $cask
  done
  brew cask cleanup
fi

# Work around colorPicker symlink issue.
# https://github.com/caskroom/homebrew-cask/issues/7004
cps=()
for f in ~/Library/ColorPickers/*.colorPicker; do
  [[ -L "$f" ]] && cps=("${cps[@]}" "$f")
done

if (( ${#cps[@]} > 0 )); then
  echo "Fixing colorPicker symlinks"
  for f in "${cps[@]}"; do
    target="$(readlink "$f")"
    echo "$(basename "$f")"
    rm "$f"
    cp -R "$target" ~/Library/ColorPickers/
  done
fi

