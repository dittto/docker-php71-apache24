#!/bin/bash

composer create-project symfony/framework-standard-edition temp
rm -rf web
mv -f temp/* .
cat temp/.gitignore >> .gitignore
rm -rf temp
