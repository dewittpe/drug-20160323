## @knitr chunk01
# Example
data("diamonds", package = "ggplot2")
fit <- lm(price ~ cut + color + carat, data = diamonds)
fit

## @knitr chunk02
# the dot means "keep all of this side"
# add clarity to the rhs
update(fit, formula = . ~ . + clarity)

## @knitr chunk03
# the dot means "keep all of this side"
# remove cut from the rhs
update(fit, formula = . ~ . - cut)

## @knitr chunk04
# remove the ordering form diamonds$cut
update(fit, 
       data = dplyr::mutate(diamonds, cut = factor(cut, ordered = FALSE)))

## @knitr chunk05
update(fit, 
       formula = . ~ . + clarity,
       data = dplyr::mutate(diamonds, cut = factor(cut, ordered = FALSE)))

## @knitr chunk06
# Carat is on the rhs as a continuous and categorical variable
update(fit, 
       formula = . ~ . + cut(carat, breaks = c(0, 0.5, 1.0, 2.0, 5.0))) %>%
magrittr::extract("call")

# cut and color are missing from the rhs
update(fit, 
       formula = . ~ cut(carat, breaks = c(0, 0.5, 1.0, 2.0, 5.0))) %>%
magrittr::extract("call")

## @knitr chunk07
# correct specification
fit <- update(fit, 
              formula = . ~ . - carat + 
                            cut(carat, breaks = c(0, 0.5, 1.0, 2.0, 5.0)))
fit %>% magrittr::extract("call")

## @knitr chunk08
# this does not work.  breaks needs to be passed to cut
update(fit, breaks = c(0, 2, 5))

# we would need to remove the old call to cut and replace it.  
# Worth it?
update(fit, 
       formula = . ~ . - cut(carat, breaks = c(0, 0.5, 1.0, 2.0, 5.0)) +
                         cut(carat, breaks = c(0, 2.0, 5.0))) %>%
magrittr::extract("call")


## @knitr chunk09

# Define a function new_breaks to update the breaks argument in cut 
# within a formula.
new_breaks <- function(form, brks) { 
  rr <- function(x, brks) {
      if(is.call(x) && grepl("cut", deparse(x[[1]]))) {
          x$breaks <- brks 
          x
      } else if (is.recursive(x)) {
          as.call(lapply(as.list(x), rr, brks))
      } else {
          x
      }
  }

  z <- lapply(as.list(form), rr, brks)   
  z <- eval(as.call(z))
  environment(z) <- environment(form)
  z
}

## @knitr chunk10
# original call
fit$call

# update the call
fit <- update(fit, 
              formula = new_breaks(formula(fit), brks = c(0, 2.0, 5.0)))

# view updated call
fit$call

## @knitr chunk11
matrix(fit$coefficients, ncol = 1,
       dimnames = list(names(coef(fit)), "coef"))
