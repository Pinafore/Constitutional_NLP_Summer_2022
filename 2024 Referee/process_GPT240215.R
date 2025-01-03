##### BVerfG
##### Referee: Prepare for / from GPT
##### 240215

##### HOUSEKEEPING ----
##### clean
rm(list = ls())

##### load libraries
library(stringr)
library(dplyr)
library(tidyr)
library(ggplot2)
theme_update(plot.title = element_text(hjust = 0.5))

##### set working directory
setwd("/Users/engel/Documents/word/Manuskript/Governance/BVerfG/Data/2024 Referee/")

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
bverfg %>% 
  filter(senate == 1,
         body == "chamber",
         sumref > 1,
         sumdm > 1) %>% 
  select(id) -> mult
mult$nrow <- 1:nrow(mult)

  #### compile prompt ----
    ### generic components ----

intro1 <- "Für die folgende Entscheidung kommen diese Gegenstände in Betracht: \n"

intro2 <- "Können Sie anhand des folgenden Texts entscheiden, welcher dieser Gegenstände der richtige ist? \n"

intro3 <- "Auf seiner Website hat das Gericht den Fall so beschrieben: \n"

intro4 <- "Es folgt der Text der Entscheidung (wenn die Entscheidung sehr lang ist, wird nur der Beginn der Entscheidung mitgeteilt): \n"
    
    ### load help file with German domain names ----
load("domain240129.RData")

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
  my_path <- "/Users/engel/Documents/word/Manuskript/Governance/BVerfG/Data/2023 GPT Tests/venv/cases/"
  file_path <- paste0(my_path, file_name)
  cat(case, file = file_path)
}

##### senate 2 chamber ----
  #### select relevant cases ----
bverfg %>% 
  filter(senate == 2,
         body == "chamber",
         sumref2 > 1,
         sumdm2 > 1) %>% 
  select(id) -> mult2
mult2$nrow <- 1:nrow(mult2)

  #### compile prompt ----
    ### generic components ----

intro1 <- "Für die folgende Entscheidung kommen diese Gegenstände in Betracht: \n"

intro2 <- "Können Sie anhand des folgenden Texts entscheiden, welcher dieser Gegenstände der richtige ist? \n"

intro3 <- "Auf seiner Website hat das Gericht den Fall so beschrieben: \n"

intro4 <- "Es folgt der Text der Entscheidung (wenn die Entscheidung sehr lang ist, wird nur der Beginn der Entscheidung mitgeteilt): \n"
    
    ### load help file with German domain names ----
load("domain240215.RData")

    ### loop over individual cases ----
for (i in 1:nrow(mult2)) {
    ### relevant domains
  positive_dm2_vars <- bverfg %>% 
    filter(id == mult2$id[i]) %>%
    select(starts_with("dm2_")) %>% 
    select(where(~ any(. != 0)))

    ### retrieve German definition of domains
  domains <- ""
  
    for (index in seq_along(colnames(positive_dm2_vars))) {
        dm2_var <- colnames(positive_dm2_vars)[index]
        definition <- domain$german[domain$key == dm2_var]
    
        # Append numbered domain to the "domains" text
        domains <- paste(domains, paste0(index, ". ", definition, "\n"), sep = " ")
    }


    ### short description
  short <- bverfg$short_description[bverfg$id == mult2$id[i]]

    ### full text
  full <- bverfg$full_text[bverfg$id == mult2$id[i]]

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
  # my_path <- "/Users/engel/Documents/word/Manuskript/Governance/BVerfG/Data/2024 Referee/cases/"
  my_path <- "/Users/engel/Documents/word/Manuskript/Governance/BVerfG/Data/2023 GPT Tests/venv/cases2/"
  file_path <- paste0(my_path, file_name)
  cat(case, file = file_path)
}

##### EXTRACT DOMAIN FROM GPT RESPONSE ----
##### senate 1 ----
  #### extract information from GPT ----
    ### extract domain number from GPT response ----
    ### prepare files
directory <- "/Users/engel/Documents/word/Manuskript/Governance/BVerfG/Data/2023 GPT Tests/venv/responses"
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



##### senate 2 ----
  #### extract information from GPT ----
    ### extract domain number from GPT response ----
    ### prepare files
directory <- "/Users/engel/Documents/word/Manuskript/Governance/BVerfG/Data/2023 GPT Tests/venv/responses2"
files <- mixedsort(list.files(directory, pattern = "\\.txt$", full.names = TRUE))
num <- 1:nrow(mult2)
extract <- data.frame(nrow = num, dm2 = NA)
extract <- left_join(extract, mult2)
    ### loop over all response files
