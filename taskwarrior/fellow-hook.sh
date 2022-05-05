#!/bin/bash
# ---------------------------------- #
# Taskwarrior hook on task completed #
# ---------------------------------- #

description="$(sed -nE 's/.*"description":"([^"]+)".*"status":"completed".*/\1/p')"
if [[ -n "${description}" ]]; then
  fellow taskdone "Completed: ${description}"
fi
