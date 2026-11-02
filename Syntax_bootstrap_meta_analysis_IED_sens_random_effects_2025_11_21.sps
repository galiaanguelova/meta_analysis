* Encoding: UTF-8.
*-------------------------------------------------------------------
* 0. Zorg dat er geen oude WEIGHT actief is.
*-------------------------------------------------------------------.
WEIGHT OFF.
EXECUTE.

*-------------------------------------------------------------------
* 1. Variantie van het gemiddelde en "echte" gewichten berekenen.
*-------------------------------------------------------------------.

* Binnen-studie varianties van het gemiddelde.
COMPUTE var_Persyst = (Persyst_sens_SD ** 2) / Persyst_sens_number.
COMPUTE var_Encevis = (Encevis_sens_SD ** 2) / Encevis_sens_number.

* Inverse-variantie gewichten (nog NIET integer).
COMPUTE w_Persyst = 1 / var_Persyst.
COMPUTE w_Encevis = 1 / var_Encevis.

* Studie-level verschil Persyst – Encevis.
COMPUTE diff_mean = Persyst_sens_mean - Encevis_sens_mean.

* Variante van het verschil (covariantie genegeerd).
COMPUTE var_diff = var_Persyst + var_Encevis.
COMPUTE w_diff  = 1 / var_diff.
EXECUTE.

*-------------------------------------------------------------------
* 2. Gewichten schalen naar gehele waarden (vereist voor BOOTSTRAP).
*-------------------------------------------------------------------.

* Schaalfactor kun je aanpassen; 1000 is meestal prima.
COMPUTE wP_int = RND(w_Persyst * 1000).
COMPUTE wE_int = RND(w_Encevis * 1000).
COMPUTE wD_int = RND(w_diff    * 1000).

* Zorg dat er geen nul-gewichten ontstaan.
IF (wP_int < 1) wP_int = 1.
IF (wE_int < 1) wE_int = 1.
IF (wD_int < 1) wD_int = 1.
EXECUTE.

*-------------------------------------------------------------------
* 3. BOOTSTRAP: gepoolde Persyst-sensitiviteit (fixed effect).
*-------------------------------------------------------------------.

WEIGHT BY wP_int.

BOOTSTRAP
  /SAMPLING METHOD=SIMPLE
  /CRITERIA NSAMPLES=5000 CILEVEL=95 CITYPE=PERCENTILE.

DESCRIPTIVES VARIABLES=Persyst_sens_mean
  /STATISTICS=MEAN.

WEIGHT OFF.

*-------------------------------------------------------------------
* 4. BOOTSTRAP: gepoolde Encevis-sensitiviteit (fixed effect).
*-------------------------------------------------------------------.

WEIGHT BY wE_int.

BOOTSTRAP
  /SAMPLING METHOD=SIMPLE
  /CRITERIA NSAMPLES=5000 CILEVEL=95 CITYPE=PERCENTILE.

DESCRIPTIVES VARIABLES=Encevis_sens_mean
  /STATISTICS=MEAN.

WEIGHT OFF.

*-------------------------------------------------------------------
* 5. BOOTSTRAP: Δ-sensitiviteit (Persyst – Encevis).
*-------------------------------------------------------------------.

WEIGHT BY wD_int.

BOOTSTRAP
  /SAMPLING METHOD=SIMPLE
  /CRITERIA NSAMPLES=5000 CILEVEL=95 CITYPE=PERCENTILE.

DESCRIPTIVES VARIABLES=diff_mean
  /STATISTICS=MEAN.

WEIGHT OFF.

