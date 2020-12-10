rm -r .vscode
rm -r .idea
rm -rf __pycache__
rm -rf *_imgs
rm -r ./grasp_generation/batch/*
rm -r ./grasp_generation/output/*

git add .
git commit -m "$1"
git push origin main
