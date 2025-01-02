#git fetch
#git diff --diff-filter=d --name-only $(git merge-base origin/develop HEAD) -- "*.swift" | while read -r line; do Pods/SwiftLint/swiftlint autocorrect "$line"; done

Pods/SwiftLint/swiftlint --reporter html > swiftlint-report.html