for (i in 1:nrow(extract)) {
  content <- readLines(files[i], warn = FALSE)
  hgegenstand_number <- str_extract(content[length(content)],
                                   "Gegenstand \\s*(\\d+)")
  gegenstand_number <- str_extract(hgegenstand_number, "\\d")
  extract$dm[extract$nrow == i] <- as.numeric(gegenstand_number)
}
    ### check for missing values ----
table(extract$nrow[is.na(extract$dm2)])
    ### do handle these cases manually
    ### to be done once date is in !

    ### retrieve name of relevant domain ----
    ### initialize variable
extract$name <- NA
    ### reverse engineer encoding
for (i in (1:nrow(mult2))) {
  # Get the case ID
  case_id <- extract$id[i]
  # Get the relevant domains for the current case
    positive_dm2_vars <- bverfg %>%
      filter(id == case_id) %>%
      select(starts_with("dm2_")) %>%
      select(where(~ any(. != 0)))
  # put in a vector
    positive_dm2_vars <- colnames(positive_dm2_vars)
  # Extract the number from the 'extract' dataframe
    gegenstand_number <- extract$dm2[i]
  # add name to "extract" dataset
    extract$name[i] <- positive_dm2_vars[as.numeric(gegenstand_number)]
}

    ### manual corrections ----
    # following the check for missing values above 
    # to be done once data in in!

    ### merge with main dataset ----
bverfg <- merge(bverfg, extract, by = "id", all.x = TRUE)

  #### replace all dm2_ in bverfg by 0 unless listed in extract
for (j in 1:nrow(extract)) {
  i <- extract$id[extract$nrow == j]
  nametokeep <- extract$name[extract$id == i]
  bverfg %>% filter(id == i) %>%
    select(starts_with("dm2_")) %>%
    mutate(across(everything(), ~ 0)) %>%  # Step 1: Set all variables to 0
    mutate(across(all_of(nametokeep), ~ 1)) -> bverfgdm2
  bverfg %>% 
    filter(id == i) %>% 
    select(!starts_with("dm2_")) -> bverfgnotdm2
  bverfgdm2 <- cbind(bverfgdm2, bverfgnotdm2)
  bverfg %>% 
    filter(id != i) -> bverfgoth
  bverfg <- rbind(bverfgoth, bverfgdm)
}

    ### correct one case where domain cannot be defined ----
      # to be done once data is in!
  
  #### check whether domain is unique for all handled cases
    ### recalculate number of domains per case ----
