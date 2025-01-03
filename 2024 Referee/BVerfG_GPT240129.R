##### BVerfG
##### Referee: Prepare for / from GPT
##### 240129

##### HOUSEKEEPING ----
##### clean
rm(list = ls())

##### load libraries
# install.packages("languageserver")
# install.packages(c('stringr', 'dplyr', 'ggplot2', 'tidyr', 'tokenizers', 'gtools'))
library(tokenizers)
library(gtools)

library(stringr)
library(dplyr)
library(tidyr)
library(ggplot2)
theme_update(plot.title = element_text(hjust = 0.5))

##### set working directory
# setwd("/Users/engel/Documents/word/Manuskript/Governance/BVerfG/Data/2024 Referee/")
setwd("/Users/amao/git/Constitutional_NLP_Summer_2022/2024 Referee")

# write_path <- "/Users/amao/git/Constitutional_NLP_Summer_2022/venv/chamber_1_1_domain/cases/"
# write_path <- "/Users/amao/git/Constitutional_NLP_Summer_2022/venv/senate_1/cases/"
write_path <- "/Users/amao/git/Constitutional_NLP_Summer_2022/venv/senate_2/cases/"

##### load prepared data
load("bverfg240129.RData")

##### PREPARE FOR GPT ----
##### token length ----
# Create a new column to store the number of tokens for each observation
bverfg$tokens <- NA

# Loop through each row of the dataset
for (i in 1:nrow(bverfg)) {
  # Combine the two text parts
  combined_text <- paste(bverfg$short_description[i], bverfg$full_text[i])
  
  # Tokenize the combined text
  tokens <- unlist(tokenize_words(combined_text))
  
  # Count the number of tokens and store in the new column
  bverfg$tokens[i] <- length(tokens)
}

bverfg %>% 
  select(body, tokens) %>%
  filter(body != "plenary" & body != "complaint") %>% 
  ggplot(aes(x = tokens, color = body)) +
  geom_density() +
  geom_vline(xintercept = 7000)

summary(bverfg$tokens)
summary(bverfg$tokens[bverfg$body == "chamber"])
length(bverfg$tokens[bverfg$body == "chamber" &
                      bverfg$tokens > 4000])
length(bverfg$tokens[bverfg$body == "chamber" &
                      bverfg$tokens > 7000])
length(bverfg$tokens[bverfg$body == "chamber" &
                        bverfg$sumref > 1 &
                        bverfg$sumdm > 1 &
                        bverfg$tokens > 7000])

##### senate 1 chamber ----
  #### select relevant cases ----
# bverfg %>%
#   filter(senate == 1,
#          body == "chamber",
#          sumref > 1,
#          sumdm > 1) %>%
#   select(id) -> mult
# mult$nrow <- 1:nrow(mult)

bverfg %>%
  filter(senate == 1,
         body == "chamber",
         sumdm == 1) %>%
  select(id) -> mult
mult$nrow <- 1:nrow(mult)

# bverfg %>% 
#   filter(senate == 2,
#          body == "chamber",
#          sumref2 > 1,
#          sumdm2 > 1) %>% 
#   select(id) -> mult
# mult$nrow <- 1:nrow(mult)
# bverfg %>%
#   filter(senate == 1,
#          body == "senate",
#          sumdm > 1) %>%
#   select(id) -> mult
# mult$nrow <- 1:nrow(mult)
# bverfg %>%
#   filter(senate == 2,
#          body == "senate",
#          sumdm2 > 1) %>%
#   select(id) -> mult
# mult$nrow <- 1:nrow(mult)

  #### compile prompt ----
    ### generic components ----

intro1 <- "Für die folgende Entscheidung kommen diese Gegenstände in Betracht: \n"

intro2 <- "Können Sie anhand des folgenden Texts entscheiden, welcher dieser Gegenstände der richtige ist? \n"

intro3 <- "Auf seiner Website hat das Gericht den Fall so beschrieben: \n"

intro4 <- "Es folgt der Text der Entscheidung (wenn die Entscheidung sehr lang ist, wird nur der Beginn der Entscheidung mitgeteilt): \n"
    
    ### load help file with German domain names ----
# load("domain240129.RData")
load("domain231231.RData")

    ### loop over individual cases ----
