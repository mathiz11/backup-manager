# Backup manager

This was my first project in 2018 during my studies.

I needed to create a backup manager in bash. It permits to manage file tree on your Linux system.

This script allows you to make different backups of the chosen tree structure, display the differences between two versions in an html file (with Firefox), browse the tree structure where is situated the backup.

Our program does not allow to compare the different versions of files with patch command.

## Installation

There is nothing to do

## Usage

The script can be launched anywhere but since the backup is done in a folder that will be in the "\$HOME",
this means that the tree structure chosen to have a different path.

You must install a package called "tree". It permits to list recursive directory.

You need to open a terminal and go to folder where contains the script.

```bash
    ./script.sh
```

When the program is launched for the first time, the tree will be requested as well as stored and a menu will appear with different choices of actions to perform.

When you want to delete the entire backup (what the script to generate), it is then necessary if you want to change the tree, for example, to quit the menu and run the "project" script.
