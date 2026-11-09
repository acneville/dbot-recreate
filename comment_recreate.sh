#!/usr/bin/env bash

# must run chmod +x comment_recreate.sh to use
# also must have github CLI installed to use `gh`
# note: posting recreate does not always invoke dbot, may need to investigate awaiting
# However, running this is an excellent way to clear out your queue after an npck.
# Expect a LOT of emails.
set -euo pipefail

main() {
  local repo_source

  if [[ $# -eq 1 ]]; then
    REPO="$1"
    repo_source="argument"
  else
    echo "RIP, you need an arg"
    exit 1
  fi

  echo "Finding open Dependabot PRs in $REPO..."
  echo "Using repository from $repo_source."

  PR_NUMBERS=$(gh pr list \
    --repo "$REPO" \
    --state open \
    --app dependabot \
    --json number \
    --jq '.[].number')

  if [[ -z "${PR_NUMBERS}" ]]; then
    echo "No open Dependabot PRs found."
    exit 0
  fi

  echo "Posting '@dependabot recreate' to:"
  echo "$PR_NUMBERS"

  while IFS= read -r pr; do
    [[ -z "$pr" ]] && continue
    echo "Commenting on PR #$pr"
    gh pr comment "$pr" \
      --repo "$REPO" \
      --body "@dependabot recreate"
      
    # note: if there is a merge conflict dbot usually won't respond to any mentions
    # and thus you will need to take care of it manually
    
  done <<< "$PR_NUMBERS"

  echo "Done."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
