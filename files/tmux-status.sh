#!/bin/bash

CURRENT_PATH=$1
SHOW_FOLDER=$2

DEFAULT_COLOR='colour34'
TEXT_COLOR='colour240'

BRANCH_COLOR_NOTHING='colour240'
BRANCH_COLOR_UNTRACKED='colour166'
BRANCH_COLOR_COMMITED='colour28'
BRANCH_COLOR_CHANGES='colour196'
BRANCH_COLOR_CONFLICTS='colour196'
BRANCH_ICON=""
BRANCH_ICON_CONFLICTS="✖"

FOLDER_ICON=""
FOLDER_ICON_COLOR='colour243'
FILE_ICON=""
FILE_ICON_COLOR='colour243'
SYMLINK_ICON=""
SYMLINK_ICON_COLOR='colour243'

SPLITTER_ICON=""
SPLITTER_ICON_COLOR='colour243'

get_git() {
  local is_git
  is_git="$(cd $CURRENT_PATH; git rev-parse --is-inside-work-tree 2> /dev/null)"
  echo "$is_git"
}

get_git_status() {
  local git_status
  git_status="$(cd $CURRENT_PATH; git status 2> /dev/null)"
  echo "$git_status"
}

get_branch_icon() {
  local git_status
  git_status=$(cd $CURRENT_PATH; git status 2> /dev/null)

  case "${git_status}" in
    *"nothing to commit"*)
      echo "#[fg=$BRANCH_COLOR_NOTHING]$BRANCH_ICON" #colour240
      ;;
    *"Changes not staged"*)
      echo "#[fg=$BRANCH_COLOR_CHANGES]$BRANCH_ICON" #colour196
      ;;
    *"nothing added to commit but untracked"*)
      echo "#[fg=$BRANCH_COLOR_UNTRACKED]$BRANCH_ICON" #colour166
      ;;
    *"conflicts"*)
      echo "#[fg=$BRANCH_COLOR_CONFLICTS]$BRANCH_ICON_CONFLICTS" #✖colour196
      ;;
    *"Changes to be committed"*)
      echo "#[fg=$BRANCH_COLOR_COMMITED]$BRANCH_ICON" #colour28
      ;;
  esac
}

get_branch_name() {
  local branch_name
  branch_name="$(cd $CURRENT_PATH; git rev-parse --abbrev-ref HEAD)"
  echo $branch_name
}

get_folder_status() {
  local folder_count="$(cd $CURRENT_PATH; find . -mindepth 1 -maxdepth 1 -type d | wc -l)"
  local file_count="$(cd $CURRENT_PATH; find . -mindepth 1 -maxdepth 1 -type f | wc -l)"
  local symlink_count="$(cd $CURRENT_PATH; find . -mindepth 1 -maxdepth 1 -type l | wc -l)"
  folder="#[fg=$FOLDER_ICON_COLOR]$FOLDER_ICON #[fg=$TEXT_COLOR]${folder_count}"
  file="#[fg=$FILE_ICON_COLOR]$FILE_ICON #[fg=$TEXT_COLOR]${file_count}"
  symlink="#[fg=$SYMLINK_ICON_COLOR]$SYMLINK_ICON #[fg=$TEXT_COLOR]${symlink_count}"
  splitter="#[fg=$SPLITTER_ICON_COLOR]$SPLITTER_ICON#[fg=$TEXT_COLOR]"
  folder_status="$folder $file $symlink $splitter"
  echo $folder_status
}

set_status_bar() {
  local git_status
  local branch_name
  local branch_icon
  local branch_status

  git_status=$(get_git_status)
  branch_name="$(get_branch_name)"
  branch_icon="$(get_branch_icon)"
  splitter="#[fg=$SPLITTER_ICON_COLOR]$SPLITTER_ICON#[fg=$TEXT_COLOR]"
  branch_status="$branch_icon#[fg=$DEFAULT_COLOR] ${branch_name} $splitter"
  echo $branch_status
}

folder_status=""
if $SHOW_FOLDER == "true"; then
  folder_status=$(get_folder_status)
fi

IS_GIT=$(get_git)
status=""
if $IS_GIT == true; then
  status=$(set_status_bar)
  echo $folder_status $status
else
  echo $folder_status
fi
