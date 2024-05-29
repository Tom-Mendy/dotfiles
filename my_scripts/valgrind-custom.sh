#!/bin/bash

commande_line=$*

if [ -f Makefile ]; then
  make
  echo "-------------------"
fi

valgrind --leak-check=full --track-origins=yes --show-leak-kinds=all --errors-for-leak-kinds=all "$commande_line"
