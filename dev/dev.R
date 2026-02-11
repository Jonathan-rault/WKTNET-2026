# https://github.com/ices-tools-prod/icesTAF
# https://github.com/ices-tools-prod/TAF

# devtools::install_github("ices-tools-prod/TAF", force = TRUE, build_manual = TRUE)
# devtools::install_github("ices-tools-prod/icesTAF", force = TRUE, build_manual = TRUE)

library(icesTAF)

icesTAF::taf.skeleton()

# sessionInfo()


#############################################
## creating DATA.bib boot file ##############
#############################################

TAF::draft.data(
  originator = "ifremer",
  data.files = "REFERENCES/referentiel_stocks_ices.xlsx",
  title = "ices stock definitions",
  file = TRUE,
  append = FALSE
)

TAF::draft.data(
  originator = "ICES",
  data.files = "WKNatEst recommendation - alternative format to Annex 1 to increase compatibility with national estimation in RDBES_TAF_____.xlsx",
  title = "estimations requirement for each stocks",
  file = TRUE,
  append = TRUE
)

TAF::draft.data(
  originator = "ifremer",
  data.files = "TEMPLATES",
  title = "template for rendering rmarkdown pdf",
  file = TRUE,
  append = TRUE
)

### not working properly : why ?

TAF::draft.data(
  originator = "ifremer",
  data.files = "data_aquisition.R",
  title = "initial script for preparing boot data",
  file = TRUE,
  append = TRUE
)


#############################################
## creating SOFTWARE.bib boot file ##########
#############################################

TAF::draft.software(
  package = "RDBEScore",
  author = "ICES",
  year = NULL,
  title = NULL,
  version = NULL,
  source = "ices-tools-dev/RDBEScore@9077812",
  file = TRUE,
  append = FALSE
)

TAF::draft.software(
  package = "TEST.PACKAGE",
  # author = NULL,
  # year = NULL,
  # title = NULL,
  # version = NULL,
  source = "https://github.com/Jonathan-rault/r-package-test-taf@6bf12c1",
  append = TRUE
)