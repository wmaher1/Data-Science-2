# Data-Science-2

# SVM Decision Boundary Shiny App

## Overview

This project is an interactive Shiny application that demonstrates how Support Vector Machine (SVM) classification models create decision boundaries under different kernel functions and hyperparameter settings.

The app uses the Palmer Penguins dataset to classify penguin species based on bill measurements and allows users to explore how model behavior changes as inputs are adjusted.

---

## Research Question

How do bill length and bill depth distinguish between Adelie, Chinstrap, and Gentoo penguins using Support Vector Machine classification?

Which SVM kernel provides the best separation of the three penguin species?

---

## Features

### Interactive Inputs
- Select penguin species to include
- Choose SVM kernel:
  - Linear
  - Radial
  - Polynomial
  - Sigmoid
- Adjust cost parameter
- Adjust gamma for radial kernels
- Adjust degree for polynomial kernels

### Outputs
- Interactive decision boundary visualization
- Highlighted support vectors
- Training accuracy
- Confusion matrix
- Summary statistics by species
- Support vector breakdown table

---

## Data Source

The project uses the `palmerpenguins` dataset.

Source:
- Dr. Kristen Gorman and the Palmer Station Antarctica Long Term Ecological Research (LTER) program
- https://allisonhorst.github.io/palmerpenguins/

The dataset contains measurements from penguins observed in the Palmer Archipelago, Antarctica between 2007–2009.

---

## Packages Used

```r
shiny
palmerpenguins
dplyr
ggplot2
e1071
DT