for (i in 1:nrow(mult)) {
    ### relevant domains
  positive_dm_vars <- bverfg %>% 
    filter(id == mult$id[i]) %>%
    select(starts_with("dm_")) %>% 
    select(where(~ any(. != 0)))

    ### retrieve German definition of domains
  domains <- ""
  
    for (index in seq_along(colnames(positive_dm_vars))) {
        dm_var <- colnames(positive_dm_vars)[index]
        definition <- domain$german[domain$key == dm_var]
    
        # Append numbered domain to the "domains" text
        domains <- paste(domains, paste0(index, ". ", definition, "\n"), sep = " ")
    }


    ### short description
  short <- bverfg$short_description[bverfg$id == mult$id[i]]

    ### full text
  full <- bverfg$full_text[bverfg$id == mult$id[i]]

    ### compile prompt
  case <- paste(intro1, domains, ". \n\r\n", intro2, intro3, 
               short, ". \n\r\n", intro4, "\n\r\n", full, sep = "")

    ### cut very long decisions
  words <- unlist(strsplit(case, "\\s+"))
  max_words <- 7000
  len_words <- min(max_words, length(words))
  case <- paste(words[1:len_words], collapse = " ")

    ### save result in separate file
  file_name <- paste0("case", i, ".txt")
#   my_path <- "/Users/engel/Documents/word/Manuskript/Governance/BVerfG/Data/2023 GPT Tests/venv/cases/"
   # my_path <- "/Users/amao/git/Constitutional_NLP_Summer_2022/venv/cases_2/"
  
  file_path <- paste0(write_path, file_name)
  cat(case, file = file_path)
}

##### EXTRACT DOMAIN FROM GPT RESPONSE ----
  #### extract information from GPT ----
    ### extract domain number from GPT response ----
    ### prepare files
# directory <- "/Users/engel/Documents/word/Manuskript/Governance/BVerfG/Data/2023 GPT Tests/venv/responses"
directory <- "/Users/amao/git/Constitutional_NLP_Summer_2022/venv/responses"

files <- mixedsort(list.files(directory, pattern = "\\.txt$", full.names = TRUE))
num <- 1:nrow(mult)
extract <- data.frame(nrow = num, dm = NA)
extract <- left_join(extract, mult)
    ### loop over all response files
for (i in 1:nrow(extract)) {
  content <- readLines(files[i], warn = FALSE)
  hgegenstand_number <- str_extract(content[length(content)],
                                   "Gegenstand \\s*(\\d+)")
  gegenstand_number <- str_extract(hgegenstand_number, "\\d")
  extract$dm[extract$nrow == i] <- as.numeric(gegenstand_number)
}
    ### check for missing values ----
table(extract$nrow[is.na(extract$dm)])
    ### do handle these cases manually
extract$dm[extract$nrow == 90] <- 5
  # Transplantationsgesetz, allgemeine Handlungsfreiheit
extract$dm[extract$nrow == 99] <- 2
  # Aktienrecht, im weiteren Sinne Vereinigungsfreiheit
extract$dm[extract$nrow == 186] <- 1
  # GPT protestiert zu Recht: ist dm_property (das nicht genannt war)
    # is wrong: must later be corrected manually
    # but otherwise following code does not run through
extract$dm[extract$nrow == 386] <- 1
  # Aktienrecht, im weiteren Sinne Vereinigungsfreiheit
extract$dm[extract$nrow == 892] <- 1
  # bei sehr weiter Auslegung Recht der freien Berufe
extract$dm[extract$nrow == 1201] <- 1
    # is wrong, must later the corrected manually
    # but otherwise following code does not run through
    # no fitting comp discernible (COVID case)
extract$dm[extract$nrow == 1280] <- 1
  # is wrong, must later the corrected manually
    # but otherwise following code does not run through
    # dm_art

    ### retrieve name of relevant domain ----
    ### initialize variable
extract$name <- NA
    ### reverse engineer encoding
