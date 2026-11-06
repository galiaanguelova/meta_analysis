* Encoding: UTF-8.

*-------------------------------------------------------------------.
* 0. Zorg dat er geen oude WEIGHT actief is.
*-------------------------------------------------------------------.

WEIGHT OFF.
EXECUTE.

*-------------------------------------------------------------------.
* 1. Logittransformatie en binnen-studievarianties.
*-------------------------------------------------------------------.

* Zet percentages om naar proporties.
COMPUTE Persyst_sens_prop = Persyst_sens_mean / 100.
COMPUTE Encevis_sens_prop = Encevis_sens_mean / 100.

* Zet de SD's om van procentpunten naar proporties.
COMPUTE Persyst_sens_SD_prop = Persyst_sens_SD / 100.
COMPUTE Encevis_sens_SD_prop = Encevis_sens_SD / 100.

* Continuïteitscorrectie bij exact 0 of 1.
* Nodig omdat logit(0) en logit(1) niet bestaan.

IF (Persyst_sens_prop >= 1)
    Persyst_sens_prop =
    (Persyst_sens_number + 0.5) /
    (Persyst_sens_number + 1).

IF (Persyst_sens_prop <= 0)
    Persyst_sens_prop =
    0.5 / (Persyst_sens_number + 1).

IF (Encevis_sens_prop >= 1)
    Encevis_sens_prop =
    (Encevis_sens_number + 0.5) /
    (Encevis_sens_number + 1).

IF (Encevis_sens_prop <= 0)
    Encevis_sens_prop =
    0.5 / (Encevis_sens_number + 1).

* Logittransformatie van de gemiddelde sensitiviteit.
COMPUTE Persyst_sens_logit =
    LN(Persyst_sens_prop / (1 - Persyst_sens_prop)).

COMPUTE Encevis_sens_logit =
    LN(Encevis_sens_prop / (1 - Encevis_sens_prop)).

* Delta-methode voor SD op de logitschaal.
COMPUTE Persyst_sens_SD_logit =
    Persyst_sens_SD_prop /
    (Persyst_sens_prop * (1 - Persyst_sens_prop)).

COMPUTE Encevis_sens_SD_logit =
    Encevis_sens_SD_prop /
    (Encevis_sens_prop * (1 - Encevis_sens_prop)).

* Binnen-studievarianties van het gemiddelde op de logitschaal.
COMPUTE var_Persyst_sens =
    (Persyst_sens_SD_logit ** 2) /
    Persyst_sens_number.

COMPUTE var_Encevis_sens =
    (Encevis_sens_SD_logit ** 2) /
    Encevis_sens_number.

* Studie-level verschil Persyst minus Encevis.
COMPUTE diff_sens_logit =
    Persyst_sens_logit - Encevis_sens_logit.

* Approx. variantie van het logitverschil.
* De binnen-studiecovariantie wordt hierbij op nul gesteld.
COMPUTE var_diff_sens =
    var_Persyst_sens + var_Encevis_sens.

EXECUTE.

*-------------------------------------------------------------------.
* 2. DerSimonian-Laird tau²-waarden op de logitschaal.
*
* Gebaseerd op:
* Persyst: 95%, 77%, 67%.
* Encevis: 86%, 93%, 46%.
*-------------------------------------------------------------------.

COMPUTE tau2_Persyst_sens = 0.206965.
COMPUTE tau2_Encevis_sens = 2.367201.
COMPUTE tau2_diff_sens    = 1.164750.

EXECUTE.

*-------------------------------------------------------------------.
* 3. Random-effects totale varianties en gewichten.
*-------------------------------------------------------------------.

COMPUTE varRE_Persyst_sens =
    var_Persyst_sens + tau2_Persyst_sens.

COMPUTE varRE_Encevis_sens =
    var_Encevis_sens + tau2_Encevis_sens.

COMPUTE varRE_diff_sens =
    var_diff_sens + tau2_diff_sens.

COMPUTE wRE_Persyst_sens =
    1 / varRE_Persyst_sens.

COMPUTE wRE_Encevis_sens =
    1 / varRE_Encevis_sens.

COMPUTE wRE_diff_sens =
    1 / varRE_diff_sens.

EXECUTE.

*-------------------------------------------------------------------.
* 4. Gewichten schalen naar gehele getallen.
* SPSS vereist integergewichten bij deze bootstrapmethode.
*-------------------------------------------------------------------.

COMPUTE wP_RE_int_sens =
    RND(wRE_Persyst_sens * 100000).

COMPUTE wE_RE_int_sens =
    RND(wRE_Encevis_sens * 100000).

COMPUTE wD_RE_int_sens =
    RND(wRE_diff_sens * 100000).

* Veiligheidsnet: geen nulgewichten.
IF (wP_RE_int_sens < 1) wP_RE_int_sens = 1.
IF (wE_RE_int_sens < 1) wE_RE_int_sens = 1.
IF (wD_RE_int_sens < 1) wD_RE_int_sens = 1.

EXECUTE.

*-------------------------------------------------------------------.
* 5. BOOTSTRAP: random-effects gepoolde sensitiviteit Persyst.
*-------------------------------------------------------------------.

WEIGHT BY wP_RE_int_sens.

BOOTSTRAP
  /SAMPLING METHOD=SIMPLE
  /CRITERIA NSAMPLES=5000 CILEVEL=95 CITYPE=PERCENTILE.

DESCRIPTIVES VARIABLES=Persyst_sens_logit
  /STATISTICS=MEAN.

WEIGHT OFF.

*-------------------------------------------------------------------.
* 6. BOOTSTRAP: random-effects gepoolde sensitiviteit Encevis.
*-------------------------------------------------------------------.

WEIGHT BY wE_RE_int_sens.

BOOTSTRAP
  /SAMPLING METHOD=SIMPLE
  /CRITERIA NSAMPLES=5000 CILEVEL=95 CITYPE=PERCENTILE.

DESCRIPTIVES VARIABLES=Encevis_sens_logit
  /STATISTICS=MEAN.

WEIGHT OFF.

*-------------------------------------------------------------------.
* 7. BOOTSTRAP: random-effects verschil Persyst minus Encevis.
*-------------------------------------------------------------------.

WEIGHT BY wD_RE_int_sens.

BOOTSTRAP
  /SAMPLING METHOD=SIMPLE
  /CRITERIA NSAMPLES=5000 CILEVEL=95 CITYPE=PERCENTILE.

DESCRIPTIVES VARIABLES=diff_sens_logit
  /STATISTICS=MEAN.

WEIGHT OFF.
EXECUTE.
