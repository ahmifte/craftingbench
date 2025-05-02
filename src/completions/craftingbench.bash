#!/usr/bin/env bash

# Bash completion for CraftingBench CLI

_craftingbench_complete() {
  local cur prev words cword
  _init_completion || return

  # List of common commands
  local commands="setup_python_project setup_python_library setup_python_backend setup_go_project setup_go_library setup_go_backend setup_nodejs_backend setup_react_frontend setup_fullstack_project"

  # Complete command names
  if [ "$cword" -eq 1 ]; then
    COMPREPLY=($(compgen -W "$commands" -- "$cur"))
    return 0
  fi

  # Project type options based on command
  if [ "$cword" -eq 2 ]; then
    case "$prev" in
      setup_python_project)
        COMPREPLY=($(compgen -W "--type=library --type=backend" -- "$cur"))
        ;;
      setup_go_project)
        COMPREPLY=($(compgen -W "--type=library --type=backend" -- "$cur"))
        ;;
      setup_fullstack_project)
        COMPREPLY=($(compgen -W "--backend=nextjs --backend=flask --backend=golang" -- "$cur"))
        ;;
    esac
  fi

  return 0
}

# Register the completion function
complete -F _craftingbench_complete craftingbench
complete -F _craftingbench_complete cb 