for (i in (1:nrow(mult))) {
  # Get the case ID
  case_id <- extract$id[i]
  # Get the relevant domains for the current case
    positive_dm_vars <- bverfg %>%
      filter(id == case_id) %>%
      select(starts_with("dm_")) %>%
      select(where(~ any(. != 0)))
  # put in a vector
    positive_dm_vars <- colnames(positive_dm_vars)
  # Extract the number from the 'extract' dataframe
    gegenstand_number <- extract$dm[i]
  # add name to "extract" dataset
    extract$name[i] <- positive_dm_vars[as.numeric(gegenstand_number)]
}

    ### manual corrections ----
    # following the check for missing values above
extract$name[extract$nrow == 186] <- "dm_property"
extract$name[extract$nrow == 463] <- "dm_freedomgeneral"
extract$name[extract$nrow == 1280] <- "dm_art"
    # nrow == 1201 can only be adjusted at a later point to none
    # (or the following code is not running through)

    ### merge with main dataset ----
bverfg <- merge(bverfg, extract, by = "id", all.x = TRUE)

  #### replace all dm_ in bverfg by 0 unless listed in extract
for (j in 1:nrow(extract)) {
  i <- extract$id[extract$nrow == j]
  nametokeep <- extract$name[extract$id == i]
  bverfg %>% filter(id == i) %>%
    select(starts_with("dm_")) %>%
    mutate(across(everything(), ~ 0)) %>%  # Step 1: Set all variables to 0
    mutate(across(all_of(nametokeep), ~ 1)) -> bverfgdm
  bverfg %>%
    filter(id == i) %>%
    select(!starts_with("dm_")) -> bverfgnotdm
  bverfgdm <- cbind(bverfgdm, bverfgnotdm)
  bverfg %>%
    filter(id != i) -> bverfgoth
  bverfg <- rbind(bverfgoth, bverfgdm)
}

    ### correct one case where domain cannot be defined ----
# bverfg %>% 
#   filter(id == 7266) %>% 
#   select(starts_with("dm_"))
bverfg$dm_manifestations[bverfg$id == 7266] <- 0
bverfg$dm_professions[bverfg$id == 7266] <- 0
  
  #### check whether domain is unique for all handled cases
# table(bverfg$sumdm[bverfg$body == "chamber" &
#                       bverfg$senate == 1 &
#                       bverfg$id %in% extract$id])
# bverfg %>% 
#   mutate(sumdm_new = rowSums(select(., starts_with("dm_")))) -> bverfg
# table(bverfg$sumdm_new[bverfg$body == "chamber" &
#                       bverfg$senate == 1 &
#                       bverfg$id %in% extract$id])
    ### recalculate number of domains per case ----
bverfg <- bverfg %>% 
  mutate(sumdm = rowSums(select(., starts_with("dm_"))))

  #### redefine referee ----
bverfg$ref_seidl <- ifelse((bverfg$dm_environmental == 1 | bverfg$dm_property == 1 |
                               bverfg$dm_ip == 1 | bverfg$dm_inheritance == 1 |
                               bverfg$dm_childallowance == 1 | bverfg$dm_developmentcharge == 1 |
                               bverfg$dm_landsale == 1 ) &
                              (bverfg$date > "1997-12-31" & bverfg$date < "1998-02-28"),
                            1, 0)
bverfg$ref_papier <- ifelse(((bverfg$date > "1998-02-27" & bverfg$date < "1999-12-17") &
                                (bverfg$dm_farming == 1 | bverfg$dm_childallowance == 1 |
                                   bverfg$dm_developmentcharge == 1 | bverfg$dm_landsale == 1)) |
                               ((bverfg$date > "1998-02-27" & bverfg$date < "2010-03-15") &
                                  (bverfg$dm_environmental == 1 | bverfg$dm_property == 1 |
                                     bverfg$dm_ip == 1 | bverfg$dm_inheritance == 1 )), 1, 0)
bverfg$ref_haas <- ifelse(((bverfg$date > "1997-12-31" & bverfg$date < "1999-12-17") &
                              bverfg$dm_postwar == 1 ) |
                             ((bverfg$date > "1997-12-31" & bverfg$date < "2006-10-03") &
                                (bverfg$dm_taking == 1 | bverfg$dm_tax == 1 |
                                   bverfg$dm_levies == 1 |
                                   bverfg$dm_construction == 1 |
                                   bverfg$dm_planning == 1 | bverfg$dm_landuse == 1 |
                                   bverfg$dm_conservation == 1 |
                                   bverfg$dm_landconsolidation == 1)) |
                             ((bverfg$date > "1999-12-16" & bverfg$date < "2006-10-03") &
                                (bverfg$dm_landsale == 1 | bverfg$dm_developmentcharge == 1)), 1, 0)
