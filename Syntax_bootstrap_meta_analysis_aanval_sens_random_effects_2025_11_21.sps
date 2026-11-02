* Encoding: UTF-8.

*-------------------------------------------------------------------
* 0. Geen oude WEIGHT actief laten.
*-------------------------------------------------------------------.
WEIGHT OFF.
EXECUTE.

*-------------------------------------------------------------------
* 1. Binnen-studie varianties en verschil uitrekenen.
*-------------------------------------------------------------------.

* Binnen-studie varianties van het gemiddelde (sensitiviteit).
COMPUTE var_Persyst_sens = (Persyst_sens_SD ** 2) / Persyst_sens_number.
COMPUTE var_Encevis_sens = (Encevis_sens_SD ** 2) / Encevis_sens_number.

* Studie-level verschil in sensitiviteit (Persyst – Encevis).
COMPUTE diff_sens = Persyst_sens_mean - Encevis_sens_mean.

* Approx. variantie van het verschil (covariantie genegeerd).
COMPUTE var_diff_sens = var_Persyst_sens + var_Encevis_sens.
EXECUTE.

*-------------------------------------------------------------------
* 2. DerSimonian–Laird tau²-waarden (berekend op jouw data).
*-------------------------------------------------------------------.

COMPUTE tau2_Persyst_sens = 138.614.
COMPUTE tau2_Encevis_sens = 194.114.
COMPUTE tau2_diff_sens    = 0.000.
EXECUTE.

*-------------------------------------------------------------------
* 3. Random-effects totale varianties en gewichten.
*-------------------------------------------------------------------.

* Random-effects totale varianties.
COMPUTE varRE_Persyst_sens = var_Persyst_sens + tau2_Persyst_sens.
COMPUTE varRE_Encevis_sens = var_Encevis_sens + tau2_Encevis_sens.
COMPUTE varRE_diff_sens    = var_diff_sens    + tau2_diff_sens.

* Random-effects gewichten.
COMPUTE wRE_Persyst_sens = 1 / varRE_Persyst_sens.
COMPUTE wRE_Encevis_sens = 1 / varRE_Encevis_sens.
COMPUTE wRE_diff_sens    = 1 / varRE_diff_sens.
EXECUTE.

*-------------------------------------------------------------------
* 4. Gewichten schalen naar gehele getallen (vereist voor BOOTSTRAP).
*-------------------------------------------------------------------.

* Schaalfactor; mag groter/kleiner, maar moet ints opleveren.
COMPUTE wP_RE_int_sens = RND(wRE_Persyst_sens * 100000).
COMPUTE wE_RE_int_sens = RND(wRE_Encevis_sens * 100000).
COMPUTE wD_RE_int_sens = RND(wRE_diff_sens    * 100000).

* Geen nul-gewichten toelaten.
IF (wP_RE_int_sens < 1) wP_RE_int_sens = 1.
IF (wE_RE_int_sens < 1) wE_RE_int_sens = 1.
IF (wD_RE_int_sens < 1) wD_RE_int_sens = 1.
EXECUTE.

*-------------------------------------------------------------------
* 5. BOOTSTRAP: random-effects gepoolde sensitiviteit Persyst.
*-------------------------------------------------------------------.

WEIGHT BY wP_RE_int_sens.

BOOTSTRAP
  /SAMPLING METHOD=SIMPLE
  /CRITERIA NSAMPLES=5000 CILEVEL=95 CITYPE=PERCENTILE.

DESCRIPTIVES VARIABLES=Persyst_sens_mean
  /STATISTICS=MEAN.

WEIGHT OFF.

*-------------------------------------------------------------------
* 6. BOOTSTRAP: random-effects gepoolde sensitiviteit Encevis.
*-------------------------------------------------------------------.

WEIGHT BY wE_RE_int_sens.

BOOTSTRAP
  /SAMPLING METHOD=SIMPLE
  /CRITERIA NSAMPLES=5000 CILEVEL=95 CITYPE=PERCENTILE.

DESCRIPTIVES VARIABLES=Encevis_sens_mean
  /STATISTICS=MEAN.

WEIGHT OFF.

*-------------------------------------------------------------------
* 7. BOOTSTRAP: random-effects Δ-sensitiviteit (Persyst – Encevis).
*-------------------------------------------------------------------.

WEIGHT BY wD_RE_int_sens.

BOOTSTRAP
  /SAMPLING METHOD=SIMPLE
  /CRITERIA NSAMPLES=5000 CILEVEL=95 CITYPE=PERCENTILE.

DESCRIPTIVES VARIABLES=diff_sens
  /STATISTICS=MEAN.

WEIGHT OFF.

