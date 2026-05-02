# .bashrc - Interactive shell setup
#
# Sources OS-specific, host-specific, and custom rc files.
# Environment variables and PATH are set in .bash_env (sourced from .bash_profile).

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Array of rc files to source
rc_files=(
  "$DIR/.bashrc_$(uname)"
  "$DIR/.bashrc_$(uname)_$(hostname)"
  "$HOME/.bash_env"
  "$HOME/.bash_custom"
  "$HOME/.bash_prompt"
)

# Iterate over rc files and source them if they exist
for rc_file in "${rc_files[@]}"; do
  [[ -e "$rc_file" ]] && source "$rc_file"
done

# Kiro shell integration
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path bash)"