bverfg$ref_grimm <- ifelse((bverfg$date > "1997-12-31" & bverfg$date < "1999-12-17") &
                              (bverfg$dm_association == 1 |
                                 bverfg$dm_petitions == 1 | bverfg$dm_competition == 1 |
                                 bverfg$dm_speech == 1 | bverfg$dm_manifestations == 1 |
                                 bverfg$dm_freedomgeneral == 1 | bverfg$dm_dataprotection == 1) |
                              (bverfg$dm_restitution == 1 & bverfg$justgrimm == 1), 1, 0)
bverfg$ref_hoemig <- ifelse(((bverfg$date > "1997-12-31" & bverfg$date < "1999-12-17") &
                                (bverfg$dm_art == 1 | bverfg$dm_university == 1 |
                                   bverfg$dm_science == 1)) |
                               ((bverfg$date > "1997-12-31" & bverfg$date < "2006-04-25") &
                                  (bverfg$dm_religion == 1 | bverfg$dm_school == 1 |
                                     bverfg$dm_reunification == 1)), 1, 0)                           
bverfg$ref_kuehling <- ifelse(((bverfg$date > "1997-12-31" & bverfg$date < "2001-01-24") &
                                  (bverfg$dm_labour == 1 | bverfg$dm_labourleasing == 1 |
                                     bverfg$dm_maternityleave == 1)) |
                                 ((bverfg$date > "1999-12-16" & bverfg$date < "2001-01-24") &
                                    (bverfg$dm_art == 1 | bverfg$dm_association == 1 |
                                       bverfg$dm_university == 1 | bverfg$dm_science == 1 |
                                       bverfg$dm_petitions == 1 | bverfg$dm_childallowance == 1)), 1, 0)
bverfg$ref_seibert <- ifelse((bverfg$date > "1997-12-31" & bverfg$date < "1998-09-29") &
                                (bverfg$dm_family == 1 | bverfg$dm_names == 1 |
                                   bverfg$dm_civilstatus == 1 | bverfg$dm_transsexual == 1 |
                                   bverfg$dm_child == 1), 1, 0)
bverfg$ref_jaeger <- ifelse((bverfg$date > "1997-12-31" & bverfg$date < "2004-11-01") &
                               (bverfg$dm_professions == 1 | bverfg$dm_exams == 1 |
                                  bverfg$dm_healthinsurance == 1), 1, 0)
bverfg$ref_steiner <- ifelse((bverfg$date > "1997-12-31" & bverfg$date < "2007-10-02") &
                                bverfg$dm_socialsecurity == 1, 1, 0)
bverfg$ref_hohmanndennhardt <- ifelse((bverfg$date > "1998-09-28" & bverfg$date < "2011-02-02") &
                                         (bverfg$dm_family == 1 | bverfg$dm_names == 1 |
                                            bverfg$dm_civilstatus == 1 | bverfg$dm_transsexual == 1 |
                                            bverfg$dm_child == 1), 1, 0)
bverfg$ref_hoffmannriem <- ifelse((bverfg$date > "1999-12-16" & bverfg$date < "2008-04-03") &
                                     (bverfg$dm_competition == 1 | bverfg$dm_speech == 1 |
                                        bverfg$dm_manifestations == 1 | bverfg$dm_freedomgeneral == 1 |
                                        bverfg$dm_dataprotection == 1), 1, 0)
bverfg$ref_bryde <- ifelse(((bverfg$date > "2001-01-23" & bverfg$date < "2010-03-15") &
                               (bverfg$dm_art == 1 | bverfg$dm_petitions == 1)) |
                              ((bverfg$date > "2001-01-23" & bverfg$date < "2011-02-02") &
                                 (bverfg$dm_labour == 1 | bverfg$dm_labourleasing == 1 |
                                    bverfg$dm_maternityleave == 1 | bverfg$dm_association == 1 |
                                    bverfg$dm_university == 1 | bverfg$dm_science == 1 |
                                    bverfg$dm_childallowance == 1)) |
                              ((bverfg$date > "2008-12-31" & bverfg$date < "2010-03-15") &
                                 bverfg$dm_services == 1) |
                              ((bverfg$date > "2010-03-14" & bverfg$date < "2011-02-02") &
                                 (bverfg$dm_welfarebasic == 1 | bverfg$dm_asylumallowance == 1 |
                                    bverfg$dm_welfare == 1 | bverfg$dm_vocationalallowance == 1)), 1, 0)
