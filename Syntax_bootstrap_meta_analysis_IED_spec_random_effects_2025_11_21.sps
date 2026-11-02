* Encoding: UTF-8.
*-------------------------------------------------------------------
* 0. Zorg dat er geen oude WEIGHT actief is.
*-------------------------------------------------------------------.
WEIGHT OFF.
EXECUTE.

*-------------------------------------------------------------------
* 1. Binnen-studie varianties en verschil uitrekenen.
*-------------------------------------------------------------------.

* Binnen-studie varianties van het gemiddelde (specificiteit).
COMPUTE var_Persyst_spec = (Persyst_spec_SD ** 2) / Persyst_spec_number.
COMPUTE var_Encevis_spec = (Encevis_spec_SD ** 2) / Encevis_spec_number.

* Studie-level verschil in specificiteit (Persyst – Encevis).
COMPUTE diff_spec = Persyst_spec_mean - Encevis_spec_mean.

* Approx. variantie van het verschil (covariantie genegeerd).
COMPUTE var_diff_spec = var_Persyst_spec + var_Encevis_spec.
EXECUTE.

*-------------------------------------------------------------------
* 2. DerSimonian–Laird tau²-waarden (berekend op jouw specificiteitsdata).
*-------------------------------------------------------------------.

COMPUTE tau2_Persyst_spec = 0.
COMPUTE tau2_Encevis_spec = 0.
COMPUTE tau2_diff_spec    = 5.5301.
EXECUTE.

*-------------------------------------------------------------------
* 3. Random-effects totale varianties en gewichten.
*-------------------------------------------------------------------.

* Random-effects totale varianties.
COMPUTE varRE_Persyst_spec = var_Persyst_spec + tau2_Persyst_spec.
COMPUTE varRE_Encevis_spec = var_Encevis_spec + tau2_Encevis_spec.
COMPUTE varRE_diff_spec    = var_diff_spec    + tau2_diff_spec.

* Random-effects gewichten.
COMPUTE wRE_Persyst_spec = 1 / varRE_Persyst_spec.
COMPUTE wRE_Encevis_spec = 1 / varRE_Encevis_spec.
COMPUTE wRE_diff_spec    = 1 / varRE_diff_spec.
EXECUTE.

*-------------------------------------------------------------------
* 4. Gewichten schalen naar gehele getallen (vereist voor BOOTSTRAP).
*-------------------------------------------------------------------.

* Schaalfactor (100000 werkt hier prima).
COMPUTE wP_RE_int_spec = RND(wRE_Persyst_spec * 100000).
COMPUTE wE_RE_int_spec = RND(wRE_Encevis_spec * 100000).
COMPUTE wD_RE_int_spec = RND(wRE_diff_spec    * 100000).

* Geen nul-gewichten toelaten.
IF (wP_RE_int_spec < 1) wP_RE_int_spec = 1.
IF (wE_RE_int_spec < 1) wE_RE_int_spec = 1.
IF (wD_RE_int_spec < 1) wD_RE_int_spec = 1.
EXECUTE.

*-------------------------------------------------------------------
* 5. BOOTSTRAP: random-effects gepoolde specificiteit Persyst.
*-------------------------------------------------------------------.

WEIGHT BY wP_RE_int_spec.

BOOTSTRAP
  /SAMPLING METHOD=SIMPLE
  /CRITERIA NSAMPLES=5000 CILEVEL=95 CITYPE=PERCENTILE.

DESCRIPTIVES VARIABLES=Persyst_spec_mean
  /STATISTICS=MEAN.

WEIGHT OFF.

*-------------------------------------------------------------------
* 6. BOOTSTRAP: random-effects gepoolde specificiteit Encevis.
*-------------------------------------------------------------------.

WEIGHT BY wE_RE_int_spec.

BOOTSTRAP
  /SAMPLING METHOD=SIMPLE
  /CRITERIA NSAMPLES=5000 CILEVEL=95 CITYPE=PERCENTILE.

DESCRIPTIVES VARIABLES=Encevis_spec_mean
  /STATISTICS=MEAN.

WEIGHT OFF.

*-------------------------------------------------------------------
* 7. BOOTSTRAP: random-effects Δ-specificiteit (Persyst – Encevis).
*-------------------------------------------------------------------.

WEIGHT BY wD_RE_int_spec.

BOOTSTRAP
  /SAMPLING METHOD=SIMPLE
  /CRITERIA NSAMPLES=5000 CILEVEL=95 CITYPE=PERCENTILE.

DESCRIPTIVES VARIABLES=diff_spec
  /STATISTICS=MEAN.

WEIGHT OFF.

