#!/bin/bash
if [ -e /var/log/leapp/answerfile ]
  then
    grep '^confirm = True' /var/log/leapp/answerfile
      exit 0
  else
    printf 'no answerfile found' >&2
    exit 1
  fi