bverfg$ref_gaier <- ifelse(((bverfg$date > "2004-10-31" & bverfg$date < "2013-01-01") &
                               bverfg$dm_exams == 1) |
                              ((bverfg$date > "2004-10-31" & bverfg$date < "2016-04-01") &
                                 (bverfg$dm_healthinsurance == 1)) |
                              ((bverfg$date > "2004-10-31" & bverfg$date < "2016-11-01") &
                                 (bverfg$dm_professions == 1 )) |
                              ((bverfg$date > "2008-04-02" & bverfg$date < "2016-11-01") &
                                 bverfg$dm_competition == 1 ) |
                              ((bverfg$date > "2010-03-14" & bverfg$date < "2016-11-01") &
                                 (bverfg$dm_pensionfund == 1 | bverfg$dm_competitionenergy == 1)) |
                              ((bverfg$date > "2010-12-31" & bverfg$date < "2013-01-01") &
                                 bverfg$dm_sales == 1) |
                              ((bverfg$date > "2012-12-31" & bverfg$date < "2016-11-01") &
                                 bverfg$dm_landlord == 1) |
                              ((bverfg$date > "2015-06-30" & bverfg$date < "2016-11-01") &
                                 bverfg$dm_attorney == 1) |
                              (bverfg$dm_welfarebasic == 1 & 
                                 ((bverfg$date > "2014-12-31" & bverfg$date < "2015-07-01") |
                                    (bverfg$date > "2015-12-31" & bverfg$date < "2016-04-01"))), 1, 0)
bverfg$ref_schluckebier <- ifelse(((bverfg$date > "2006-04-24" & bverfg$date < "2017-12-02") &
                                      (bverfg$dm_religion == 1 | bverfg$dm_school == 1 |
                                         bverfg$dm_reunification == 1 | bverfg$dm_corporations == 1)) |
                                     ((bverfg$date > "2011-12-31" & bverfg$date < "2017-12-02") &
                                        bverfg$dm_vocationalallowance == 1) | 
                                     ((bverfg$date > "2012-12-31" & bverfg$date < "2017-12-02") &
                                        bverfg$dm_exams == 1), 1, 0)
bverfg$ref_eichberger <- ifelse(((bverfg$date > "2006-10-02" & bverfg$date < "2009-01-01") &
                                    (bverfg$dm_landsale == 1)) |
                                   ((bverfg$date > "2006-10-02" & bverfg$date < "2010-03-15") &
                                      (bverfg$dm_levies == 1 | bverfg$dm_conservation == 1 |
                                         bverfg$dm_landconsolidation == 1)) |
                                   ((bverfg$date > "2006-10-02" & bverfg$date < "2015-01-01") &
                                      (bverfg$dm_developmentcharge == 1 | bverfg$dm_construction == 1)) |
                                   ((bverfg$date > "2006-10-02" & bverfg$date < "2018-06-17") &
                                      (bverfg$dm_taking == 1 |
                                         bverfg$dm_planning == 1 | bverfg$dm_landuse == 1)) |
                                   ((bverfg$date > "2006-10-02" & bverfg$date < "2018-06-17") &
                                      (bverfg$dm_tax == 1 & bverfg$justeichberger == 1)) |
                                   ((bverfg$date > "2008-12-31" & bverfg$date < "2015-01-01") &
                                      bverfg$dm_regulation == 1 ) |
                                   ((bverfg$date > "2008-12-31" & bverfg$date < "2018-06-17") &
                                      bverfg$dm_mining == 1) |
                                   ((bverfg$date > "2010-03-14" & bverfg$date < "2018-06-17") &
                                      (bverfg$dm_environmental == 1 | bverfg$dm_property == 1)) |
                                   ((bverfg$date > "2015-06-30" & bverfg$date < "2018-06-17") &
                                      bverfg$dm_supportpayment == 1) |
                                   ((bverfg$date > "2017-12-01" & bverfg$date < "2018-06-17") &
                                      (bverfg$dm_welfarebasic == 1 & bverfg$justeichberger == 1)), 1, 0)
