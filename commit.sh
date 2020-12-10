rm -r .vscode
rm -r .idea
rm -rf __pycache__
rm -rf *_imgs
git add .
git commit -m "$1"
git push origin main
