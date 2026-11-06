* Encoding: UTF-8.

WEIGHT OFF.
EXECUTE.

META CONTINUOUS
  /DATA
    TREATMENT=
      N(Persyst_sens_number)
      MEAN(Persyst_sens_logit)
      STD(Persyst_sens_SD_logit)
    CONTROL=
      N(Encevis_sens_number)
      MEAN(Encevis_sens_logit)
      STD(Encevis_sens_SD_logit)
    ID=Study
    ESTYPE=MEAN_DIFF
  /CRITERIA
    CILEVEL=95
    SCOPE=AVAILABLE
    CLASSMISSING=EXCLUDE
    MAXITER=100
    MAXSTEP=5
    CONVERGENCE=0.000001
  /INFERENCE
    MODEL=RANDOM
    ESTIMATE=REML
    ADJUSTSE=NONE
  /FORESTPLOT
    DISPLAY=ES CI WEIGHT
    POSITION=RIGHT
    ANNOTATIONS=HETEROGENEITY TEST.