bverfg$ref_fkirchhof <- ifelse(((bverfg$date > "2007-10-01" & bverfg$date < "2018-12-01") &
                                   bverfg$dm_socialsecurity == 1) |
                                  ((bverfg$date > "2016-06-30" & bverfg$date < "2018-12-01") &
                                     bverfg$dm_healthinsurance == 1), 1, 0)
bverfg$ref_masing <- ifelse(((bverfg$date > "2008-04-02" & bverfg$date < "2020-01-01") &
                                (bverfg$dm_manifestations == 1 )) |
                               ((bverfg$date > "2008-04-02" & bverfg$date < "2020-07-11") &
                                  ((bverfg$dm_speech == 1 | bverfg$dm_manifestations == 1 |
                                      bverfg$dm_freedomgeneral == 1 | bverfg$dm_dataprotection == 1 |
                                      bverfg$dm_competitionspeech == 1) & bverfg$justmasing == 1)) |
                               ((bverfg$date > "2017-12-01" & bverfg$date < "2020-07-11") &
                                  bverfg$dm_welfarebasic == 1 & bverfg$justmasing == 1) |
                               bverfg$dm_torts == 1, 1, 0)
bverfg$ref_paulus <- ifelse(((bverfg$date > "2010-03-14" & bverfg$date < "2015-07-01") &
                                bverfg$dm_services == 1) |
                               ((bverfg$date > "2010-03-14" & bverfg$date < "2020-01-01") &
                                  bverfg$dm_gaming == 1) |
                               ((bverfg$date > "2010-03-14" & bverfg$date < "2021-01-01") &
                                  bverfg$dm_inheritance == 1) |
                               ((bverfg$date > "2010-03-14" & bverfg$date < "2022-06-04") &
                                  (bverfg$dm_ip == 1 | bverfg$dm_inheritance == 1 |
                                     bverfg$dm_art == 1 | bverfg$dm_levies == 1)) |
                               ((bverfg$date > "2014-12-31" & bverfg$date < "2020-01-01") &
                                  (bverfg$dm_developmentcharge == 1 | bverfg$dm_construction == 1)) |
                               ((bverfg$date > "2015-12-31" & bverfg$date < "2021-01-01") &
                                  bverfg$dm_custody == 1) |
                               (bverfg$date > "2018-11-30" & 
                                  (bverfg$dm_competition == 1 | bverfg$dm_competitionenergy == 1)), 1, 0)
bverfg$ref_britz <- ifelse(((bverfg$date > "2011-02-01" & bverfg$date < "2012-01-01") &
                               bverfg$dm_custody == 1) |
                              ((bverfg$date > "2011-02-01" & bverfg$date < "2018-06-17") &
                                 (bverfg$dm_family == 1 | bverfg$dm_names == 1 |
                                    bverfg$dm_civilstatus == 1 | bverfg$dm_transsexual == 1 |
                                    bverfg$dm_child == 1 | bverfg$dm_parentalallowance == 1)) |
                              (bverfg$date > "2014-12-31" & bverfg$dm_regulation == 1) |
                              ((bverfg$date > "2017-12-01" & bverfg$date < "2018-06-17") &
                                 bverfg$dm_condominium == 1) |
                              (bverfg$date > "2018-06-16" & 
                                 (bverfg$dm_environmental == 1 | bverfg$dm_taking == 1 |
                                    bverfg$dm_supportpayment == 1 | 
                                    bverfg$dm_pensionright == 1 | 
                                    bverfg$dm_welfare == 1 | bverfg$dm_mining == 1 |
                                    bverfg$dm_planning == 1 | bverfg$dm_landuse == 1)) |
                              (bverfg$date > "2018-06-16" &
                                 (bverfg$dm_property == 1 | bverfg$dm_welfarebasic == 1) &
                                 bverfg$justbritz == 1) |
                              (bverfg$date > "2020-06-30" &
                                 (bverfg$dm_dataprotection == 1 | bverfg$dm_construction == 1 |
                                    bverfg$dm_developmentcharge == 1) & bverfg$justbritz == 1), 1, 0)
