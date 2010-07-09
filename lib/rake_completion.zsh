function _last_modified_at(){
    if [ `uname -s` = "Linux" ]; then
        stat -c%y $1
    else
        stat -f%m $1
    fi
}

_rake_does_task_list_need_generating () {
  if [ ! -f .rake_tasks~ ]; then return 0;
  else
    accurate=$(_last_modified_at .rake_tasks~)
    changed=$(_last_modified_at Rakefile)
    return $(expr $accurate '>=' $changed)
  fi
}

_rake () {
  if [ -f Rakefile ]; then
    if _rake_does_task_list_need_generating; then
      echo "\nGenerating .rake_tasks~..." > /dev/stderr
      rake --silent --tasks | cut -d " " -f 2 > .rake_tasks~
    fi
    compadd `cat .rake_tasks~`
  fi
}

compctl -K _rake rake

function _cap_does_task_list_need_generating () {
  if [ ! -f .cap_tasks~ ]; then return 0;
  else
    accurate=$(_last_modified_at .cap_tasks~)
    changed=$(_last_modified_at config/deploy.rb)
    return $(expr $accurate '>=' $changed)
  fi
}

function _cap () {
  if [ -f config/deploy.rb ]; then
    if _cap_does_task_list_need_generating; then
      echo "\nGenerating .cap_tasks~..." > /dev/stderr
      cap show_tasks -q | cut -d " " -f 1 | sed -e '/^ *$/D' -e '1,2D'
> .cap_tasks~
    fi
    compadd `cat .cap_tasks~`
  fi
}

compctl -K _cap cap
