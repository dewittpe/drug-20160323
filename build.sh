#!/bin/bash

R -e "knitr::knit('updating-formulas.Rnw')"

latexmk -gg -pdf updating-formulas.tex
latexmk -c -pdf updating-formulas.tex

/bin/rm updating-formulas.nav
/bin/rm updating-formulas.tex
/bin/rm updating-formulas.vrb
/bin/rm updating-formulas.snm 