bverfg$ref_baer <- ifelse((bverfg$date > "2011-02-01" &
                              (bverfg$dm_labour == 1 | bverfg$dm_labourleasing == 1 |
                                 bverfg$dm_maternityleave == 1 | bverfg$dm_association == 1 |
                                 bverfg$dm_university == 1 | bverfg$dm_science == 1 |
                                 bverfg$dm_childallowance == 1  |
                                 bverfg$dm_asylumallowance == 1) |
                              ((bverfg$date > "2011-02-01" & bverfg$date < "2016-01-01") &
                                 bverfg$dm_welfare == 1) |
                              ((bverfg$date > "2011-02-01" & bverfg$date < "2015-01-01") &
                                 bverfg$dm_welfarebasic == 1) |
                              ((bverfg$date > "2011-02-01" & bverfg$date < "2012-01-01") &
                                 bverfg$dm_vocationalallowance == 1)) |
                             ((bverfg$date > "2015-06-30" & bverfg$date < "2016-01-01") &
                                bverfg$dm_welfarebasic == 1) |
                             (bverfg$date > "2016-03-31" & bverfg$dm_welfarebasic == 1 &
                                bverfg$justbaer == 1), 1, 0)
bverfg$ref_ott <- ifelse((bverfg$date > "2016-10-31" & 
                             (bverfg$dm_professions == 1 | bverfg$dm_pensionfund == 1 |
                                bverfg$dm_landlord == 1 | bverfg$dm_attorney == 1)) |
                            ((bverfg$date > "2016-10-31" & bverfg$date < "2018-12-01") & 
                               (bverfg$dm_competition == 1 | bverfg$dm_competitionenergy == 1)) |
                            (bverfg$date > "2018-06-16" & bverfg$dm_tax == 1 &
                               bverfg$justott == 1), 1, 0)
bverfg$ref_christ <- ifelse((bverfg$date > "2017-12-01" &
                                (bverfg$dm_vocationalallowance == 1 | bverfg$dm_exams == 1 |
                                   bverfg$dm_religion == 1 | bverfg$dm_school == 1 |
                                   bverfg$dm_reunification == 1 | bverfg$dm_corporations == 1)) |
                               (bverfg$date > "2020-12-31" & bverfg$dm_inheritance == 1), 1, 0)
bverfg$ref_radtke <- ifelse(bverfg$date > "2018-06-16" &
                               (bverfg$dm_family == 1 | bverfg$dm_names == 1 |
                                  bverfg$dm_civilstatus == 1 | bverfg$dm_transsexual == 1 |
                                  bverfg$dm_child == 1 | bverfg$dm_parentalallowance == 1 |
                                  bverfg$dm_condominium == 1), 1, 0)
bverfg$ref_harbarth <- ifelse((bverfg$date > "2018-11-30" & bverfg$date < "2022-06-04" &
                                  (bverfg$dm_healthinsurance == 1 | bverfg$dm_socialsecurity == 1)) |
                                 (bverfg$date > "2019-12-31" & 
                                    bverfg$dm_manifestations == 1) |
                                 (bverfg$date > "2022-06-03" &
                                    (bverfg$dm_ip == 1 | bverfg$dm_custody == 1 |
                                       bverfg$dm_competition == 1 | bverfg$dm_levies == 1)), 1, 0)
bverfg$ref_haertel <- ifelse(bverfg$date > "2020-07-10" &
                                ((bverfg$dm_speech == 1 |
                                    bverfg$dm_freedomgeneral == 1 | bverfg$dm_dataprotection == 1 |
                                    bverfg$dm_competitionspeech == 1)) |
                                (bverfg$dm_welfarebasic == 1 & bverfg$justhaertel == 1), 1, 0)
bverfg$ref_wolff <- ifelse(bverfg$date > "2022-06-03" & 
                              (bverfg$dm_art == 1 | bverfg$dm_healthinsurance == 1 |
                                 bverfg$dm_socialsecurity == 1), 1, 0)
#### housekeeping
bverfg$sumref_new <- rowSums(bverfg[, c(grep("ref_", names(bverfg)))])


save(bverfg, file = "court_final_data.RData")