bverfg <- bverfg %>% 
  mutate(sumdm = rowSums(select(., starts_with("dm2_"))))

  ##### redefine referee ----
  bverfg$ref2_kruis <- ifelse(((bverfg$date > "1997-12-31" & bverfg$date < "1998-10-16") &
                                  (bverfg$dm2_detention == 1 |
                                     bverfg$dm2_prosecution == 1 | bverfg$dm2_adminoffence == 1)), 1, 0) 
  bverfg$ref2_grasshof <- ifelse(((bverfg$date > "1997-12-31" & bverfg$date < "1998-10-16") &
                                     (bverfg$dm2_extradition == 1 | bverfg$dm2_nationality == 1 |
                                        bverfg$dm2_elections == 1 | bverfg$dm2_fgg == 1 |
                                        bverfg$dm2_reinstatement == 1 |
                                        bverfg$dm2_crimeregister == 1)) |
                                    ((bverfg$date > "1997-12-31" & bverfg$date < "1998-10-16") &
                                       ( bverfg$dm2_victim == 1 & bverfg$justgrasshof == 1)) |
                                    ((bverfg$date > "1997-12-31" & bverfg$date < "1998-10-16") &
                                       bverfg$dm2_private == 1 & bverfg$justgrasshof == 1), 1, 0)
  bverfg$ref2_pkirchhof <- ifelse(((bverfg$date > "1997-12-31" & bverfg$date < "1999-12-17") &
                                      (bverfg$dm2_budget == 1 | bverfg$dm2_tax == 1 |
                                         bverfg$dm2_european == 1 | bverfg$dm2_international == 1)) |
                                     ((bverfg$date > "1997-12-31" & bverfg$date < "1999-12-17") &
                                        (bverfg$dm2_victim == 1 & bverfg$justpkirchhof == 1)), 1, 0)
  bverfg$ref2_winter <- ifelse(((bverfg$date > "1997-12-31" & bverfg$date < "2000-10-11") &
                                   (bverfg$dm2_crim == 1 | bverfg$dm2_clemency == 1)) |
                                  ((bverfg$date > "1997-12-31" & bverfg$date < "2000-10-11") &
                                     bverfg$dm2_private == 1 & bverfg$justwinter == 1), 1, 0)
  bverfg$ref2_limbach <- ifelse(((bverfg$date > "1997-12-31" & bverfg$date < "2002-04-11") &
                                    (bverfg$dm2_parliament == 1)) |
                                   ((bverfg$date > "2000-10-10" & bverfg$date < "2002-04-11") &
                                      (bverfg$dm2_military == 1) & bverfg$justlimbach == 1) |
                                   ((bverfg$date > "2000-12-31" & bverfg$date < "2002-04-11") &
                                      bverfg$dm2_crimmilitary == 1) |
                                   ((bverfg$date > "1997-12-31" & bverfg$date < "2002-04-11") &
                                      bverfg$dm2_private == 1 & bverfg$justlimbach == 1), 1, 0)
  bverfg$ref2_sommer <- ifelse(((bverfg$date > "1997-12-31" & bverfg$date < "2000-01-01") &
                                   (bverfg$dm2_socialcourts == 1)) |
                                  ((bverfg$date > "1998-10-16" & bverfg$date < "2002-04-11") &
                                     (bverfg$dm2_nationality == 1)) | 
                                  ((bverfg$date > "1997-12-31" & bverfg$date < "2003-08-01") &
                                     (bverfg$dm2_foreigner == 1 & bverfg$justsommer == 1)) |
                                  ((bverfg$date > "1997-12-31" & bverfg$date < "2003-08-01") &
                                     (bverfg$dm2_administrativecourts == 1)) |
                                  ((bverfg$date > "1997-12-31" & bverfg$date < "2003-08-01") &
                                     (bverfg$dm2_restitution == 1 & bverfg$justsommer == 1 )) |
                                  ((bverfg$date > "1997-12-31" & bverfg$date < "2003-08-01") &
                                     (bverfg$dm2_asylum == 1  & bverfg$justsommer == 1)) |
                                  ((bverfg$date > "1997-12-31" & bverfg$date < "2003-08-01") &
                                     (bverfg$dm2_private == 1  & bverfg$justsommer == 1)) |
                                  ((bverfg$date > "2000-10-10" & bverfg$date < "2003-08-01") &
                                     (bverfg$dm2_publicservice == 1)) |
                                  ((bverfg$date > "2002-04-10" & bverfg$date < "2003-08-01") &
                                     (bverfg$dm2_publicemployee == 1)), 1, 0)
  bverfg$ref2_jentsch <- ifelse(((bverfg$date > "1997-12-31" & bverfg$date < "2000-10-11") &
                                    (bverfg$dm2_publicservice == 1 |
                                       bverfg$dm2_publicemployee == 1 | bverfg$dm2_g131 == 1 |
                                       bverfg$dm2_crimmilitary == 1)) |
                                   ((bverfg$date > "1997-12-31" & bverfg$date < "2002-04-11") &
                                      (bverfg$dm2_military == 1 & bverfg$justjentsch == 1)) |
                                   ((bverfg$date > "1997-12-31" & bverfg$date < "2003-08-01") &
                                      (bverfg$dm2_training == 1)) |
                                   ((bverfg$date > "1997-12-31" & bverfg$date < "2005-09-29") &
                                      (bverfg$dm2_parties == 1 |
                                         bverfg$dm2_disciplinary == 1)) |
                                   ((bverfg$date > "1998-10-15" & bverfg$date < "2005-09-29") &
                                      (bverfg$dm2_elections == 1 |
                                         bverfg$dm2_reinstatement == 1)) |
                                   ((bverfg$date > "1998-10-15" & bverfg$date < "2005-09-29") &
                                      (bverfg$dm2_victim == 1 & bverfg$justjentsch == 1)) |
                                   ((bverfg$date > "2003-07-31" & bverfg$date < "2005-09-29") &
                                      (bverfg$dm2_publicemployee == 1)) |
                                   ((bverfg$date > "1997-12-31" & bverfg$date < "1998-10-16") &
                                      (bverfg$dm2_asylum == 1 & bverfg$justjentsch == 1)), 1, 0)
  bverfg$ref2_hassemer <- ifelse(((bverfg$date > "1997-12-31" & bverfg$date < "2000-10-11") &
                                     (bverfg$dm2_municipalities == 1 | 
                                        bverfg$dm2_privateaccusation == 1 |
                                        bverfg$dm2_reopening == 1)) |
                                    ((bverfg$date > "1997-12-31" & bverfg$date < "2002-04-11") &
                                       (bverfg$dm2_church == 1)) |
                                    ((bverfg$date > "1998-10-15" & bverfg$date < "2000-10-11") &
                                       (bverfg$dm2_detention == 1 | 
                                          bverfg$dm2_prosecution == 1 |
                                          bverfg$dm2_crimenforce == 1)) |
                                    ((bverfg$date > "2000-10-10" & bverfg$date < "2002-01-01") &
                                       (bverfg$dm2_private == 1 & bverfg$justhassemer == 1)) |
                                    ((bverfg$date > "2000-10-10" & bverfg$date < "2008-05-08") &
                                       (bverfg$dm2_crim == 1 | bverfg$dm2_clemency == 1)), 1, 0)
  bverfg$ref2_bross <- ifelse(((bverfg$date > "1998-10-15" & bverfg$date < "2002-04-11") &
                                  (bverfg$dm2_asylum == 1 | bverfg$dm2_private) & bverfg$justbross == 1) | 
                                 ((bverfg$date > "1998-10-15" & bverfg$date < "2010-11-17") &
                                    bverfg$dm2_adminoffence == 1) |
                                 ((bverfg$date > "1999-12-16" & bverfg$date < "2010-11-17") &
                                    bverfg$dm2_pretrial == 1) |
                                 ((bverfg$date > "1999-12-16" & bverfg$date < "2010-11-17") &
                                    bverfg$dm2_european == 1 & bverfg$justbross == 1) |
                                 ((bverfg$date > "2000-10-10" & bverfg$date < "2010-11-17") &
                                    (bverfg$dm2_crimeregister == 1 | bverfg$dm2_fgg == 1)) |
                                 ((bverfg$date > "2002-04-10" & bverfg$date < "2010-11-17") &
                                    (bverfg$dm2_reopening == 1 | bverfg$dm2_church == 1)) |
                                 ((bverfg$date > "2005-09-28" & bverfg$date < "2010-11-17") &
                                    (bverfg$dm2_parliament == 1 & bverfg$justbross == 1)) |
                                 ((bverfg$date > "2008-05-07" & bverfg$date < "2010-11-17") &
                                    (bverfg$dm2_reinstatement == 1 | bverfg$dm2_condominium == 1)) |
                                 ((bverfg$date > "2003-07-31" & bverfg$date < "2005-09-29") &
                                    bverfg$dm2_publicservice == 1), 1, 0)                               
  bverfg$ref2_osterloh <- ifelse(((bverfg$date > "1998-10-15" & bverfg$date < "2000-10-11") &
                                     (bverfg$dm2_fgg == 1 | bverfg$dm2_crimeregister |
                                        bverfg$dm2_extradition == 1)) |
                                    ((bverfg$date > "1998-10-15" & bverfg$date < "2002-04-11") &
                                       (bverfg$dm2_asylum == 1 & bverfg$justosterloh == 1)) |
                                    ((bverfg$date > "1998-10-15" & bverfg$date < "2010-11-17") &
                                       (bverfg$dm2_private == 1 & bverfg$justosterloh == 1)) |
                                    ((bverfg$date > "1999-12-16" & bverfg$date < "2010-11-17") &
                                       (bverfg$dm2_budget == 1)) |
                                    ((bverfg$date > "1999-12-16" & bverfg$date < "2010-11-17") &
                                       bverfg$dm2_tax == 1 & bverfg$justosterloh == 1) |
                                    ((bverfg$date > "2008-05-07" & bverfg$date < "2010-11-17") &
                                       (bverfg$dm2_foreclosure == 1)), 1, 0)
  bverfg$ref2_mellinghoff <- ifelse(((bverfg$date > "2001-01-22" & bverfg$date < "2002-04-11") &
                                        (bverfg$dm2_detention == 1 | 
                                           bverfg$dm2_privateaccusation == 1 |
                                           bverfg$dm2_reopening == 1)) |
                                       ((bverfg$date > "2001-01-22" & bverfg$date < "2010-11-17") &
                                          (bverfg$dm2_municipalities == 1 & bverfg$justmellinghoff == 1)) |
                                       ((bverfg$date > "2001-01-22" & bverfg$date < "2010-11-17") &
                                          (bverfg$dm2_crimenforce == 1 & bverfg$justmellinghoff == 1)) |
                                       ((bverfg$date > "2001-01-22" & bverfg$date < "2011-11-01") &
                                          (bverfg$dm2_prosecution == 1 )) |
                                       ((bverfg$date > "2002-04-10" & bverfg$date < "2008-05-08") &
                                          (bverfg$dm2_military == 1)) |
                                       ((bverfg$date > "2005-09-28" & bverfg$date < "2010-11-17") &
                                          (bverfg$dm2_parties == 1)) |
                                       ((bverfg$date > "2005-09-28" & bverfg$date < "2011-11-01") &
                                          (bverfg$dm2_elections == 1 & bverfg$justmellinghoff == 1)) |
                                       ((bverfg$date > "2008-05-07" & bverfg$date < "2010-01-01") &
                                          (bverfg$dm2_insolvency == 1)) |
                                       ((bverfg$date > "2008-05-07" & bverfg$date < "2010-11-17") &
                                          (bverfg$dm2_tax == 1 & bverfg$justmellinghoff == 1)) |
                                       ((bverfg$date > "2008-05-07" & bverfg$date < "2011-11-01") &
                                          (bverfg$dm2_executionsale == 1)), 1, 0)
  bverfg$ref2_difabio <- ifelse(((bverfg$date > "1999-12-16" & bverfg$date < "2005-01-01") &
                                    bverfg$dm2_foreigner == 1 & bverfg$justdifabio == 1) |
                                   ((bverfg$date > "1999-12-16" & bverfg$date < "2005-09-29") &
                                      (bverfg$dm2_asylum == 1 & bverfg$justdifabio == 1)) |
                                   ((bverfg$date > "1999-12-16" & bverfg$date < "2011-12-20") &
                                      (bverfg$dm2_international == 1)) |
                                   ((bverfg$date > "1999-12-16" & bverfg$date < "2011-12-20") &
                                      (bverfg$dm2_victim == 1 & bverfg$justdifabio == 1)) |
                                   ((bverfg$date > "2000-10-10" & bverfg$date < "2011-12-20") &
                                      bverfg$dm2_extradition == 1) |
                                   ((bverfg$date > "2000-12-31" & bverfg$date < "2010-11-17") &
                                      bverfg$dm2_parliament == 1 & bverfg$justdifabio == 1) |
                                   ((bverfg$date > "2005-09-28" & bverfg$date < "2011-12-20") &
                                      (bverfg$dm2_municipalities == 1 & bverfg$justdifabio == 1)) |
                                   ((bverfg$date > "2006-12-31" & bverfg$date < "2011-12-20") &
                                      (bverfg$dm2_european == 1 & bverfg$justdifabio == 1)) |
                                   ((bverfg$date > "2008-05-07" & bverfg$date < "2011-12-20") &
                                      (bverfg$dm2_private == 1 & bverfg$justdifabio == 1)) |
                                   ((bverfg$date > "2008-05-07" & bverfg$date < "2011-12-20") &
                                      (bverfg$dm2_privateaccusation == 1)), 1, 0)
  bverfg$ref2_luebbewolff <- ifelse(((bverfg$date > "2002-04-10" & bverfg$date < "2014-06-03") &
                                        (bverfg$dm2_nationality == 1 | bverfg$dm2_detention == 1)) |
                                       ((bverfg$date > "2002-04-10" & bverfg$date < "2009-01-01") &
                                          (bverfg$dm2_asylum == 1 & bverfg$justluebbewolff == 1)) | 
                                       ((bverfg$date > "2008-05-07" & bverfg$date < "2014-06-03") &
                                          (bverfg$dm2_private == 1 & bverfg$justluebbewolff == 1 )) |
                                       ((bverfg$date > "2008-05-07" & bverfg$date < "2014-06-03") &
                                          bverfg$dm2_displacement == 1) |
                                       ((bverfg$date > "2009-12-31" & bverfg$date < "2010-11-17") &
                                          (bverfg$dm2_insolvency == 1)) |
                                       ((bverfg$date > "2010-11-16" & bverfg$date < "2014-06-03") &
                                          (bverfg$dm2_budget == 1)), 1, 0)
  bverfg$ref2_gerhardt <- ifelse(((bverfg$date > "2003-07-31" & bverfg$date < "2005-01-01") &
                                     (bverfg$dm2_administrativecourts == 1)) |
                                    ((bverfg$date > "2003-07-31" & bverfg$date < "2007-01-01") &
                                       (bverfg$dm2_restitution == 1)) |
                                    ((bverfg$date > "2003-07-31" & bverfg$date < "2014-07-16") &
                                       (bverfg$dm2_foreigner == 1 & bverfg$justgerhardt == 1)) |
                                    ((bverfg$date > "2003-07-31" & bverfg$date < "2010-11-17") &
                                       (bverfg$dm2_private == 1 & bverfg$justgerhardt == 1)) |
                                    ((bverfg$date > "2003-07-31" & bverfg$date < "2014-07-16") &
                                       (bverfg$dm2_training == 1)) |
                                    ((bverfg$date > "2003-07-31" & bverfg$date < "2014-07-16") &
                                       (bverfg$dm2_asylum == 1 & bverfg$justgerhardt == 1)) |
                                    ((bverfg$date > "2008-05-07" & bverfg$date < "2010-11-17") &
                                       (bverfg$dm2_weapon == 1 | bverfg$dm2_military == 1)) |
                                    ((bverfg$date > "2010-11-16" & bverfg$date < "2014-07-16") &
                                       (bverfg$dm2_parties == 1)) |
                                    ((bverfg$date > "2010-11-16" & bverfg$date < "2014-07-16") &
                                       (bverfg$dm2_elections == 1 & bverfg$justgerhardt == 1)), 1, 0)
  bverfg$ref2_landau <- ifelse(((bverfg$date > "2005-09-28" & bverfg$date < "2008-05-08") &
                                   (bverfg$dm2_publicservice == 1 | bverfg$dm2_publicemployee == 1 |
                                      bverfg$dm2_disciplinary == 1 | bverfg$dm2_privateaccusation == 1|
                                      bverfg$dm2_reinstatement == 1)) |   
                                  ((bverfg$date > "2005-09-28" & bverfg$date < "2008-05-08") &
                                     (bverfg$dm2_private == 1 & bverfg$justlandau == 1)) |
                                  ((bverfg$date > "2005-09-28" & bverfg$date < "2008-01-01") &
                                     (bverfg$dm2_victim == 1 & bverfg$justlandau == 1)) |
                                  ((bverfg$date > "2008-05-07" & bverfg$date < "2016-07-21") &
                                     (bverfg$dm2_crim == 1 & bverfg$justlandau == 1)) |
                                  ((bverfg$date > "2011-12-31" & bverfg$date < "2016-07-21") &
                                     (bverfg$dm2_church == 1)), 1, 0)
  bverfg$ref2_vosskuhle <- ifelse(((bverfg$date > "2008-05-07" & bverfg$date < "2010-11-17") &
                                      (bverfg$dm2_disciplinary == 1)) |
                                     ((bverfg$date > "2008-05-07" & bverfg$date < "2010-11-17") &
                                        (bverfg$dm2_private == 1 & bverfg$justvosskuhle == 1)) |
                                     ((bverfg$date > "2008-05-07" & bverfg$date < "2011-11-01") &
                                        (bverfg$dm2_crimenforce == 1 & bverfg$justvosskuhle == 1)) |
                                     ((bverfg$date > "2008-05-07" & bverfg$date < "2020-06-23") &
                                        (bverfg$dm2_publicemployee == 1 | bverfg$dm2_publicservice == 1 |
                                           bverfg$dm2_petitions == 1)) |
                                     ((bverfg$date > "2010-11-16" & bverfg$date < "2020-06-23") &
                                        (bverfg$dm2_clemency == 1 | bverfg$dm2_parliament == 1)) |
                                     ((bverfg$date > "2014-07-15" & bverfg$date < "2020-06-23") &
                                        (bverfg$dm2_military == 1)), 1, 0)
  bverfg$ref2_hermanns <- ifelse(((bverfg$date > "2010-11-16" & bverfg$date < "2011-11-01") &
                                     (bverfg$dm2_pretrial == 1 | bverfg$dm2_reinstatement == 1)) | 
                                    ((bverfg$date > "2010-11-16" & bverfg$date < "2016-01-01") &
                                       (bverfg$dm2_reopening == 1 & bverfg$justhermanns == 1)) |
                                    ((bverfg$date > "2010-11-16" & bverfg$date < "2016-07-11") &
                                       (bverfg$dm2_weapon == 1)) |
                                    ((bverfg$date > "2010-11-16") &
                                       (bverfg$dm2_foreclosure == 1 | bverfg$dm2_insolvency == 1)) |
                                    ((bverfg$date > "2010-11-16") &
                                       (bverfg$dm2_private == 1 & bverfg$justhermanns == 1)) |
                                    ((bverfg$date > "2011-10-31") &
                                       (bverfg$dm2_tax == 1)) |
                                    ((bverfg$date > "2020-12-31") &
                                       (bverfg$dm2_sales == 1)), 1, 0)
  bverfg$ref2_huber <- ifelse(((bverfg$date > "2010-11-16" & bverfg$date < "2011-12-20") &
                                  (bverfg$dm2_condominium == 1 | bverfg$dm2_fgg == 1 |
                                     bverfg$dm2_military == 1)) | 
                                 ((bverfg$date > "2010-11-16" & bverfg$date < "2014-01-01") &
                                    (bverfg$dm2_crimenforce == 1 & bverfg$justhuber == 1)) | 
                                 ((bverfg$date > "2010-11-16") &
                                    (bverfg$dm2_municipalities == 1 & bverfg$justhuber == 1)) |
                                 ((bverfg$date > "2010-11-16") &
                                    (bverfg$dm2_crimeregister == 1)) |
                                 ((bverfg$date > "2010-11-16") &
                                    (bverfg$dm2_private == 1 & bverfg$justhuber == 1)) | 
                                 ((bverfg$date > "2011-12-19") &
                                    (bverfg$dm2_international == 1 | bverfg$dm2_victim == 1)), 1, 0)
  bverfg$ref2_pmueller <- ifelse(((bverfg$date > "2011-12-19" & bverfg$date < "2014-07-16") &
                                     (bverfg$dm2_military == 1 | bverfg$dm2_extradition == 1 |
                                        bverfg$dm2_fgg == 1)) | 
                                    ((bverfg$date > "2011-12-19" & bverfg$date < "2014-07-16") &
                                       (bverfg$dm2_condominium == 1 & bverfg$justpmueller == 1)) | 
                                    ((bverfg$date > "2011-12-19" & bverfg$date < "2016-01-01") &
                                       (bverfg$dm2_prosecution == 1 & bverfg$justpmueller == 1)) |
                                    ((bverfg$date > "2011-10-31" ) &
                                       (bverfg$dm2_crimenforce == 1 & bverfg$justpmueller == 1)) | 
                                    ((bverfg$date > "2011-12-19" ) &
                                       (bverfg$dm2_privateaccusation == 1)) | 
                                    ((bverfg$date > "2014-07-15" ) &
                                       (bverfg$dm2_parties == 1 | bverfg$dm2_elections == 1)) | 
                                    ((bverfg$date > "2015-12-31" ) &
                                       (bverfg$dm2_private == 1 & bverfg$justpmueller == 1)) | 
                                    ((bverfg$date > "2016-07-20" & bverfg$date < "2019-01-01") &
                                       (bverfg$dm2_condominium == 1)) | 
                                    ((bverfg$date > "2016-07-20") &
                                       (bverfg$dm2_church == 1 & bverfg$justpmueller == 1)) | 
                                    (bverfg$date > "2020-06-22" &
                                       ((bverfg$dm2_condominium == 1 & bverfg$justpmueller == 1) |
                                          bverfg$dm2_parliament == 1 & bverfg$justpmueller == 1)), 1, 0)
  bverfg$ref2_kessalwulf <-  ifelse(((bverfg$date > "2011-12-19" & bverfg$date < "2014-06-03") &
                                        (bverfg$dm2_executionsale == 1)) | 
                                       ((bverfg$date > "2011-12-19" & bverfg$date < "2014-07-16") &
                                          (bverfg$dm2_reinstatement == 1)) |
                                       ((bverfg$date > "2011-12-19" & bverfg$date < "2016-07-21") &
                                          (bverfg$dm2_adminoffence == 1 |
                                             (bverfg$dm2_crim == 1 & bverfg$justkessalwulf == 1))) |
                                       ((bverfg$date > "2011-12-19" & bverfg$date < "2016-07-21") &
                                          (bverfg$dm2_reopening == 1 & bverfg$justkessalwulf == 1)) |
                                       ((bverfg$date > "2011-12-19") &
                                          (bverfg$dm2_pretrial == 1)) |
                                       ((bverfg$date > "2014-06-02") &
                                          (bverfg$dm2_budget == 1)) |
                                       ((bverfg$date > "2014-07-15") &
                                          (bverfg$dm2_private == 1 & bverfg$justkessalwulf == 1)) |
                                       (bverfg$date > "2016-07-20" &
                                          bverfg$dm2_crim == 1 & bverfg$justkessalwulf == 1), 1, 0)
  bverfg$ref2_koenig <- ifelse(((bverfg$date > "2014-06-02" & bverfg$date < "2014-07-16") &
                                   (bverfg$dm2_prosecution == 1 & bverfg$justkoenig == 1)) |
                                  ((bverfg$date > "2014-06-02" & bverfg$date < "2020-06-23") &
                                     (bverfg$dm2_displacement == 1 | bverfg$dm2_nationality == 1)) |
                                  ((bverfg$date > "2014-06-02") &
                                     (bverfg$dm2_private == 1 & bverfg$justkoenig == 1)) |
                                  ((bverfg$date > "2014-06-02") &
                                     (bverfg$dm2_detention == 1)) |
                                  ((bverfg$date > "2015-12-31" & bverfg$date < "2020-06-23") &
                                     (bverfg$dm2_fgg == 1)) |
                                  ((bverfg$date > "2016-07-20") &
                                     (bverfg$dm2_extradition == 1)), 1, 0)
  bverfg$ref2_maidowski <- ifelse(((bverfg$date > "2014-07-15" & bverfg$date < "2016-07-21") &
                                      (bverfg$dm2_condominium == 1)) |
                                     ((bverfg$date > "2014-07-15" & bverfg$date < "2020-06-23") &
                                        (bverfg$dm2_foreigner == 1 | bverfg$dm2_training == 1 |
                                           bverfg$dm2_prosecution == 1)) |
                                     ((bverfg$date > "2014-07-15") &
                                        (bverfg$dm2_asylum == 1)) |
                                     ((bverfg$date > "2014-07-15") &
                                        (bverfg$dm2_private == 1 & bverfg$justmaidowski == 1)) |
                                     ((bverfg$date > "2016-07-20" & bverfg$date < "2018-01-01") &
                                        (bverfg$dm2_reinstatement == 1)) |
                                     ((bverfg$date > "2016-07-20") &
                                        (bverfg$dm2_weapon == 1)) |
                                     ((bverfg$date > "2020-06-22") &
                                        (bverfg$dm2_publicemployee == 1)) |
                                     ((bverfg$date > "2020-06-22") &
                                        (bverfg$dm2_condominium == 1 & bverfg$justmaidowski == 1)) |
                                     ((bverfg$date > "2020-06-22") &
                                        (bverfg$dm2_publicservice == 1 & bverfg$justmaidowski == 1)), 1, 0)
  bverfg$ref2_langenfeld <-  ifelse(((bverfg$date > "2016-07-20" & bverfg$date < "2020-06-23") &
                                        (bverfg$dm2_executionsale == 1 | bverfg$dm2_reopening == 1)) |  
                                       ((bverfg$date > "2016-07-20") &
                                          ((bverfg$dm2_crim == 1 & bverfg$justlangenfeld == 1) | bverfg$dm2_adminoffence == 1)) |  
                                       ((bverfg$date > "2017-12-31" & bverfg$date < "2021-01-01") &
                                          (bverfg$dm2_reinstatement == 1 & bverfg$justlangenfeld == 1)) |
                                       ((bverfg$date > "2020-06-22") &
                                          (bverfg$dm2_parliament == 1 & bverfg$justlangenfeld == 1)) |
                                       ((bverfg$date > "2020-06-22") &
                                          (bverfg$dm2_church == 1 & bverfg$justlangenfeld == 1)) |
                                       ((bverfg$date > "2020-06-22") &
                                          (bverfg$dm2_private == 1 & bverfg$justlangenfeld == 1)), 1, 0)
  bverfg$ref2_wallrabenstein <- ifelse(((bverfg$date > "2020-06-22") &
                                           ((bverfg$dm2_military == 1 | bverfg$dm2_foreigner == 1 |
                                               bverfg$dm2_displacement == 1 | bverfg$dm2_nationality == 1 |
                                               bverfg$dm2_executionsale == 1 | bverfg$dm2_fgg == 1 |
                                               bverfg$dm2_petitions == 1 | bverfg$dm2_reopening == 1 |
                                               bverfg$dm2_clemency == 1))) |
                                          ((bverfg$date > "2020-06-22") &
                                             (bverfg$dm2_publicservice == 1 |
                                                bverfg$dm2_private == 1 | bverfg$dm2_reinstatement == 1) & 
                                             bverfg$justwallrabenstein == 1), 1, 0)
  ##### housekeeping
  bverfg$sumref2 <- rowSums(bverfg[, c(grep("ref2_", names(bverfg)))])
  
  
