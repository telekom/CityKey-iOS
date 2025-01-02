git fetch origin
count=0;

targets=`git diff --diff-filter=d --name-only $(git merge-base origin/develop HEAD) -- "*.swift"`

IFS=$'\n'
for file_path in $targets; do
	export SCRIPT_INPUT_FILE_$count="$file_path"
    count=$((count + 1))
    export SCRIPT_INPUT_FILE_COUNT=$count
done

if [ $count == 0 ]
then
    exit 0;
fi

Pods/SwiftLint/swiftlint --strict --use-script-input-files --reporter html > swiftlint-modified-files-report.html
