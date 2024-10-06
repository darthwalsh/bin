## Tool to easily set github required checks
https://github.com/marketplace/actions/alls-green#why
>Do you have more than one job in your GitHub Actions CI/CD workflows setup? Do you use branch protection? Are you annoyed that you have to manually update the required checks in the repository settings hoping that you don't forget something on each improvement of the test matrix structure?

## Generating README content automatically
See description and implementation of [this PR](https://github.com/DomT4/homebrew-autoupdate/pull/114).

1. Github action runs to checkout repo, run python script
2. python script looks for section starting `<!-- HELP-COMMAND-OUTPUT:START -->`
3. Rewrites README contents, and sets `$GITHUB_OUTPUT`
4. Runs git commit && push

> [!QUESTION]
> One thing that makes me nervous though, is could this trigger a recursive loop if the README editor wasn't idempotent (say it added an extra newline each execution?)
