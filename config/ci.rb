# Run using bin/ci (the same gates as .github/workflows/ci.yml, locally)

CI.run do
  step "Setup", "bin/setup --skip-server"

  step "Style: Ruby", "bin/rubocop"
  step "Boundaries: Packwerk", "bin/packwerk validate && bin/packwerk check"
  step "Types: TypeScript", "npm run check"

  step "Security: Gem audit", "bin/bundler-audit"
  step "Security: Brakeman code analysis", "bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error"
  step "Tests: app + packs", "bin/rails test test packs"
end
