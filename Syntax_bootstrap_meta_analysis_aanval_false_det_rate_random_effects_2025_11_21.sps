* Encoding: UTF-8.
*-------------------------------------------------------------------
* 0. Geen oude WEIGHT actief laten.
*-------------------------------------------------------------------.
WEIGHT OFF.
EXECUTE.

*-------------------------------------------------------------------
* 1. Binnen-studie varianties en verschil uitrekenen.
*-------------------------------------------------------------------.

* Binnen-studie varianties van het gemiddelde (FDR).
COMPUTE var_Persyst_FDR = (Persyst_false_det_rate_SD ** 2) / Persyst_false_det_rate_number.
COMPUTE var_Encevis_FDR = (Encevis_false_det_rate_SD ** 2) / Encevis_false_det_rate_number.

* Studie-level verschil in FDR (Persyst – Encevis).
COMPUTE diff_FDR = Persyst_false_det_rate_mean - Encevis_false_det_rate_mean.

* Approx. variantie van het verschil (covariantie genegeerd).
COMPUTE var_diff_FDR = var_Persyst_FDR + var_Encevis_FDR.
EXECUTE.

*-------------------------------------------------------------------
* 2. DerSimonian–Laird tau²-waarden (berekend op jouw FDR-data).
*-------------------------------------------------------------------.

COMPUTE tau2_Persyst_FDR = 0.2931.
COMPUTE tau2_Encevis_FDR = 0.2066.
COMPUTE tau2_diff_FDR    = 1.0145.
EXECUTE.

*-------------------------------------------------------------------
* 3. Random-effects totale varianties en gewichten.
*-------------------------------------------------------------------.

* Random-effects totale varianties.
COMPUTE varRE_Persyst_FDR = var_Persyst_FDR + tau2_Persyst_FDR.
COMPUTE varRE_Encevis_FDR = var_Encevis_FDR + tau2_Encevis_FDR.
COMPUTE varRE_diff_FDR    = var_diff_FDR    + tau2_diff_FDR.

* Random-effects gewichten.
COMPUTE wRE_Persyst_FDR = 1 / varRE_Persyst_FDR.
COMPUTE wRE_Encevis_FDR = 1 / varRE_Encevis_FDR.
COMPUTE wRE_diff_FDR    = 1 / varRE_diff_FDR.
EXECUTE.

*-------------------------------------------------------------------
* 4. Gewichten schalen naar gehele getallen (vereist voor BOOTSTRAP).
*-------------------------------------------------------------------.

* Schaalfactor; mag groter/kleiner, zolang je integers krijgt.
COMPUTE wP_RE_int_FDR = RND(wRE_Persyst_FDR * 100000).
COMPUTE wE_RE_int_FDR = RND(wRE_Encevis_FDR * 100000).
COMPUTE wD_RE_int_FDR = RND(wRE_diff_FDR    * 100000).

* Geen nul-gewichten toelaten.
IF (wP_RE_int_FDR < 1) wP_RE_int_FDR = 1.
IF (wE_RE_int_FDR < 1) wE_RE_int_FDR = 1.
IF (wD_RE_int_FDR < 1) wD_RE_int_FDR = 1.
EXECUTE.

*-------------------------------------------------------------------
* 5. BOOTSTRAP: random-effects gepoolde FDR van Persyst.
*-------------------------------------------------------------------.

WEIGHT BY wP_RE_int_FDR.

BOOTSTRAP
  /SAMPLING METHOD=SIMPLE
  /CRITERIA NSAMPLES=5000 CILEVEL=95 CITYPE=PERCENTILE.

DESCRIPTIVES VARIABLES=Persyst_false_det_rate_mean
  /STATISTICS=MEAN.

WEIGHT OFF.

*-------------------------------------------------------------------
* 6. BOOTSTRAP: random-effects gepoolde FDR van Encevis.
*-------------------------------------------------------------------.

WEIGHT BY wE_RE_int_FDR.

BOOTSTRAP
  /SAMPLING METHOD=SIMPLE
  /CRITERIA NSAMPLES=5000 CILEVEL=95 CITYPE=PERCENTILE.

DESCRIPTIVES VARIABLES=Encevis_false_det_rate_mean
  /STATISTICS=MEAN.

WEIGHT OFF.

*-------------------------------------------------------------------
* 7. BOOTSTRAP: random-effects ΔFDR (Persyst – Encevis).
*-------------------------------------------------------------------.

WEIGHT BY wD_RE_int_FDR.

BOOTSTRAP
  /SAMPLING METHOD=SIMPLE
  /CRITERIA NSAMPLES=5000 CILEVEL=95 CITYPE=PERCENTILE.

DESCRIPTIVES VARIABLES=diff_FDR
  /STATISTICS=MEAN.

WEIGHT OFF.

