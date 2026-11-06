* Encoding: UTF-8.

*-------------------------------------------------------------------
* 0. Zorg dat er geen oude WEIGHT actief is.
*-------------------------------------------------------------------.
WEIGHT OFF.
EXECUTE.

*-------------------------------------------------------------------
* 1. Logittransformatie en binnen-studievarianties.
*-------------------------------------------------------------------.

* Zet percentages om naar proporties.
COMPUTE Persyst_spec_prop = Persyst_spec_mean / 100.
COMPUTE Encevis_spec_prop = Encevis_spec_mean / 100.

* Zet de SD's eveneens om van procentpunten naar proporties.
COMPUTE Persyst_spec_SD_prop = Persyst_spec_SD / 100.
COMPUTE Encevis_spec_SD_prop = Encevis_spec_SD / 100.

* Continuïteitscorrectie bij exact 0 of 1.
* Nodig omdat logit(0) en logit(1) niet bestaan.
IF (Persyst_spec_prop >= 1)
    Persyst_spec_prop =
    (Persyst_spec_number + 0.5) /
    (Persyst_spec_number + 1).

IF (Persyst_spec_prop <= 0)
    Persyst_spec_prop =
    0.5 / (Persyst_spec_number + 1).

IF (Encevis_spec_prop >= 1)
    Encevis_spec_prop =
    (Encevis_spec_number + 0.5) /
    (Encevis_spec_number + 1).

IF (Encevis_spec_prop <= 0)
    Encevis_spec_prop =
    0.5 / (Encevis_spec_number + 1).

* Logittransformatie van de gemiddelde specificiteit.
COMPUTE Persyst_spec_logit =
    LN(Persyst_spec_prop / (1 - Persyst_spec_prop)).

COMPUTE Encevis_spec_logit =
    LN(Encevis_spec_prop / (1 - Encevis_spec_prop)).

* Delta-methode voor SD op de logitschaal.
COMPUTE Persyst_spec_SD_logit =
    Persyst_spec_SD_prop /
    (Persyst_spec_prop * (1 - Persyst_spec_prop)).

COMPUTE Encevis_spec_SD_logit =
    Encevis_spec_SD_prop /
    (Encevis_spec_prop * (1 - Encevis_spec_prop)).

* Binnen-studievarianties op de logitschaal.
COMPUTE var_Persyst_spec =
    (Persyst_spec_SD_logit ** 2) /
    Persyst_spec_number.

COMPUTE var_Encevis_spec =
    (Encevis_spec_SD_logit ** 2) /
    Encevis_spec_number.

* Studie-level verschil op de logitschaal.
COMPUTE diff_spec_logit =
    Persyst_spec_logit - Encevis_spec_logit.

* Approx. variantie van het logitverschil.
* De binnen-studiecovariantie wordt hierbij op nul gesteld.
COMPUTE var_diff_spec =
    var_Persyst_spec + var_Encevis_spec.

EXECUTE.

*-------------------------------------------------------------------
* 2. DerSimonian-Laird tau²-waarden op de logitschaal.
*
* Gebaseerd op:
* Persyst: 100%, 97%, 93%.
* Encevis: 88%, 93%, 97%.
* Voor 100% is bovenstaande continuïteitscorrectie gebruikt.
*-------------------------------------------------------------------.

COMPUTE tau2_Persyst_spec = 0.
COMPUTE tau2_Encevis_spec = 0.1010.
COMPUTE tau2_diff_spec    = 0.
EXECUTE.

*-------------------------------------------------------------------
* 3. Random-effects totale varianties en gewichten.
*-------------------------------------------------------------------.

COMPUTE varRE_Persyst_spec =
    var_Persyst_spec + tau2_Persyst_spec.

COMPUTE varRE_Encevis_spec =
    var_Encevis_spec + tau2_Encevis_spec.

COMPUTE varRE_diff_spec =
    var_diff_spec + tau2_diff_spec.

COMPUTE wRE_Persyst_spec =
    1 / varRE_Persyst_spec.

COMPUTE wRE_Encevis_spec =
    1 / varRE_Encevis_spec.

COMPUTE wRE_diff_spec =
    1 / varRE_diff_spec.

EXECUTE.

*-------------------------------------------------------------------
* 4. Gewichten schalen naar gehele getallen.
*-------------------------------------------------------------------.

COMPUTE wP_RE_int_spec =
    RND(wRE_Persyst_spec * 100000).

COMPUTE wE_RE_int_spec =
    RND(wRE_Encevis_spec * 100000).

COMPUTE wD_RE_int_spec =
    RND(wRE_diff_spec * 100000).

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

DESCRIPTIVES VARIABLES=Persyst_spec_logit
  /STATISTICS=MEAN.

WEIGHT OFF.

*-------------------------------------------------------------------
* 6. BOOTSTRAP: random-effects gepoolde specificiteit Encevis.
*-------------------------------------------------------------------.

WEIGHT BY wE_RE_int_spec.

BOOTSTRAP
  /SAMPLING METHOD=SIMPLE
  /CRITERIA NSAMPLES=5000 CILEVEL=95 CITYPE=PERCENTILE.

DESCRIPTIVES VARIABLES=Encevis_spec_logit
  /STATISTICS=MEAN.

WEIGHT OFF.

*-------------------------------------------------------------------
* 7. BOOTSTRAP: random-effects verschil Persyst – Encevis.
*-------------------------------------------------------------------.

WEIGHT BY wD_RE_int_spec.

BOOTSTRAP
  /SAMPLING METHOD=SIMPLE
  /CRITERIA NSAMPLES=5000 CILEVEL=95 CITYPE=PERCENTILE.

DESCRIPTIVES VARIABLES=diff_spec_logit
  /STATISTICS=MEAN.

WEIGHT OFF.

* een positief logitverschil betekent OR > 1 en hogere specificity odds voor Persyst;
*een negatief logitverschil betekent OR < 1 en hogere specificity odds voor Encevis;
*een 95%-BI voor het logitverschil dat 0 bevat, komt overeen met een OR-BI dat 1 bevat.
 
