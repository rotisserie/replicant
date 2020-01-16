#!/bin/sh

commit()
{
  git checkout -b chore/repo-setup
  mv .github/workflows/replicant.yml .github/workflows/$REPO_NAME.yml
  git add .chglog .github doc.go go.mod Makefile README.md
  git commit -S -m "chore: setup repo"
  git push --set-upstream origin chore/repo-setup
}

destruct()
{
  echo "this script will self-destruct in"
  echo "3" && sleep 1
  echo "2" && sleep 1
  echo "1" && sleep 1
  rm retire.sh
}

read -p "github username or organization (default = rotisserie): " -e REPO_ORG
if [ "$REPO_ORG" == "" ]; then
  REPO_ORG="rotisserie"
fi
read -p "repo name: " -e REPO_NAME
read -p "repo tagline: Package $REPO_NAME " -e REPO_TAGLINE
PACKAGE_TAGLINE="Package $REPO_NAME $REPO_TAGLINE"
if [ "${PACKAGE_TAGLINE: -1}" != "." ]; then
  PACKAGE_TAGLINE+="."
fi

echo "configuring changelog"
sed -i '' "s|rotisserie|$REPO_ORG|g" .chglog/config.yml
sed -i '' "s|replicant|$REPO_NAME|g" .chglog/config.yml

echo "constructing ci"
sed -i '' "s|rotisserie|$REPO_ORG|g" .github/workflows/replicant.yml
sed -i '' "s|replicant|$REPO_NAME|g" .github/workflows/replicant.yml
echo "do you want to setup code coverage now? (y/n)"
read ANS
if [ "$ANS" == "y" ]; then
  sed -i '' "s|^#||g" .github/workflows/replicant.yml
else
  sed -i '' "/^#/d" .github/workflows/replicant.yml
fi

echo "preparing package"
sed -i '' "s|replicant|$REPO_NAME|g" doc.go
sed -i '' "1 s|^.*$|// $PACKAGE_TAGLINE|g" doc.go
sed -i '' "s|rotisserie|$REPO_ORG|g" go.mod
sed -i '' "s|replicant|$REPO_NAME|g" go.mod

echo "modifying makefile"
sed -i '' "1 s|^.*$|TAGLINE := \"$PACKAGE_TAGLINE\"|" Makefile

echo "revising readme"
rm README.md && echo "# $REPO_NAME\n\n$PACKAGE_TAGLINE" >> README.md

git diff
echo "does everything look okay? (y/n)"
read ANS
if [ "$ANS" == "y" ]; then
  commit
  destruct
else
  git add --patch .chglog .github doc.go go.mod Makefile README.md
  commit
  destruct
fi
