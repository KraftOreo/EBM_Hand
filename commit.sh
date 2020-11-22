rm -r ".vscode"
rm -r "__pycache__"
git add .
git commit -m "$1"
git push