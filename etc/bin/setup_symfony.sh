#!/bin/bash

composer create-project symfony/framework-standard-edition temp
rm -rf web
mv -f temp/* .
paste temp/.gitignore .gitignore > .gitignore
rm -rf temp
