* Encoding: UTF-8.
META CONTINUOUS
  /DATA
    TREATMENT=
      N(Persyst_spec_number)
      MEAN(Persyst_spec_logit)
      STD(Persyst_spec_SD_logit)
    CONTROL=
      N(Encevis_spec_number)
      MEAN(Encevis_spec_logit)
      STD(Encevis_spec_SD_logit)
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
