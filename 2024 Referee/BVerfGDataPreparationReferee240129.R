##### BVerfG
##### Data Preparation
##### Referee
##### 240129

##### HOUSEKEEPING ----
##### load raw data
rm(list = ls())
bverfg <- read.csv("/Users/engel/Documents/word/Manuskript/Governance/BVerfG/Data/2022 Nguyen/case_scraping_Dec_04_2022.csv",
                   stringsAsFactors = FALSE, encoding = "UTF-8")

##### set working directory
setwd("/Users/engel/Documents/word/Manuskript/Governance/BVerfG/Data/2024 Referee/")

##### call libraries
library(lubridate)
library(stringr)
library(dplyr)
library(tidyr)

##### remove datapoints that are pure press-releases, not decisions
bverfg <- subset(bverfg, bverfg$participating_judges != "[]")

##### date
bverfg$date <- parse_date_time(bverfg$decision_date, "dmy",
                               locale = "de_DE.UTF-8")
bverfg$decision_date <- NULL

#### order by date (oldest to newest)
bverfg <- bverfg[order(bverfg$date),]

##### year  
bverfg$year <- format(as.Date(bverfg$date), "%Y")

##### id (by date)
bverfg$id <- 1:nrow(bverfg)
bverfg$bverfg_id_forward <- NULL


##### CASE TYPE ----
  ##### docket number ----
bverfg %>% 
  rename(az = docket_numbers) -> bverfg

#### remove code for space not allowed to break
bverfg %>% 
  mutate(az = str_replace_all(az, fixed("\\xa0"), " ")) -> bverfg

#### remove curly braces
bverfg %>% 
  mutate(az = str_remove_all(az, fixed("{")),
         az = str_remove_all(az, fixed("}"))) -> bverfg

#### manually add missings
bverfg$az[bverfg$id == 385] <- "1 BvL 2/91"
bverfg$az[bverfg$id == 626] <- "2 BvR 301/98"
bverfg$az[bverfg$id == 634] <- "1 BvR 1327/98"
bverfg$az[bverfg$id == 5894] <- "1 BvR 3309/13"
bverfg$az[bverfg$id == 7769] <- "1 BvR 2771/18"

  ##### infer case type ----
bverfg$casecomplaint <- ifelse(str_detect(bverfg$az, "BvR"), 1, 0)
bverfg$caseelect <- ifelse(str_detect(bverfg$az, "BvC"), 1, 0)
bverfg$caseprelim <- ifelse(str_detect(bverfg$az, "BvQ"), 1, 0)

bverfg %>% 
  mutate(casetype = case_when(
    str_detect(bverfg$az, "BvA") ~ "caseabolition",
    str_detect(bverfg$az, "BvB") ~ "casepartyban",
    str_detect(bverfg$az, "BvC") ~ "caseelect",
    str_detect(bverfg$az, "BvD") ~ "casepres",
    str_detect(bverfg$az, "BvE") ~ "casefedconfl",
    str_detect(bverfg$az, "BvF") ~ "caseabsrev",
    str_detect(bverfg$az, "BvG") ~ "casefedlconfl",
    str_detect(bverfg$az, "BvK") ~ "caselconst2",
    str_detect(bverfg$az, "BvL") ~ "caseconcrev",
    str_detect(bverfg$az, "BvM") ~ "casepubint",
    str_detect(bverfg$az, "BvN") ~ "caselconst1",
    str_detect(bverfg$az, "BvO") ~ "casepreconst",
    str_detect(bverfg$az, "BvP") ~ "casedeleg",
    str_detect(bverfg$az, "BvQ") ~ "caseprelim",
    str_detect(bverfg$az, "BvR") ~ "casecomplaint")) -> bverfg

##### add casetype manually 
  ### if az is missing
bverfg$casecomplaint[bverfg$id == 69] <- 1
bverfg$casetype[bverfg$id == 69] <- "casecomplaint"
bverfg$casetype[bverfg$id == 526] <- "caseconcrev"
  ### or not correctly reported
bverfg$casecomplaint[bverfg$id == 260] <- 1
bverfg$casetype[bverfg$id == 260] <- "casecomplaint"
bverfg$casecomplaint[bverfg$id == 3401] <- 1
bverfg$casetype[bverfg$id == 3401] <- "casecomplaint"


##### JUSTICES ----
  ##### data cleaning ----
#### variable name
bverfg %>% 
  rename(judges = participating_judges) -> bverfg

#### correct spelling
bverfg$judges <- tolower(bverfg$judges)
bverfg$judges <- gsub(pattern = '[ä]', replacement = "ae", bverfg$judges)
bverfg$judges <- gsub(pattern = '[ö]', replacement = "oe", bverfg$judges)
bverfg$judges <- gsub(pattern = '[ü]', replacement = "ue", bverfg$judges)
bverfg$judges <- gsub(pattern = '[ß]', replacement = "ss", bverfg$judges)
bverfg$judges <- gsub(pattern = '[-]', replacement = "", bverfg$judges)
bverfg$judges <- gsub(pattern = "di fabio", replacement = "difabio", bverfg$judges)
bverfg$judges <- gsub(pattern = "\"difabio\"", replacement = "difabio", bverfg$judges)
bverfg$judges <- gsub(pattern = "'di\\xa0fabio'", replacement = "difabio", bverfg$judges)
bverfg$judges <- gsub(pattern = "'gerhard'", replacement = "gerhardt", bverfg$judges)
bverfg$judges <- gsub(pattern = "grahof", replacement = "grasshof", bverfg$judges)
bverfg$judges <- gsub(pattern = "khling", replacement = "kuehling", bverfg$judges)
bverfg$judges <- gsub(pattern = "hmig", replacement = "hoemig", bverfg$judges)
bverfg$judges <- gsub(pattern = "hohmann dennhardt", replacement = "hohmanndennhardt", bverfg$judges)
bverfg$judges <- gsub(pattern = "hohmanndennhardtt", replacement = "hohmanndennhardt", bverfg$judges)
bverfg$judges <- gsub(pattern = "'hohmanndennhard'", replacement = "'hohmanndennhardt'", bverfg$judges)
bverfg$judges <- gsub(pattern = "luebbe wolff", replacement = "luebbewolff", bverfg$judges)
bverfg$judges <- gsub(pattern = "luebbewoff", replacement = "luebbewolff", bverfg$judges)
bverfg$judges <- gsub(pattern = "'hasseme'", replacement = "'hassemer'", bverfg$judges)
bverfg$judges <- gsub(pattern = "wallrabensein", replacement = "wallrabenstein", bverfg$judges)
bverfg$judges <- gsub(pattern = "herrmanns", replacement = "hermanns", bverfg$judges)
bverfg$judges <- gsub(pattern = "bro", replacement = "bross", bverfg$judges)  
# unique(bverfg$judges)

#### remove irrelevant entries
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'vizepraesidentseidl\\nistausdemamt\\nausgeschiedenunddeshalb\\nanderunterschrift\\ngehindert.\\ngrimm'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'vizepraesidentseidl\\nistwegenausscheidens\\nausdemamtander\\nunterschriftverhindert.\\ngrimm'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'papier\\nfraubvrinseibert\\nistausdemamt\\nausgeschieden.'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'kuehlingistausdem\\namtgeschiedenunddahergehindert,dieunterschriftzu\\nleisten.\\npapier'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'kuehlingistausdem\\namtgeschiedenunddahergehindertzu\\nunterschreiben.\\npapier'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'praesidentinlimbachistaus\\ndemamtausgeschieden.\\nhassemer'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'brossist\\nanderunterschriftgehindert.\\nhassemer'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'brossistander\\nunterschriftverhindert.'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'brossistan\\nderunterschriftverhindert.'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'brossistander\\nunterschriftgehindert.\\nhassemer'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("frauhaasistgehindert,ihre\\nunterschriftbeizufuegen.\\njaeger'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'die\\njaegeristausdemamtausgeschiedenunddeshalbander\\nunterschriftgehindert.\\n\\npapier'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'dergerhardtistausdemamt\\nausgeschiedenunddeshalbanderunterschriftgehindert\\nvosskuhle'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'derkuehlingistaus\\ndemamtgeschiedenunddahergehindertzu\\nunterschreiben.\\npapier'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'di\\xa0fabioist\\nan\\nderunterschriftverhindert.'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'derkuehlingistausdemamtgeschiedenunddahergehindertzuunterschreibenpapier'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'die\\xa0\\xa0haas\\nist\\xa0aus\\xa0dem\\xa0amt\\xa0ausge\\nschieden\\xa0und\\xa0deshalb\\nan\\xa0der\\xa0unterschrift\\ngehindert.\\npapier'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'diehaasistausdem\\namtausgeschiedenunddeshalbanderunterschrift\\ngehindert.\\npapier'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'dersteineist\\nausgeschiedenunddaherderunterschriftgehindert.\\npapier'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'derhoffmannriemist\\nausdemamtausgeschiedenunddaheranderunterschrift\\ngehindert.\\n\\npapier'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'dermellinghoff\\nistausdemamtaus\\ngeschiedenunddeshalb\\nanderunterschriftgehindert.\\nvosskuhle'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'dieluebbewolffistausdemamt\\nausgeschiedenunddeshalbanderunterschriftgehindert\\nvosskuhle'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("''dergerhardtistausdemamt\\nausgeschiedenunddeshalbanderunterschriftgehindert\\nvosskuhle'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'derhoemigistausdem\\namtausgeschiedenunddeshalbanderunterschrift\\ngehindert\\npapier'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'bundesverfassungsrichter\\nwinteristanderunter\\nschriftverhindert.'"))) -> bverfg

bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'unter'"))) -> bverfg
bverfg %>%
  mutate(judges =
           str_remove(judges, fixed("'mitwirkung'"))) -> bverfg

#### correct values
bverfg %>%
  mutate(judges =
           str_replace_all(judges, fixed("'di\\xa0fabio'"), "'difabio'")) -> bverfg
bverfg %>%
  mutate(judges =
           str_replace(judges, fixed("'papier\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0haas\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0hoffmannriem'"), "'papier', 'haas', 'hoffmannriem'")) -> bverfg
bverfg %>%
  mutate(judges =
           str_replace(judges, fixed("'haas\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0bryde\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0\\xa0eichberger'"), "'haas', 'bryde', 'eichberger'")) -> bverfg

#### empty quotes
bverfg %>% 
  mutate(judges = 
           str_replace_all(judges, fixed("''"), " ")) -> bverfg

#### number of judges on the panel
bverfg$numjudges <- str_count(bverfg$judges, "'")/2

#### irregular number of justices ---
### 2
bverfg[bverfg$numjudges == 2, c("id", "judges")]

### 4 
num_4 <- bverfg$id[bverfg$numjudges == 4]
for (i in num_4) {
  assign(paste0("freq_", i),
         table(unlist(strsplit(bverfg$judges[bverfg$id == i], ' '))))
  print(paste0("freq_", i))
  print(get(unique(paste0("freq_", i))))
}

rm(list = ls(pattern = "^freq_"))
rm(list = ls(pattern = "^num_"))

### 5 
num_5 <- bverfg$id[bverfg$numjudges == 5]
for (i in num_5) {
  assign(paste0("freq_", i),
         table(unlist(strsplit(bverfg$judges[bverfg$id == i], ' '))))
  print(paste0("freq_", i))
  print(get(unique(paste0("freq_", i))))
}

rm(list = ls(pattern = "^freq_"))
rm(list = ls(pattern = "^num_"))

### 6 
num_6 <- bverfg$id[bverfg$numjudges == 6]
for (i in num_6) {
  assign(paste0("freq_", i),
         table(unlist(strsplit(bverfg$judges[bverfg$id == i], ' '))))
  print(paste0("freq_", i))
  print(get(unique(paste0("freq_", i))))
}

bverfg[bverfg$numjudges == 6, c("id", "judges")]

rm(list = ls(pattern = "^freq_"))
rm(list = ls(pattern = "^num_"))

### 7 
num_7 <- bverfg$id[bverfg$numjudges == 7]
for (i in num_7) {
  assign(paste0("freq_", i),
         table(unlist(strsplit(bverfg$judges[bverfg$id == i], ' '))))
  print(paste0("freq_", i))
  print(get(unique(paste0("freq_", i))))
}

bverfg[bverfg$numjudges == 7, c("id", "judges")]

bverfg$judges <- str_remove(bverfg$judges,
                                          fixed("'herrbrossistander\\nunterschriftgehindert.\\nlimbach'"))
bverfg$judges <- str_remove(bverfg$judges,
                                          fixed("'diejaegeristaus\\ndemamtausgeschiedenunddaheranderunterschrift\\ngehindert.\\n\\npapier'"))
bverfg$judges <- str_remove(bverfg$judges,
                                          fixed("'diejaegeristaus\\ndemamtausgeschiedenunddaheranderunterschrift\\ngehindert\\n\\npapier'"))


rm(list = ls(pattern = "^freq_"))
rm(list = ls(pattern = "^num_"))

### 9 
num_9 <- bverfg$id[bverfg$numjudges == 9]
for (i in num_9) {
  assign(paste0("freq_", i),
         table(unlist(strsplit(bverfg$judges[bverfg$id == i], ' '))))
  print(paste0("freq_", i))
  print(get(unique(paste0("freq_", i))))
  bverfg$maxunique9[bverfg$id == i] <- max(get(unique(paste0("freq_", i))))
}

bverfg$judges <- str_remove(bverfg$judges,
                                          fixed("'Bundesverfassungsrichter\\nWinteristanderUnter-\\nschriftverhindert.'"))
bverfg$judges <- str_remove(bverfg$judges,
                                          fixed("'<us>'"))
bverfg$judges <- str_remove(bverfg$judges,
                                          fixed("'DerHömigistausdem\\nAmtausgeschiedenunddeshalbanderUnterschrift\\ngehindert\\nPapier'"))
bverfg$judges <- str_remove(bverfg$judges,
                                          fixed("'.'"))

rm(list = ls(pattern = "^freq_"))
rm(list = ls(pattern = "^num_"))

### 10 
num_10 <- bverfg$id[bverfg$numjudges == 10]
for (i in num_10) {
  assign(paste0("freq_", i),
         table(unlist(strsplit(bverfg$judges[bverfg$id == i], ' '))))
  print(paste0("freq_", i))
  print(get(unique(paste0("freq_", i))))
  bverfg$maxunique10[bverfg$id == i] <- max(get(unique(paste0("freq_", i))))
}

rm(list = ls(pattern = "^freq_"))
rm(list = ls(pattern = "^num_"))

### 11 
num_11 <- bverfg$id[bverfg$numjudges == 11]
for (i in num_11) {
  assign(paste0("freq_", i),
         table(unlist(strsplit(bverfg$judges[bverfg$id == i], ' '))))
  print(paste0("freq_", i))
  print(get(unique(paste0("freq_", i))))
  bverfg$maxunique11[bverfg$id == i] <- max(get(unique(paste0("freq_", i))))
}

bverfg$judges <- str_remove(bverfg$judges,
                                          fixed("'DerGrimmistausdem\\nAmtausgeschiedenunddeshalbanderUnterschrift\\ngehindert.\\nPapier'"))

rm(list = ls(pattern = "^freq_"))
rm(list = ls(pattern = "^num_"))

### larger
num_12 <- bverfg$id[bverfg$numjudges > 11]
for (i in num_12) {
  assign(paste0("freq_", i),
         table(unlist(strsplit(bverfg$judges[bverfg$id == i], ' '))))
  print(paste0("freq_", i))
  print(get(unique(paste0("freq_", i))))
  bverfg$maxunique12[bverfg$id == i] <- max(get(unique(paste0("freq_", i))))
}

bverfg$judges <- str_remove(bverfg$judges,
                                          fixed("'FrauBVRinSeibertistausdemAmtausgeschieden.Papier'"))

rm(list = ls(pattern = "^freq_"))
rm(list = ls(pattern = "^num_"))

  ##### number of judges ----
bverfg$numjudges <- str_count(bverfg$judges, "'")/2

#### correct mistakes in data
bverfg$numjudges[bverfg$numjudges == 7.5] <- 7
bverfg$numjudges[bverfg$id == 3393] <- 3
bverfg$numjudges[bverfg$numjudges == 1] <- 3
bverfg$numjudges[bverfg$id == 5427] <- 6
bverfg$numjudges[bverfg$maxunique9 == 3] <- 7
bverfg$numjudges[bverfg$maxunique9 == 2] <- 8
bverfg$numjudges[bverfg$maxunique10 == 2] <- 8
bverfg$numjudges[bverfg$maxunique11 == 2] <- 8
bverfg$numjudges[bverfg$maxunique12 == 2] <- 8

bverfg$numjudges[(bverfg$id == 514 | bverfg$id == 746 | bverfg$id == 2306 |
                    bverfg$id == 2461 | bverfg$id == 4830 | bverfg$id == 6019 |
                    bverfg$id == 6351 | bverfg$id == 7641)] <- 7
bverfg$numjudges[(bverfg$id == 1914 | bverfg$id == 2099 | bverfg$id == 4698 |
                    bverfg$id == 5100 | bverfg$id == 1426 | bverfg$id == 1097 |
                    bverfg$id == 3766 | bverfg$id == 183  | bverfg$id == 1877 |
                    bverfg$id == 2222 | bverfg$id == 3237 | bverfg$id == 3337 |
                    bverfg$id == 4267 | bverfg$id == 4477 | bverfg$id == 5232 |
                    bverfg$id == 5276 | bverfg$id == 5302 | bverfg$id == 5782 |
                    bverfg$id == 6610 | bverfg$id == 7103 | bverfg$id == 7104 |
                    bverfg$id == 8112 | bverfg$id == 1734 | bverfg$id == 2749 |
                    bverfg$id == 3603 | bverfg$id == 1426 | bverfg$id == 3479 | 
                    bverfg$id == 2306 | bverfg$id == 1097 | bverfg$id == 3766 |
                    bverfg$id == 789  | bverfg$id == 2352)] <- 8

# table(bverfg$numjudges)

#### delete help variables
bverfg %>% 
  select(-(starts_with("maxunique"))) -> bverfg

  ##### disambiguate Kirchhof and Müller ----
bverfg$judges[bverfg$year < 2000] <-
  gsub(pattern = "kirchhof", replacement = "pkirchhof", bverfg$judges[bverfg$year < 2000])
bverfg$judges[bverfg$year > 2006] <-
  gsub(pattern = "kirchhof", replacement = "fkirchhof", bverfg$judges[bverfg$year > 2006])
bverfg$judges[bverfg$year < 1972] <-
  gsub(pattern = "mueller", replacement = "gmueller", bverfg$judges[bverfg$year < 1972])
bverfg$judges[bverfg$year > 2010] <-
  gsub(pattern = "mueller", replacement = "pmueller", bverfg$judges[bverfg$year > 2010])

  ##### dummy variable for each justice ----
#### vector of names
just <- c("baer", "britz", "bross", "bryde", "christ", "difabio", "eichberger", "fkirchhof",
          "gaier", "gerhardt", "grasshof", "grimm", "haas", "haertel", "harbarth",
          "hassemer", "hermanns", "hoemig", "hohmanndennhardt",
          "hoffmannriem", "huber", "jaeger", "jentsch", "kessalwulf",
          "koenig", "kruis", "kuehling", "landau", "langenfeld", 
          "limbach", "luebbewolff", "maidowski", "masing", "mellinghoff",
          "osterloh", "ott", "papier", "paulus", "pkirchhof", "pmueller", "radtke",
          "schluckebier", "seibert", "seidl", "sommer", "steiner",
          "vosskuhle", "wallrabenstein", "winter", "wolff") 

#### initialize variables
bverfg[paste0("just", just)] <- 0

#### assign if justice has been on the bench
for (j in just) bverfg[paste0("just", j)][grepl(j, bverfg$judges),] <- 1

#### disambiguate Luebbewolff and Wolff
bverfg$justluebbewolff[str_detect(bverfg$judges, fixed("'wolff'"))] <- 0
bverfg$justwolff <- ifelse(str_detect(bverfg$judges, fixed("'wolff'")), 1, 0)

# ##### check number of justices on the bench
bverfg$numjudges2 <- rowSums(bverfg[,grep("^just", names(bverfg))])
# table(bverfg$numjudges, bverfg$numjudges2)
# bverfg[bverfg$numjudges == 8 & bverfg$numjudges2 == 7, c("id", "judges")]
# bverfg[bverfg$numjudges == 7 & bverfg$numjudges2 == 8, c("id", "judges")]
# bverfg[bverfg$id == 2308, grepl("just", names(bverfg))]
bverfg$numjudges <- NULL
bverfg$numjudges <- bverfg$numjudges2
bverfg$numjudges2 <- NULL

  ##### gender ----
bverfg$totfemale <- bverfg$justbaer + bverfg$justbritz + bverfg$justgrasshof +
  bverfg$justhaas + bverfg$justhaertel + bverfg$justhermanns + 
  bverfg$justhohmanndennhardt + bverfg$justjaeger + bverfg$justkessalwulf +
  bverfg$justkoenig + bverfg$justlangenfeld + bverfg$justlimbach +
  bverfg$justluebbewolff + bverfg$justosterloh + bverfg$justott +
  bverfg$justseibert + bverfg$justwallrabenstein

bverfg$fem <- bverfg$totfemale / bverfg$numjudges
bverfg$totfemale <- NULL

  ##### tenure ----
#### first date on which a justice has decided
for (j in just) bverfg[paste0("min_", j)] <- 
  min(bverfg$date[bverfg[paste0("just", j)] == 1])
#### number of days justice has been on the bench when deciding the current case
for (j in just) bverfg[paste0("ten_", j)] <-
  as.numeric(difftime(bverfg$date, bverfg[,paste0("min_", j)], units = "days"))
#### replace with NA if justice has not been on the bench
for (j in just) bverfg[,paste0("ten_", j)][bverfg[paste0("just", j)] == 0] <- NA
#### total tenure of all justices on the bench
bverfg$tottenure <- rowSums(bverfg[,grep("^ten_", names(bverfg))], na.rm = TRUE)
#### mean tenure of all justices on the bench
bverfg$tenure <- bverfg$tottenure/bverfg$numjudges
#### remove helpvariables
bverfg %>% 
  select(-c((starts_with("min_")),
            (starts_with("ten_")),
            tottenure)) -> bverfg

# caution: in early years, mechanically lower
# bverfg %>% 
#   group_by(year) %>% 
#   summarise(mten = mean(meantenure)) %>% 
#   ggplot(aes(x = year, y = mten)) +
#   geom_point() +
#   geom_line(group = 1)

  ##### age ----
#### age of individual justices
bverfg$agbaer <- ifelse(bverfg$justbaer == 1, as.numeric(bverfg$year) - 1964, 0)
bverfg$agbritz <- ifelse(bverfg$justbritz == 1, as.numeric(bverfg$year) - 1968, 0)
bverfg$agbross <- ifelse(bverfg$justbross == 1, as.numeric(bverfg$year) - 1946, 0)
bverfg$agbryde <- ifelse(bverfg$justbryde == 1, as.numeric(bverfg$year) - 1943, 0)
bverfg$agchrist <- ifelse(bverfg$justchrist == 1, as.numeric(bverfg$year) - 1956, 0)
bverfg$agdifabio <- ifelse(bverfg$justdifabio == 1, as.numeric(bverfg$year) - 1954, 0)
bverfg$ageichberger <- ifelse(bverfg$justeichberger == 1, as.numeric(bverfg$year) - 1953, 0)
bverfg$aggaier <- ifelse(bverfg$justgaier == 1, as.numeric(bverfg$year) - 1954, 0)
bverfg$aggerhardt <- ifelse(bverfg$justgerhardt == 1, as.numeric(bverfg$year) - 1954, 0)
bverfg$aggrasshof <- ifelse(bverfg$justgrasshof == 1, as.numeric(bverfg$year) - 1937, 0)
bverfg$aggrimm <- ifelse(bverfg$justgrimm == 1, as.numeric(bverfg$year) - 1937, 0)
bverfg$aghaas <- ifelse(bverfg$justhaas == 1, as.numeric(bverfg$year) - 1949, 0)
bverfg$agharbarth <- ifelse(bverfg$justharbarth == 1, as.numeric(bverfg$year) - 1971, 0)
bverfg$aghaertel <- ifelse(bverfg$justhaertel == 1, as.numeric(bverfg$year) - 1972, 0)
bverfg$aghassemer <- ifelse(bverfg$justhassemer == 1, as.numeric(bverfg$year) - 1940, 0)
bverfg$aghermanns <- ifelse(bverfg$justhermanns == 1, as.numeric(bverfg$year) - 1959, 0)
bverfg$aghoemig <- ifelse(bverfg$justhoemig == 1, as.numeric(bverfg$year) - 1938, 0)
bverfg$aghohmanndennhardt <- ifelse(bverfg$justhohmanndennhardt == 1, as.numeric(bverfg$year) - 1950, 0)
bverfg$aghoffmannriem <- ifelse(bverfg$justhoffmannriem == 1, as.numeric(bverfg$year) - 1940, 0)
bverfg$aghuber <- ifelse(bverfg$justhuber == 1, as.numeric(bverfg$year) - 1959, 0)
bverfg$agjaeger <- ifelse(bverfg$justjaeger == 1, as.numeric(bverfg$year) - 1940, 0)
bverfg$agjentsch <- ifelse(bverfg$justjentsch == 1, as.numeric(bverfg$year) - 1937, 0)
bverfg$agkessalwulf <- ifelse(bverfg$justkessalwulf == 1, as.numeric(bverfg$year) - 1958, 0)
bverfg$agfkirchhof <- ifelse(bverfg$justfkirchhof == 1, as.numeric(bverfg$year) - 1950, 0)
bverfg$agpkirchhof <- ifelse(bverfg$justpkirchhof == 1, as.numeric(bverfg$year) - 1943, 0)
bverfg$agkoenig <- ifelse(bverfg$justkoenig == 1, as.numeric(bverfg$year) - 1957, 0)
bverfg$agkruis <- ifelse(bverfg$justkruis == 1, as.numeric(bverfg$year) - 1930, 0)
bverfg$agkuehling <- ifelse(bverfg$justkuehling == 1, as.numeric(bverfg$year) - 1934, 0)
bverfg$aglangenfeld <- ifelse(bverfg$justlangenfeld == 1, as.numeric(bverfg$year) - 1962, 0)
bverfg$aglandau <- ifelse(bverfg$justlandau == 1, as.numeric(bverfg$year) - 1948, 0)
bverfg$aglimbach <- ifelse(bverfg$justlimbach == 1, as.numeric(bverfg$year) - 1934, 0)
bverfg$agluebbewolff <- ifelse(bverfg$justluebbewolff == 1, as.numeric(bverfg$year) - 1953, 0)
bverfg$agmaidowski <- ifelse(bverfg$justmaidowski == 1, as.numeric(bverfg$year) - 1958, 0)
bverfg$agmasing <- ifelse(bverfg$justmasing == 1, as.numeric(bverfg$year) - 1959, 0)
bverfg$agmellinghoff <- ifelse(bverfg$justmellinghoff == 1, as.numeric(bverfg$year) - 1954, 0)
bverfg$agpmueller <- ifelse(bverfg$justpmueller == 1, as.numeric(bverfg$year) - 1955, 0)
bverfg$agosterloh <- ifelse(bverfg$justosterloh == 1, as.numeric(bverfg$year) - 1944, 0)
bverfg$agott <- ifelse(bverfg$justott == 1, as.numeric(bverfg$year) - 1963, 0)
bverfg$agpapier <- ifelse(bverfg$justpapier == 1, as.numeric(bverfg$year) - 1943, 0)
bverfg$agpaulus <- ifelse(bverfg$justpaulus == 1, as.numeric(bverfg$year) - 1968, 0)
bverfg$agradtke <- ifelse(bverfg$justradtke == 1, as.numeric(bverfg$year) - 1962, 0)
bverfg$agschluckebier <- ifelse(bverfg$justschluckebier == 1, as.numeric(bverfg$year) - 1949, 0)
bverfg$agseibert <- ifelse(bverfg$justseibert == 1, as.numeric(bverfg$year) - 1939, 0)
bverfg$agseidl <- ifelse(bverfg$justseidl == 1, as.numeric(bverfg$year) - 1931, 0)
bverfg$agsommer <- ifelse(bverfg$justsommer == 1, as.numeric(bverfg$year) - 1937, 0)
bverfg$agsteiner <- ifelse(bverfg$juststeiner == 1, as.numeric(bverfg$year) - 1939, 0)
bverfg$agvosskuhle <- ifelse(bverfg$justvosskuhle == 1, as.numeric(bverfg$year) - 1963, 0)
bverfg$agwallrabenstein <- ifelse(bverfg$justwallrabenstein == 1, as.numeric(bverfg$year) - 1969, 0)
bverfg$agwinter <- ifelse(bverfg$justwinter == 1, as.numeric(bverfg$year) - 1936, 0)
bverfg$agwolff <- ifelse(bverfg$justwolff == 1, as.numeric(bverfg$year) - 1965, 0)

#### aggregate
bverfg$totage <- rowSums(bverfg[,grep("^ag", names(bverfg))])

#### remove helpvariables
bverfg %>% 
  select(-(starts_with("ag")),
         totage) -> bverfg

bverfg$age <- bverfg$totage / bverfg$numjudges

  ##### nominating political party ----
bverfg$totcdu <- bverfg$justbross + bverfg$justchrist + bverfg$justdifabio + 
  bverfg$justeichberger + bverfg$justhaas + bverfg$justharbarth + bverfg$justhuber +
  bverfg$justjentsch + bverfg$justkessalwulf + bverfg$justfkirchhof + bverfg$justpkirchhof +
  bverfg$justkruis + bverfg$justlandau + bverfg$justlangenfeld + bverfg$justmellinghoff +
  bverfg$justpmueller + bverfg$justpapier + bverfg$justradtke + bverfg$justschluckebier +
  bverfg$justseidl + bverfg$juststeiner + bverfg$justwinter

bverfg$totspd <- bverfg$justbritz + bverfg$justgaier + bverfg$justgerhardt +
  bverfg$justgrasshof + bverfg$justgrimm + bverfg$justhaertel + bverfg$justhassemer +
  bverfg$justhermanns + bverfg$justhohmanndennhardt + bverfg$justhoffmannriem +
  bverfg$justjaeger + bverfg$justkoenig + bverfg$justkuehling + bverfg$justlimbach +
  bverfg$justluebbewolff + bverfg$justmaidowski + bverfg$justmasing + bverfg$justosterloh +
  bverfg$justott + bverfg$justseibert + bverfg$justsommer + bverfg$justvosskuhle

bverfg$totgreen <- bverfg$justbaer + bverfg$justbryde + bverfg$justwallrabenstein
bverfg$totfdp <- bverfg$justhoemig + bverfg$justpaulus + bverfg$justwolff

bverfg$totright <- bverfg$totcdu + bverfg$totfdp
bverfg$totleft <- bverfg$totspd + bverfg$totgreen

bverfg$cdu = bverfg$totcdu/bverfg$numjudges
bverfg$spd = bverfg$totspd/bverfg$numjudges
bverfg$fdp = bverfg$totfdp/bverfg$numjudges
bverfg$green = bverfg$totgreen/bverfg$numjudges
bverfg$right = bverfg$totright/bverfg$numjudges
bverfg$left = bverfg$totleft/bverfg$numjudges

##### BODY ----
table(bverfg$numjudges)

bverfg %>% 
  mutate(body = case_when(
    numjudges < 4 ~ "chamber",
    numjudges > 3 & numjudges < 15 ~ "senate",
    str_detect(bverfg$senate_and_chamber, "Plenum") ~ "plenary")) -> bverfg
bverfg$body[str_detect(bverfg$senate_and_chamber,
                       "Beschwerdekammer")] <- "complaint"

##### senate
bverfg %>% 
  mutate(senate = case_when(
    str_detect(bverfg$senate_and_chamber, "1. Senat") ~ "1",
    str_detect(bverfg$senate_and_chamber, "2. Senat") ~ "2")) -> bverfg

#### add missing information from az
# bverfg[is.na(bverfg$senate), c("id", "az")]
bverfg$senate[bverfg$id == 2053] <- 1
bverfg$senate[bverfg$id == 4911] <- 2
bverfg$senate[bverfg$id == 5078] <- 1
bverfg$senate[bverfg$id == 5153] <- 2
bverfg$senate[bverfg$id == 5661] <- 1
bverfg$senate[bverfg$id == 5773] <- 1
bverfg$senate[bverfg$id == 6070] <- 2
bverfg$senate[bverfg$id == 6358] <- 1
bverfg$senate[bverfg$id == 6607] <- 2
bverfg$senate[bverfg$id == 7601] <- 1
bverfg$senate[bverfg$id == 7602] <- 1
# sum(is.na(bverfg$senate))

#### correct wrongly defined senate
bverfg$senate_fromaz <- gsub(pattern = "[^\\d]*([0-9]).*",
  replacement = "\\1", x = bverfg$az, perl = TRUE)

table(bverfg$senate, bverfg$senate_fromaz)
bverfg$senate <- bverfg$senate_fromaz
bverfg$senate_fromaz <- NULL


##### SEPARATE HEADER ----
# if there is black letter law, it comes first
bverfg$blackletter <- substr(bverfg$full_text, 1, 
                             regexpr("BUNDESVERFASSUNGSGERICHT",
                                     bverfg$full_text) - 1)
# occasionally, the court does not use capital letters for its name
bverfg$blackletter2 <- ifelse((str_detect(bverfg$full_text,
                                          "^L e i t s a t z") |
                                 str_detect(bverfg$full_text,
                                            "^L e i t s ä t z e") |
                                 str_detect(bverfg$full_text,
                                            "^Leitsatz") |
                                 str_detect(bverfg$full_text,
                                            "Leitsätze")) &
                                bverfg$blackletter == "",
                              substr(bverfg$full_text, 1, 
                                     regexpr("Bundesverfassungsgericht",
                                             bverfg$full_text) - 1), "")
bverfg$blackletter <- ifelse(bverfg$blackletter == "" 
                             & bverfg$blackletter2 != "", 
                             bverfg$blackletter2, bverfg$blackletter)
# remove (usually multiple) linebreaks
bverfg$blackletter <- str_remove_all(bverfg$blackletter, "\n")
# remove extra spaces
bverfg$blackletter <- str_replace_all(bverfg$blackletter, regex("\\s+"), " ")
# dummy if there is black letter law
bverfg$dumblackletter <- ifelse(bverfg$blackletter != "", 1, 0)

# if there is black letter law, it may contain the keyword "Gründe"
# which is why only the text thereafter may be used
bverfg$header <- sub(pattern = ".*?BUNDESVERFASSUNGSGERICHT", 
                     replacement = "",
                     ignore.case = FALSE, 
                     bverfg$full_text)
bverfg$header <- ifelse(bverfg$blackletter2 != "",
                        sub(pattern = ".*?Bundesverfassungsgericht", 
                            replacement = "",
                            ignore.case = FALSE, 
                            bverfg$full_text),
                        bverfg$header)

# remove (usually multiple) linebreaks
bverfg$header <- str_remove_all(bverfg$header, "\n")
# remove extra spaces
bverfg$header <- str_replace_all(bverfg$header, regex("\\s+"), " ")

# only keep text until term "Gründe:", which starts the operative part
bverfg$header <- ifelse(str_detect(bverfg$header, "Gründe:"), 
                        substr(bverfg$header, 1, regexpr("Gründe:",
                                                         bverfg$header) - 1),
                        bverfg$header)
# correct typos
bverfg$header <- ifelse(str_detect(bverfg$header, "Grnde:"), 
                        substr(bverfg$header, 1, regexpr("Grnde:",
                                                         bverfg$header) - 1),
                        bverfg$header)
bverfg$header <- ifelse(str_detect(bverfg$header, "G r ü n d e:"), 
                        substr(bverfg$header, 1, regexpr("G r ü n d e:",
                                                         bverfg$header) - 1),
                        bverfg$header)
bverfg$header <- ifelse(str_detect(bverfg$header, "G r ü n d e :"), 
                        substr(bverfg$header, 1, regexpr("G r ü n d e :",
                                                         bverfg$header) - 1),
                        bverfg$header)
bverfg$header <- ifelse(str_detect(bverfg$header, "H i n w e i s:"), 
                        substr(bverfg$header, 1, regexpr("H i n w e i s:",
                                                         bverfg$header) - 1),
                        bverfg$header)
bverfg$header <- ifelse(str_detect(bverfg$header, "Inhaltsverzeichnis"), 
                        substr(bverfg$header, 1, regexpr("Inhaltsverzeichnis",
                                                         bverfg$header) - 1),
                        bverfg$header)

# #### check
# bverfg$header_nchar <- nchar(bverfg$header)
# bverfg$id[bverfg$header_nchar > 4000]

# fix unorthodox cases
bverfg$header[bverfg$id == 254] <- paste0(substr(bverfg$header[bverfg$id == 254], 1,
                                                 regexpr("vermögensteuerpflichtig waren",
                                                         bverfg$header[bverfg$id == 254]) - 1),
                                          "vermögensteuerpflichtig waren")
bverfg$header[bverfg$id == 1470] <- paste0(substr(bverfg$header[bverfg$id == 1470], 1,
                                                  regexpr("Der Antrag wird zurückgewiesen.",
                                                          bverfg$header[bverfg$id == 1470]) - 1),
                                           "Der Antrag wird zurückgewiesen.")
bverfg$header[bverfg$id == 2732] <- paste0(substr(bverfg$header[bverfg$id == 2732], 1,
                                                  regexpr("Auslagen zu 3/4 zu erstatten.",
                                                          bverfg$header[bverfg$id == 2732]) - 1),
                                           "Auslagen zu 3/4 zu erstatten.")
bverfg$header[bverfg$id == 3924] <- paste0(substr(bverfg$full_text[bverfg$id == 3924], 1,
                                                  regexpr("Im Übrigen werden die Anträge",
                                                          bverfg$full_text[bverfg$id == 3924]) - 1),
                                           "Im Übrigen werden die Anträge verworfen")
bverfg$header[bverfg$id == 5078] <- paste0(substr(bverfg$header[bverfg$id == 5078], 1,
                                                  regexpr("Die Verzögerungsbeschwerde wird als unzulässig verworfen.",
                                                          bverfg$header[bverfg$id == 5078]) - 1),
                                           "Die Verzögerungsbeschwerde wird als unzulässig verworfen.")
bverfg$header[bverfg$id == 5153] <- paste0(substr(bverfg$header[bverfg$id == 5153], 1,
                                                  regexpr("werden als unzulässig verworfen.",
                                                          bverfg$header[bverfg$id == 5153]) - 1),
                                           "werden als unzulässig verworfen.")
bverfg$header[bverfg$id == 5244] <- paste0(substr(bverfg$header[bverfg$id == 5244], 1,
                                                  regexpr("festgesetzt. A",
                                                          bverfg$header[bverfg$id == 5244]) - 1),
                                           "festgesetzt.")
bverfg$header[bverfg$id == 5439] <- paste0(substr(bverfg$header[bverfg$id == 5439], 1,
                                                  regexpr("Mittelschulen betrifft.",
                                                          bverfg$header[bverfg$id == 5439]) - 1),
                                           "Mittelschulen betrifft.")
bverfg$header[bverfg$id == 5466] <- paste0(substr(bverfg$header[bverfg$id == 5466], 1,
                                                  regexpr("Anordnung. I",
                                                          bverfg$header[bverfg$id == 5466]) - 1),
                                           "Anordnung.")
bverfg$header[bverfg$id == 5513] <- paste0(substr(bverfg$header[bverfg$id == 5513], 1,
                                                  regexpr("vorgelegt hat. II.",
                                                          bverfg$header[bverfg$id == 5513]) - 1),
                                           "vorgelegt hat.")
bverfg$header[bverfg$id == 7679] <- substr(bverfg$header[bverfg$id == 7679], 1,
                                           regexpr("Gliederung",
                                                   bverfg$header[bverfg$id == 7679]) - 1)
bverfg$header[bverfg$id == 8022] <- substr(bverfg$header[bverfg$id == 8022], 1,
                                           regexpr("G r ü n d e",
                                                   bverfg$header[bverfg$id == 8022]) - 1)
bverfg$header[bverfg$id == 8135] <- paste0(substr(bverfg$header[bverfg$id == 8135], 1,
                                                  regexpr("Der Antrag auf Erlass einer einstweiligen Anordnung wird verworfen",
                                                          bverfg$header[bverfg$id == 8135]) - 1),
                                           "Der Antrag auf Erlass einer einstweiligen Anordnung wird verworfen.")

# bverfg$header[bverfg$id == 6156] <- substr(bverfg$header[bverfg$id == 6156], 1, 
#                                                   regexpr("Inhaltsverzeichnis",
#                                                           bverfg$header[bverfg$id == 6156]) - 1)
# bverfg$header[bverfg$id == 6208] <- substr(bverfg$header[bverfg$id == 6208], 1, 
#                                            regexpr("Inhaltsverzeichnis",
#                                                    bverfg$header[bverfg$id == 6208]) - 1)
# bverfg$header[bverfg$id == 6502] <- substr(bverfg$header[bverfg$id == 6502], 1, 
#                                            regexpr("Inhaltsverzeichnis",
#                                                    bverfg$header[bverfg$id == 6502]) - 1)
# bverfg$header[bverfg$id == 6976] <- substr(bverfg$header[bverfg$id == 6976], 1, 
#                                            regexpr("Inhaltsverzeichnis",
#                                                    bverfg$header[bverfg$id == 6976]) - 1)
# bverfg$header[bverfg$id == 7163] <- substr(bverfg$header[bverfg$id == 7163], 1, 
#                                            regexpr("Inhaltsverzeichnis",
#                                                    bverfg$header[bverfg$id == 7163]) - 1)
# bverfg$header[bverfg$id == 7260] <- substr(bverfg$header[bverfg$id == 7260], 1, 
#                                            regexpr("Inhaltsverzeichnis",
#                                                    bverfg$header[bverfg$id == 7260]) - 1)
# bverfg$header[bverfg$id == 7288] <- substr(bverfg$header[bverfg$id == 7288], 1, 
#                                            regexpr("Inhaltsverzeichnis",
#                                                    bverfg$header[bverfg$id == 7288]) - 1)
# bverfg$header[bverfg$id == 8068] <- substr(bverfg$header[bverfg$id == 8068], 1, 
#                                            regexpr("Inhaltsverzeichnis",
#                                                    bverfg$header[bverfg$id == 8068]) - 1)



# remove helpfile
bverfg$blackletter2 <- NULL

##### PROCEDURE ----
##### preliminary injunction
bverfg$prelim <- ifelse(bverfg$casetype == "caseprelim", 1, 0)

##### oral hearing
bverfg$oral <- ifelse(str_detect(bverfg$header,
                                 "mündlich"), 1, 0)

##### separate opinion
#### dummy
bverfg$dumsepopinion <- ifelse(bverfg$body == "senate" &
                                 str_detect(bverfg$full_text,
                                            "Abweichende Meinung"), 1, 0)

#### text
bverfg %>% 
  filter(dumsepopinion == 1) %>% 
  select(id, full_text) %>% 
  mutate(sepopinion = str_extract(full_text,
                                  regex("Abweichende[\\S\\s]+$"))) -> hbverfg
bverfg <- left_join(bverfg, hbverfg) 
rm(hbverfg)

##### unanimous
bverfg$unanimous <- ifelse(bverfg$body == "senate" 
                           & str_detect(bverfg$full_text,
                                        regex("(mit\\s+).:.(\\s+Stimmen)")), 0, 1)
bverfg$unanimous <- ifelse(bverfg$body == "senate" 
                           & str_detect(bverfg$full_text,
                                        regex("(mit\\s+)(.\\s+:\\s+.)(\\s+Stimmen)")), 0, 
                           bverfg$unanimous)
bverfg$unanimous <- ifelse(bverfg$dumsepopinion == 1, 0, bverfg$unanimous)

##### LENGTH ----
  ##### number of paragraphs ----
#### temporarily remove obs with no alineas
bverfg$hasnumber <- ifelse(str_detect(bverfg$full_text,
                                      regex("(\\n\\n\\n[0-9]+)")), 1, 0)
table(bverfg$hasnumber)
#### temporarily remove long obs with a single (named) alinea
long <- c(1885, 1891, 2640, 3554, 4742, 4849, 4940, 4945, 5234,
          6109, 6605, 7179, 8019, 8049)
# handle cases with separate opinion separately
hbverfg <- bverfg[bverfg$hasnumber == 1 & bverfg$dumsepopinion == 0,]
hbverfg <- hbverfg[!(hbverfg$id %in% long),]
#### count of obs to which function can be applied
hbverfg$hid <- 1:nrow(hbverfg)

#### reduce text length
# so that function must not go over all individual numbers
hbverfg$short_text <- str_sub(hbverfg$full_text, start = -2500)

#### write function
funlength <- function (c) {
  text <- hbverfg[hbverfg$hid == c, c("short_text")]
  text1 <- str_extract_all(text,
                           regex("(\\n\\n\\n[0-9]+)"))
  text2 <- unlist(text1)
  text3 <- text2[length(text2)]
  text4 <- str_extract(text3,
                       regex("[0-9]+"))
  hbverfg$length[hbverfg$hid == c] <<- text4
}

#### run function
sapply(1:nrow(hbverfg), funlength)
hbverfg$length <- as.numeric(hbverfg$length)

#### check for outliers
table(hbverfg$length)
# is postcode
hbverfg$length[hbverfg$length == 20146] <- 1

#### export to main dataframe
hbverfg %>% 
  select(id, length) -> explength
bverfg <- left_join(bverfg, explength)

#### add length to cases with unorthodox concluding paragraphs
bverfg$length[bverfg$id == 1885] <- 192
bverfg$length[bverfg$id == 1891] <- 6
bverfg$length[bverfg$id == 2640] <- 98
bverfg$length[bverfg$id == 3554] <- 92
bverfg$length[bverfg$id == 4742] <- 10
bverfg$length[bverfg$id == 4849] <- 57
bverfg$length[bverfg$id == 4940] <- 34
bverfg$length[bverfg$id == 4945] <- 214
bverfg$length[bverfg$id == 5234] <- 1
bverfg$length[bverfg$id == 6109] <- 1
bverfg$length[bverfg$id == 6605] <- 14
bverfg$length[bverfg$id == 7179] <- 109
bverfg$length[bverfg$id == 8019] <- 1
bverfg$length[bverfg$id == 8049] <- 11

#### define length = 1 if ruling does not have alinea
bverfg$length[bverfg$hasnumber == 0] <- 1

#### check cases with separate opinion
bverfg$length[bverfg$id == 183] <- 188
bverfg$length[bverfg$id == 279] <- 240
bverfg$length[bverfg$id == 1097] <- 89
bverfg$length[bverfg$id == 1304] <- 31
bverfg$length[bverfg$id == 1426] <- 69
bverfg$length[bverfg$id == 1584] <- 95
bverfg$length[bverfg$id == 1618] <- 117
bverfg$length[bverfg$id == 1734] <- 124
bverfg$length[bverfg$id == 1877] <- 86
bverfg$length[bverfg$id == 1914] <- 153
bverfg$length[bverfg$id == 2099] <- 60
bverfg$length[bverfg$id == 2145] <- 74
bverfg$length[bverfg$id == 2262] <- 19
bverfg$length[bverfg$id == 2263] <- 21
bverfg$length[bverfg$id == 2280] <- 189
bverfg$length[bverfg$id == 2308] <- 354
bverfg$length[bverfg$id == 2387] <- 22
bverfg$length[bverfg$id == 2417] <- 244
bverfg$length[bverfg$id == 2458] <- 153
bverfg$length[bverfg$id == 2514] <- 150
bverfg$length[bverfg$id == 2543] <- 86
bverfg$length[bverfg$id == 2721] <- 131
bverfg$length[bverfg$id == 2749] <- 186
bverfg$length[bverfg$id == 2766] <- 249
bverfg$length[bverfg$id == 2806] <- 52
bverfg$length[bverfg$id == 2899] <- 143
bverfg$length[bverfg$id == 2919] <- 166
bverfg$length[bverfg$id == 3175] <- 105
bverfg$length[bverfg$id == 3206] <- 68
bverfg$length[bverfg$id == 3237] <- 166
bverfg$length[bverfg$id == 3273] <- 109
bverfg$length[bverfg$id == 3308] <- 160
bverfg$length[bverfg$id == 3333] <- 213
bverfg$length[bverfg$id == 3337] <- 107
bverfg$length[bverfg$id == 3391] <- 211
bverfg$length[bverfg$id == 3479] <- 73
bverfg$length[bverfg$id == 3603] <- 171
bverfg$length[bverfg$id == 3766] <- 94
bverfg$length[bverfg$id == 4167] <- 309
bverfg$length[bverfg$id == 4267] <- 93
bverfg$length[bverfg$id == 4477] <- 110
bverfg$length[bverfg$id == 4698] <- 146
bverfg$length[bverfg$id == 4782] <- 188
bverfg$length[bverfg$id == 4912] <- 58
bverfg$length[bverfg$id == 5100] <- 115
bverfg$length[bverfg$id == 5132] <- 143
bverfg$length[bverfg$id == 5232] <- 84
bverfg$length[bverfg$id == 5245] <- 220
bverfg$length[bverfg$id == 5276] <- 86
bverfg$length[bverfg$id == 5302] <- 114
bverfg$length[bverfg$id == 5321] <- 78
bverfg$length[bverfg$id == 5462] <- 294
bverfg$length[bverfg$id == 5478] <- 64
bverfg$length[bverfg$id == 5488] <- 159
bverfg$length[bverfg$id == 5606] <- 150
bverfg$length[bverfg$id == 5782] <- 103
bverfg$length[bverfg$id == 5898] <- 360
bverfg$length[bverfg$id == 5970] <- 39
bverfg$length[bverfg$id == 6302] <- 162
bverfg$length[bverfg$id == 6382] <- 221
bverfg$length[bverfg$id == 6610] <- 157
bverfg$length[bverfg$id == 7103] <- 122
bverfg$length[bverfg$id == 7104] <- 101
bverfg$length[bverfg$id == 7146] <- 168
bverfg$length[bverfg$id == 7592] <- 137
bverfg$length[bverfg$id == 8112] <- 190

rm(hbverfg)

  ##### number of characters ----
bverfg$all_nchar <- nchar(bverfg$full_text)
bverfg$header_nchar <- nchar(bverfg$header)
bverfg$sep_nchar <- nchar(bverfg$sepopinion)
bverfg$nchar <- ifelse(!is.na(bverfg$sep_nchar), 
                       bverfg$all_nchar - bverfg$header_nchar - bverfg$sep_nchar,
                       bverfg$all_nchar - bverfg$header_nchar)

##### DECISION ----
#### certoriari ("Nichtannahme")
# names(sort(table(bverfg$header), decreasing = TRUE))[1:50]
bverfg$deccert <- ifelse(grepl("nicht zur Entscheidung angenommen",
                               as.character(bverfg$header)), 1, 0)
bverfg$deccert <- ifelse(grepl("nicht zur Entscheidung angnommen",
                               as.character(bverfg$header)), 1, bverfg$deccert)
bverfg$deccert <- ifelse(grepl("nicht zur Entscheidung\nangenommen",
                               as.character(bverfg$header)), 1, bverfg$deccert)
bverfg$deccert <- ifelse(grepl("nicht zur\nEntscheidung angenommen",
                               as.character(bverfg$header)), 1, bverfg$deccert)
bverfg$deccert <- ifelse(grepl("nicht\nzur Entscheidung angenommen",
                               as.character(bverfg$header)), 1, bverfg$deccert)

#### certiorari Art. 100 I GG
bverfg$dec100cert <- ifelse(grepl("Die Vorlage ist unzulässig",
                                  as.character(bverfg$header)), 1, 0)
bverfg$dec100cert <- ifelse(grepl("Vorlagen sind unzulässig",
                                  as.character(bverfg$header)), 1, bverfg$dec100cert)

#### certiorari in other procedures
bverfg$decothcert <- ifelse(grepl("unzulässig",
                                  as.character(bverfg$header)) &
                              bverfg$casetype != "casecomplaint" &
                              bverfg$casetype != "caseconcrev", 1, 0)

#### discontinuation
bverfg$decdisc <- ifelse(grepl("wird eingestellt",
                               as.character(bverfg$header)), 1, 0)
bverfg$decdisc <- ifelse(grepl("werden eingestellt",
                               as.character(bverfg$header)), 1, bverfg$decdisc)
bverfg$decdisc <- ifelse(grepl("Die Wahlprüfungsbeschwerde hat sich erledigt",
                               as.character(bverfg$header)), 1, bverfg$decdisc)
bverfg$decdisc <- ifelse(grepl("hat sich durch den Tod des Beschwerdeführers erledigt",
                               as.character(bverfg$header)), 1, bverfg$decdisc)
bverfg$decdisc <- ifelse(grepl("hat sich durch den Tod der Beschwerdeführerin erledigt",
                               as.character(bverfg$header)), 1, bverfg$decdisc)
bverfg$decdisc <- ifelse(grepl("durch ihren Tod erledigt",
                               as.character(bverfg$header)), 1, bverfg$decdisc)
bverfg$decdisc <- ifelse(grepl("gegenstandslos geworden",
                               as.character(bverfg$header)), 1, bverfg$decdisc)
bverfg$decdisc <- ifelse(grepl("Die Verfahren",
                               as.character(bverfg$header)) &
                           grepl("erledigt",
                                 as.character(bverfg$header)), 1, bverfg$decdisc)

#### no preliminary injunction
bverfg$decnoprelim <- ifelse(grepl("Der Antrag auf Erlass einer einstweiligen Anordnung wird abgelehnt",
                                   as.character(bverfg$header)), 1, 0)
bverfg$decnoprelim <- ifelse(grepl("Der Antrag auf Erlaß einer einstweiligen Anordnung wird abgelehnt",
                                   as.character(bverfg$header)), 1, bverfg$decnoprelim)
bverfg$decnoprelim <- ifelse(grepl("Der Antrag auf Erlaß einer einstweiligen Anordnung wird zurückgewiesen",
                                   as.character(bverfg$header)), 1, bverfg$decnoprelim)
bverfg$decnoprelim <- ifelse(grepl("Der Antrag auf Erlass einer einstweiligen Anordnung wird als unzulässig verworfen",
                                   as.character(bverfg$header)), 1, bverfg$decnoprelim)
bverfg$decnoprelim <- ifelse(grepl("Die Anträge auf Erlass einer einstweiligen Anordnung werden abgelehnt",
                                   as.character(bverfg$header)), 1, bverfg$decnoprelim)
bverfg$decnoprelim <- ifelse(grepl("Die Anträge auf Erlass einer einstweiligen Anordnung werden verworfen",
                                   as.character(bverfg$header)), 1, bverfg$decnoprelim)
bverfg$decnoprelim <- ifelse(grepl("Der Antrag auf Erlass einer einstweiligen Anordnung wird zurückgewiesen",
                                   as.character(bverfg$header)), 1, bverfg$decnoprelim)
bverfg$decnoprelim <- ifelse(grepl("Die Anträge auf Erlaß einer einstweiligen Anordnung werden abgelehnt",
                                   as.character(bverfg$header)), 1, bverfg$decnoprelim)
bverfg$decnoprelim <- ifelse(grepl("Die Anträge auf Erlass einstweiliger Anordnungen werden abgelehnt",
                                   as.character(bverfg$header)), 1, bverfg$decnoprelim)
bverfg$decnoprelim <- ifelse(grepl("Die Anträge auf Erlaß einstweiliger Anordnungen werden abgelehnt",
                                   as.character(bverfg$header)), 1, bverfg$decnoprelim)
bverfg$decnoprelim <- ifelse(grepl("erledigt sich der Antrag auf Erlass einer einstweiligen Anordnung",
                                   as.character(bverfg$header)), 1, bverfg$decnoprelim)
bverfg$decnoprelim <- ifelse(grepl("Der Antrag auf Erlass einer einstweiligen Anordnung ",
                                   as.character(bverfg$header)) &
                               grepl("wird abgelehnt",
                                     as.character(bverfg$header)), 1, bverfg$decnoprelim)
bverfg$decnoprelim <- ifelse(grepl("Der Antrag auf Erlass einer einstweiligen Anordnung ",
                                   as.character(bverfg$header)) &
                               grepl("wird \nabgelehnt",
                                     as.character(bverfg$header)), 1, bverfg$decnoprelim)
bverfg$decnoprelim <- ifelse(grepl("Der Antrag auf Erlaß einer einstweiligen Anordnung ",
                                   as.character(bverfg$header)) &
                               grepl("wird abgelehnt",
                                     as.character(bverfg$header)), 1, bverfg$decnoprelim)
bverfg$decnoprelim <- ifelse(grepl("Der Antrag auf Erlass einer einstweiligen Anordnung ",
                                   as.character(bverfg$header)) &
                               grepl("ist gegenstandslos",
                                     as.character(bverfg$header)), 1, bverfg$decnoprelim)
bverfg$decnoprelim <- ifelse(grepl("Die Anträge auf Erlass einer einstweiligen Anordnung werden zurückgewiesen",
                                   as.character(bverfg$header)), 1, bverfg$decnoprelim)
bverfg$decnoprelim <- ifelse(grepl("Der Antrag auf Erlass einer einstweiligen Anordnung ",
                                   as.character(bverfg$header)) &
                               grepl("erledigt",
                                     as.character(bverfg$header)), 1, bverfg$decnoprelim)
bverfg$decnoprelim <- ifelse(grepl("Erlass einer einstweiligen Anordnung",
                                   as.character(bverfg$header)) &
                               grepl("abgelehnt",
                                     as.character(bverfg$header)), 1, bverfg$decnoprelim)
bverfg$decnoprelim <- ifelse(grepl("Wiederholung der einstweiligen Anordnung",
                                   as.character(bverfg$header)) &
                               grepl("abgelehnt",
                                     as.character(bverfg$header)), 1, bverfg$decnoprelim)
#### no procedural decision
bverfg$decnoproc <- ifelse(grepl("Prozesskostenhilfe",
                                 as.character(bverfg$header)) &
                             grepl("abgelehnt",
                                   as.character(bverfg$header)), 1, 0)
bverfg$decnoproc <- ifelse(grepl("Gegenstandswert",
                                 as.character(bverfg$header)) &
                             grepl("verworfen",
                                   as.character(bverfg$header)), 1, bverfg$decnoproc)
bverfg$decnoproc <- ifelse(grepl("Auslagen",
                                 as.character(bverfg$header)) &
                             grepl("abgelehnt",
                                   as.character(bverfg$header)), 1, bverfg$decnoproc)
bverfg$decnoproc <- ifelse(grepl("Auslagen",
                                 as.character(bverfg$header)) &
                             grepl("zurückgewiesen",
                                   as.character(bverfg$header)), 1, bverfg$decnoproc)
bverfg$decnoproc <- ifelse(grepl("Die sofortige Beschwerde wird zurückgewiesen",
                                 as.character(bverfg$header)), 1, bverfg$decnoproc)
bverfg$decnoproc <- ifelse(grepl("Die Erinnerung wird zurückgewiesen",
                                 as.character(bverfg$header)), 1, bverfg$decnoproc)
bverfg$decnoproc <- ifelse(grepl("Der Widerspruch wird verworfen",
                                 as.character(bverfg$header)), 1, bverfg$decnoproc)
bverfg$decnoproc <- ifelse(grepl("Die Erinnerung wird verworfen",
                                 as.character(bverfg$header)), 1, bverfg$decnoproc)
bverfg$decnoproc <- ifelse(grepl("Die Gegenvorstellung wird zurückgewiesen",
                                 as.character(bverfg$header)), 1, bverfg$decnoproc)
bverfg$decnoproc <- ifelse(grepl("Die Verzögerungsbeschwerde wird zurückgewiesen",
                                 as.character(bverfg$header)), 1, bverfg$decnoproc)
bverfg$decnoproc <- ifelse(grepl("Der Antrag auf Festsetzung des Gegenstandswertes wird abgelehnt",
                                 as.character(bverfg$header)), 1, bverfg$decnoproc)
bverfg$decnoproc <- ifelse(grepl("Prozeßkostenhilfe",
                                 as.character(bverfg$header)) &
                             grepl("zurückgewiesen",
                                   as.character(bverfg$header)), 1, bverfg$decnoproc)
bverfg$decnoproc <- ifelse(grepl("Wiedereinsetzung",
                                 as.character(bverfg$header)) &
                             grepl("abgelehnt",
                                   as.character(bverfg$header)), 1, bverfg$decnoproc)
bverfg$decnoproc <- ifelse(grepl("Berichtigung",
                                 as.character(bverfg$header)) &
                             grepl("abgelehnt",
                                   as.character(bverfg$header)), 1, bverfg$decnoproc)
bverfg$decnoproc <- ifelse(grepl("Beschwerde",
                                 as.character(bverfg$header)) &
                             grepl("zurückgewiesen",
                                   as.character(bverfg$header)), 1, bverfg$decnoproc)
bverfg$decnoproc <- ifelse(grepl("Erinnerung",
                                 as.character(bverfg$header)) &
                             grepl("zurückgewiesen",
                                   as.character(bverfg$header)), 1, bverfg$decnoproc)
bverfg$decnoproc <- ifelse(grepl("Gegenvorstellung",
                                 as.character(bverfg$header)) &
                             grepl("zurückgewiesen",
                                   as.character(bverfg$header)), 1, bverfg$decnoproc)
bverfg$decnoproc <- ifelse(grepl("Gegenvorstellung",
                                 as.character(bverfg$header)) &
                             grepl("unzulässig",
                                   as.character(bverfg$header)), 1, bverfg$decnoproc)
bverfg$decnoproc <- ifelse(grepl("Wiedereröffnung",
                                 as.character(bverfg$header)) &
                             grepl("abgelehnt",
                                   as.character(bverfg$header)), 1, bverfg$decnoproc)
bverfg$decnoproc <- ifelse(grepl("Vorlageantrag",
                                 as.character(bverfg$header)) &
                             grepl("unbegründet",
                                   as.character(bverfg$header)), 1, bverfg$decnoproc)

#### abuse
bverfg$decabuse <- ifelse(grepl("Missbrauchsgebühr",
                                as.character(bverfg$header)), 1, 0)

#### no recuse
bverfg$decnorec <- ifelse(grepl("blehnung",
                                as.character(bverfg$header)) &
                            grepl("zurückgewiesen",
                                  as.character(bverfg$header)), 1, 0)
bverfg$decnorec <- ifelse(grepl("blehnung",
                                as.character(bverfg$header)) &
                            grepl("unzulässig",
                                  as.character(bverfg$header)), 1, 0)
bverfg$decnorec <- ifelse(grepl("nicht von der Ausübung des Richteramts ausgeschlossen",
                                as.character(bverfg$header)), 1, bverfg$decnorec)
bverfg$decnorec <- ifelse(grepl("nicht von der Ausübung des Richteramts",
                                as.character(bverfg$header)) &
                            grepl("ausgeschlossen",
                                  as.character(bverfg$header)), 1, bverfg$decnorec)
bverfg$decnorec <- ifelse(grepl("begründet nicht die Besorgnis der Befangenheit",
                                as.character(bverfg$header)), 1, bverfg$decnorec)
bverfg$decnorec <- ifelse(grepl("ist ordnungsgemäß besetzt",
                                as.character(bverfg$header)), 1, bverfg$decnorec)
bverfg$decnorec <- ifelse(bverfg$id == 6268, 1, bverfg$decnorec)


#### reject constitutional complaint
bverfg$decnocomplaint <- ifelse(grepl("zurückgewiesen",
                                      as.character(bverfg$header)) &
                                  bverfg$casetype == "casecomplaint", 1, 0)
bverfg$decnocomplaint <- ifelse(grepl("zurück-\ngewiesen",
                                      as.character(bverfg$header)) &
                                  bverfg$casetype == "casecomplaint", 1, 0)
bverfg$decnocomplaint <- ifelse(grepl("verworfen",
                                      as.character(bverfg$header)) &
                                  bverfg$casetype == "casecomplaint", 1, bverfg$decnocomplaint)
bverfg$decnocomplaint <- ifelse(grepl("Verfassungsbeschwerden",
                                      as.character(bverfg$header)) &
                                  grepl("zurückgewiesen",
                                        as.character(bverfg$header)), 1, bverfg$decnocomplaint)
bverfg$decnocomplaint <- ifelse(grepl("Verfassungsbeschwerde wird",
                                      as.character(bverfg$header)) &
                                  grepl("zurückgewiesen",
                                        as.character(bverfg$header)), 1, bverfg$decnocomplaint)
bverfg$decnocomplaint <- ifelse(grepl("Verfassungsbeschwerde\nwird zurückgewiesen",
                                      as.character(bverfg$header)), 1, bverfg$decnocomplaint)

#### reject election complaint
bverfg$decnoelect <- ifelse(grepl("verworfen",
                                  as.character(bverfg$header)) &
                              bverfg$casetype == "caseelect", 1, 0)
bverfg$decnoelect <- ifelse(grepl("zurückgewiesen",
                                  as.character(bverfg$header)) &
                              bverfg$casetype == "caseelect", 1, bverfg$decnoelect)

#### reject in other procedure
# table(bverfg$casetype[bverfg$header == "Der Antrag wird verworfen."])
# table(bverfg$casetype[bverfg$header == "Der Antrag wird abgelehnt."])
# table(bverfg$casetype[bverfg$header == "Der Antrag wird zurückgewiesen."])
bverfg$decnooth <- ifelse(grepl("verworfen",
                                as.character(bverfg$header)) &
                            bverfg$casetype != "casecomplaint" 
                          & bverfg$casetype != "caseelect", 1, 0)
bverfg$decnooth <- ifelse(grepl("abgelehnt",
                                as.character(bverfg$header)) &
                            bverfg$casetype != "casecomplaint" 
                          & bverfg$casetype != "caseelect", 1, bverfg$decnooth)
bverfg$decnooth <- ifelse(grepl("zurückgewiesen",
                                as.character(bverfg$header)) &
                            bverfg$casetype != "casecomplaint" 
                          & bverfg$casetype != "caseelect", 1, bverfg$decnooth)

##### accept recusation
bverfg$decrec <- ifelse(grepl("blehnung",
                              as.character(bverfg$header)) &
                          grepl("begründet",
                                as.character(bverfg$header)), 1, 0)
bverfg$decrec <- ifelse(grepl("gehindert",
                              as.character(bverfg$header)) &
                          grepl("mitzuwirken",
                                as.character(bverfg$header)), 1, bverfg$decrec)

#### grant preliminary injunction
bverfg$decprelim <- ifelse(grepl("einstweilige Anordnung",
                                 as.character(bverfg$header)) &
                             grepl("wiederholt",
                                   as.character(bverfg$header)), 1, 0)
bverfg$decprelim <- ifelse(grepl("einstweilig",
                                 as.character(bverfg$header)) &
                             grepl("untersagt",
                                   as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("bis zur Entscheidung",
                                 as.character(bverfg$header)) &
                             grepl("untersagt",
                                   as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("außer Vollzug gesetzt",
                                 as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("ausgesetzt",
                                 as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("einstweilen eingestellt",
                                 as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("nicht zu besetzen",
                                 as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("freizuhalten",
                                 as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("frei zu halten",
                                 as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("aufschiebende Wirkung",
                                 as.character(bverfg$header)) &
                             grepl("wiederhergestellt",
                                   as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("aufschiebende Wirkung",
                                 as.character(bverfg$header)) &
                             grepl("wieder hergestellt",
                                   as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("aufschiebende Wirkung",
                                 as.character(bverfg$header)) &
                             grepl("angeordnet",
                                   as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("hinterlegen",
                                 as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("sofortige Vollziehung",
                                 as.character(bverfg$header)) &
                             grepl("angeordnet",
                                   as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("angewiesen",
                                 as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("außer Kraft gesetzt",
                                 as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("Bis zur Entscheidung",
                                 as.character(bverfg$header)) &
                             grepl("angeordnet",
                                   as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("is zur Entscheidung",
                                 as.character(bverfg$header)) &
                             grepl("darf",
                                   as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("Bis zur Entscheidung",
                                 as.character(bverfg$header)) &
                             grepl("eingestellt",
                                   as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("Bis zur Entscheidung",
                                 as.character(bverfg$header)) &
                             grepl("nicht eingeleitet",
                                   as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("gilt",
                                 as.character(bverfg$header)) &
                             grepl("als Übergangsrecht fort",
                                   as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("wird verpflichtet",
                                 as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("wird im Wege einstweiliger Anordnung verpflichtet",
                                 as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("wird im Wege der einstweiligen Anordnung verpflichtet",
                                 as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("längstens",
                                 as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("einstweilen untersagt",
                                 as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("bis zu einer Entscheidung in der Hauptsache nicht",
                                 as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("bis zu einer Entscheidung über den Antrag in der Hauptsache nicht",
                                 as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("einstweilige Anordnung",
                                 as.character(bverfg$header)) &
                             grepl("bleibt aufrechterhalten",
                                   as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("Zwangsvollstreckung",
                                 as.character(bverfg$header)) &
                             grepl("eingestellt",
                                   as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("Für die Dauer",
                                 as.character(bverfg$header)) &
                             grepl("angeordnet",
                                   as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("angeordnet",
                                 as.character(bverfg$header)) &
                             grepl("einzubeziehen",
                                   as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("angeordnet",
                                 as.character(bverfg$header)) &
                             grepl("einbezogen",
                                   as.character(bverfg$header)), 1, bverfg$decprelim)
bverfg$decprelim <- ifelse(grepl("aufgegeben",
                                 as.character(bverfg$header)) &
                             grepl("überlassen",
                                   as.character(bverfg$header)), 1, bverfg$decprelim)


#### grant procedural request
bverfg$decproc <- ifelse(grepl("Wert des Gegenstands der anwaltlichen Tätigkeit",
                               as.character(bverfg$header)), 1, 0)
bverfg$decproc <- ifelse(grepl("Wert des Gegenstandes der anwaltlichen Tätigkeit",
                               as.character(bverfg$header)), 1, bverfg$decproc)
bverfg$decproc <- ifelse(grepl("Auslagen",
                               as.character(bverfg$header)) &
                           grepl("erstatten",
                                 as.character(bverfg$header)), 1, bverfg$decproc)
bverfg$decproc <- ifelse(grepl("Aus-",
                               as.character(bverfg$header)) &
                           grepl("erstatten",
                                 as.character(bverfg$header)), 1, bverfg$decproc)
# bverfg$decproc <- ifelse(grepl("Aus-\nlagen",
#                                as.character(bverfg$header)) &
#                            grepl("erstatten",
#                                  as.character(bverfg$header)), 1, bverfg$decproc)
bverfg$decproc <- ifelse(grepl("Prozesskostenhilfe ohne Ratenzahlung bewilligt",
                               as.character(bverfg$header)), 1, bverfg$decproc)
bverfg$decproc <- ifelse(grepl("Beistand",
                               as.character(bverfg$header)) &
                           grepl("zugelassen",
                                 as.character(bverfg$header)), 1, bverfg$decproc)
bverfg$decproc <- ifelse(grepl("Tenor",
                               as.character(bverfg$header)) &
                           grepl("berichtigt",
                                 as.character(bverfg$header)), 1, bverfg$decproc)

##### constitutionality of statute
bverfg$decstat <- ifelse(grepl("nichtig",
                               as.character(bverfg$header)), 0, 99)
bverfg$decstat <- ifelse(grepl("unvereinbar",
                               as.character(bverfg$header)) &
                           bverfg$decstat > 0, 1, bverfg$decstat)
bverfg$decstat <- ifelse(grepl(" vereinbar",
                               as.character(bverfg$header)) &
                           grepl("soweit",
                                 as.character(bverfg$header)), 2, bverfg$decstat)
bverfg$decstat <- ifelse(grepl("verstößt nicht",
                               as.character(bverfg$header)) &
                           grepl("soweit",
                                 as.character(bverfg$header)), 2, bverfg$decstat)
bverfg$decstat <- ifelse(grepl("verstieß nicht",
                               as.character(bverfg$header)) &
                           grepl("soweit",
                                 as.character(bverfg$header)), 2, bverfg$decstat)
bverfg$decstat <- ifelse(grepl("schließen",
                               as.character(bverfg$header)) &
                           grepl("nicht grundsätzlich aus",
                                 as.character(bverfg$header)), 2, bverfg$decstat)
bverfg$decstat <- ifelse(grepl(" vereinbar",
                               as.character(bverfg$header)) &
                           bverfg$decstat > 2, 3, bverfg$decstat)
bverfg$decstat <- ifelse(grepl("verstößt",
                               as.character(bverfg$header)) &
                           grepl("nicht gegen",
                                 as.character(bverfg$header)), 3, bverfg$decstat)
bverfg$decstat <- ifelse(grepl("keine allgemeine Regel des Völkerrechts",
                               as.character(bverfg$header)), 4, bverfg$decstat)
bverfg$decstat <- ifelse(grepl("allgemeine Regel des Völkerrechts",
                               as.character(bverfg$header)) &
                           grepl("nicht feststellbar",
                                 as.character(bverfg$header)), 4, bverfg$decstat)

##### constitutionality of ruling
bverfg$decjust <- ifelse(grepl("aufgehoben",
                               as.character(bverfg$header)), 0, 99)
bverfg$decjust <- ifelse(grepl("verletzt",
                               as.character(bverfg$header)) &
                           bverfg$decjust > 0, 1, bverfg$decjust)
bverfg$decjust <- ifelse(grepl("verletzen",
                               as.character(bverfg$header)) &
                           bverfg$decjust > 0, 1, bverfg$decjust)
bverfg$decjust <- ifelse(grepl("ver-\nletzen",
                               as.character(bverfg$header)) &
                           bverfg$decjust > 0, 1, bverfg$decjust)

##### intervention in election matters
bverfg$decelect <- ifelse(grepl("Wählerverzeichnis",
                                as.character(bverfg$header)) &
                            grepl("nicht anzuwenden",
                                  as.character(bverfg$header)), 1, 0)

##### intervention in other matters
bverfg$decoth <- ifelse(grepl("Vermittlungsausschuss",
                              as.character(bverfg$header)) &
                          grepl("zu beschließen",
                                as.character(bverfg$header)), 1, 0)

##### decision classified how often?
bverfg$sumdec <- bverfg$deccert + bverfg$dec100cert +
  bverfg$decothcert +
  bverfg$decdisc + bverfg$decnoprelim +
  bverfg$decnoproc + bverfg$decnorec +
  bverfg$decnocomplaint +
  bverfg$decnoelect +
  bverfg$decnooth + bverfg$decrec +
  bverfg$decprelim + bverfg$decproc + 
  bverfg$decabuse + bverfg$decelect + bverfg$decoth

##### success
#### main (w/o certiorari)
bverfg$succmain <- ifelse(bverfg$decstat == 1 | bverfg$decjust == 1 |
                            bverfg$decelect == 1 | bverfg$decoth == 1, 1,
                          ifelse(bverfg$decnocomplaint == 1 | 
                                   bverfg$decnoelect == 1 | bverfg$decnooth == 1, 0,
                                 99))
#### main (with certiorari)
bverfg$succmcert <- ifelse(bverfg$succmain == 1, 1,
                           ifelse(bverfg$succmain == 0, 0,
                                  ifelse(bverfg$deccert == 1, 0,
                                         ifelse(bverfg$dec100cert == 1, 0,
                                                ifelse(bverfg$decothcert == 1, 0, 99)))))
#### preliminary
bverfg$succprelim <- ifelse(bverfg$decprelim == 1, 1,
                            ifelse(bverfg$decnoprelim == 1, 0, 99))
#### procedural
bverfg$succproc <- ifelse(bverfg$decproc == 1 | bverfg$decrec == 1, 1,
                          ifelse(bverfg$decnoproc == 1 | bverfg$decnorec, 0, 99))

#### combined success
bverfg$succcomb <- ifelse(bverfg$succmain == 1 | bverfg$succprelim == 1 | bverfg$succproc == 1, 1,
                          ifelse(bverfg$succmain == 0 | bverfg$succprelim == 0 | bverfg$succproc == 0, 0,
                                 99))

##### FUNDAMENTAL FREEDOMS ----
  ##### binary ----
bverfg$gr1_1 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*1\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr1_2 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*1\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr1_3 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*1\\s*Abs\\.\\s*3\\s*GG")), 1, 0)
bverfg$gr2_1 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*2\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr2_2 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*2\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr2_2_1 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*2\\s*Abs\\.\\s*2\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr2_2_2 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*2\\s*Abs\\.\\s*2\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr2_2_3 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*2\\s*Abs\\.\\s*2\\s*Satz\\s*3\\s*GG")), 1, 0)
bverfg$gr2_2_all <- ifelse(bverfg$gr2_2 == 1 | bverfg$gr2_2_1 == 1 | bverfg$gr2_2_2 == 1 |
                             bverfg$gr2_2_3 == 1, 1, 0)
bverfg$gr3_1 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*3\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr3_2 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*3\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr3_2_1 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*3\\s*Abs\\.\\s*2\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr3_2_2 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*3\\s*Abs\\.\\s*2\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr3_2_all <- ifelse(bverfg$gr3_2 == 1 | bverfg$gr3_2_1 == 1 | bverfg$gr3_2_2 == 1, 1, 0)
bverfg$gr3_3 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*3\\s*Abs\\.\\s*3\\s*GG")), 1, 0)
bverfg$gr3_3_1 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*3\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr3_3_2 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*3\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr3_3_all <- ifelse(bverfg$gr3_3 == 1 | bverfg$gr3_3_1 == 1 | bverfg$gr3_3_2 == 1, 1, 0)
bverfg$gr4_1 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*4\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr4_1und <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*4\\s*Abs\\.\\s*1\\s*und.*GG")), 1, 0)
bverfg$gr4_2 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*4\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr4_religion <- ifelse(bverfg$gr4_1 == 1 | bverfg$gr4_1und == 1 |
                                bverfg$gr4_2 == 1, 1, 0)
bverfg$gr4_3 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*4\\s*Abs\\.\\s*3\\s*GG")), 1, 0)
bverfg$gr4_3_1 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*4\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr4_3_2 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*4\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr4_3_all <- ifelse(bverfg$gr4_3 == 1 | bverfg$gr4_3_1 == 1 | bverfg$gr4_3_2 == 1, 1, 0)
bverfg$gr5_1 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*5\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr5_1_1 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*5\\s*Abs\\.\\s*1\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr5_1_2 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*5\\s*Abs\\.\\s*1\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr5_1_3 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*5\\s*Abs\\.\\s*1\\s*Satz\\s*3\\s*GG")), 1, 0)
bverfg$gr5_2 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*5\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr5_speech <- ifelse(bverfg$gr5_1 == 1 | bverfg$gr5_1_1 == 1 | bverfg$gr5_1_2 == 1 |
                              bverfg$gr5_1_3 == 1 | bverfg$gr5_2 == 1, 1, 0)
bverfg$gr5_3 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*5\\s*Abs\\.\\s*3\\s*GG")), 1, 0)
bverfg$gr5_3_1 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*5\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr5_3_2 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*5\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr5_3_all <- ifelse(bverfg$gr5_3 == 1 | bverfg$gr5_3_1 == 1 | bverfg$gr5_3_2 == 1, 1, 0)
bverfg$gr6_1 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*6\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr6_2 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*6\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr6_2_1 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*6\\s*Abs\\.\\s*2\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr6_2_2 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*6\\s*Abs\\.\\s*2\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr6_3 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*6\\s*Abs\\.\\s*3\\s*GG")), 1, 0)
bverfg$gr6_4 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*6\\s*Abs\\.\\s*4\\s*GG")), 1, 0)
bverfg$gr6_5 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*6\\s*Abs\\.\\s*5\\s*GG")), 1, 0)
bverfg$gr6_all <- ifelse(bverfg$gr6_1 == 1 | bverfg$gr6_2 == 1 | bverfg$gr6_2_1 == 1 |
                           bverfg$gr6_2_2 == 1 | bverfg$gr6_3 == 1 | bverfg$gr6_4 == 1 |
                           bverfg$gr6_5 == 1, 1, 0)
bverfg$gr7_1 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*7\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr7_2 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*7\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr7_3 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*7\\s*Abs\\.\\s*3\\s*GG")), 1, 0)
bverfg$gr7_3_1 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*7\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr7_3_2 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*7\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr7_3_3 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*7\\s*Abs\\.\\s*3\\s*Satz\\s*3\\s*GG")), 1, 0)
bverfg$gr7_4 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*7\\s*Abs\\.\\s*4\\s*GG")), 1, 0)
bverfg$gr7_4_1 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*7\\s*Abs\\.\\s*4\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr7_4_2 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*7\\s*Abs\\.\\s*4\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr7_4_3 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*7\\s*Abs\\.\\s*4\\s*Satz\\s*3\\s*GG")), 1, 0)
bverfg$gr7_5 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*7\\s*Abs\\.\\s*5\\s*GG")), 1, 0)
bverfg$gr7_6 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*7\\s*Abs\\.\\s*6\\s*GG")), 1, 0)
bverfg$gr7_all <- ifelse(bverfg$gr7_1 == 1 | bverfg$gr7_2 == 1 | bverfg$gr7_3 == 1 |
                           bverfg$gr7_3_1 == 1 | bverfg$gr7_3_2 == 1 | 
                           bverfg$gr7_3_3 == 1 | bverfg$gr7_4 == 1 | 
                           bverfg$gr7_4_1 == 1 | bverfg$gr7_4_2 == 1 |
                           bverfg$gr7_4_3 == 1 | bverfg$gr7_5 == 1 |
                           bverfg$gr7_6 == 1, 1, 0)
bverfg$gr8_1 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*8\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr8_2 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*8\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr8_all <- ifelse(bverfg$gr8_1 == 1 | bverfg$gr8_2 == 1, 1, 0)
bverfg$gr9_1 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*9\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr9_2 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*9\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr9_association <- ifelse(bverfg$gr9_1 == 1 | bverfg$gr9_2 == 1, 1, 0)
bverfg$gr9_3 <- ifelse(str_detect(bverfg$full_text,
                                  regex("Art\\.\\s*9\\s*Abs\\.\\s*3\\s*GG")), 1, 0)
bverfg$gr9_3_1 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*9\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr9_3_2 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*9\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr9_3_3 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*9\\s*Abs\\.\\s*3\\s*Satz\\s*3\\s*GG")), 1, 0)
bverfg$gr9_3_all <- ifelse(bverfg$gr9_3 == 1 | bverfg$gr9_3_1 == 1 | bverfg$gr9_3_2 == 1 |
                             bverfg$gr9_3_3 == 1, 1, 0)
bverfg$gr10_1 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*10\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr10_2 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*10\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr10_2_1 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*10\\s*Abs\\.\\s*2\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr10_2_2 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*10\\s*Abs\\.\\s*2\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr10_all <- ifelse(bverfg$gr10_1 == 1 | bverfg$gr10_2 == 1 | bverfg$gr10_2_1 == 1 |
                            bverfg$gr10_2_2 == 1, 1, 0)
bverfg$gr11_1 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*11\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr11_2 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*11\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr11_all <- ifelse(bverfg$gr11_1 == 1 | bverfg$gr11_2 == 1, 1, 0)
bverfg$gr12_1 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*12\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr12_1_1 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*12\\s*Abs\\.\\s*1\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr12_1_2 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*12\\s*Abs\\.\\s*1\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr12_1_all <- ifelse(bverfg$gr12_1 == 1 | bverfg$gr12_1_1 == 1 | bverfg$gr12_1_2 == 1, 1, 0)
bverfg$gr12_2 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*12\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr12_3 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*12\\s*Abs\\.\\s*3\\s*GG")), 1, 0)
bverfg$gr12a_1 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr12a_2 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr12a_3 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*3\\s*GG")), 1, 0)
bverfg$gr12a_3_1 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG")),
                           1, 0)
bverfg$gr12a_3_2 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG")),
                           1, 0)
bverfg$gr12a_4 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*4\\s*GG")), 1, 0)
bverfg$gr12a_4_1 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*4\\s*Satz\\s*1\\s*GG")),
                           1, 0)
bverfg$gr12a_4_2 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*4\\s*Satz\\s*2\\s*GG")),
                           1, 0)
bverfg$gr12a_5 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*5\\s*GG")), 1, 0)
bverfg$gr12a_5_1 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*5\\s*Satz\\s*1\\s*GG")),
                           1, 0)
bverfg$gr12a_5_2 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*5\\s*Satz\\s*2\\s*GG")),
                           1, 0)
bverfg$gr12a_6 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*6\\s*GG")), 1, 0)
bverfg$gr12a_6_1 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*6\\s*Satz\\s*1\\s*GG")),
                           1, 0)
bverfg$gr12a_6_2 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*6\\s*Satz\\s*2\\s*GG")),
                           1, 0)
bverfg$gr13_1 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*13\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr13_2 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*13\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr13_3 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*13\\s*Abs\\.\\s*3\\s*GG")), 1, 0)
bverfg$gr13_3_1 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*13\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr13_3_2 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*13\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr13_3_3 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*13\\s*Abs\\.\\s*3\\s*Satz\\s*3\\s*GG")), 1, 0)
bverfg$gr13_3_4 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*13\\s*Abs\\.\\s*3\\s*Satz\\s*4\\s*GG")), 1, 0)
bverfg$gr13_4 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*13\\s*Abs\\.\\s*4\\s*GG")), 1, 0)
bverfg$gr13_4_1 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*13\\s*Abs\\.\\s*4\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr13_4_2 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*13\\s*Abs\\.\\s*4\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr13_5 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*13\\s*Abs\\.\\s*5\\s*GG")), 1, 0)
bverfg$gr13_5_1 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*13\\s*Abs\\.\\s*5\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr13_5_2 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*13\\s*Abs\\.\\s*5\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr13_6 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*13\\s*Abs\\.\\s*6\\s*GG")), 1, 0)
bverfg$gr13_6_1 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*13\\s*Abs\\.\\s*6\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr13_6_2 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*13\\s*Abs\\.\\s*6\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr13_6_3 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*13\\s*Abs\\.\\s*6\\s*Satz\\s*3\\s*GG")), 1, 0)
bverfg$gr13_7 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*13\\s*Abs\\.\\s*7\\s*GG")), 1, 0)
bverfg$gr13_all <- ifelse(bverfg$gr13_1 == 1 | bverfg$gr13_2 == 1 | bverfg$gr13_3 == 1 |
                            bverfg$gr13_3_1 == 1 | bverfg$gr13_3_2 == 1 |
                            bverfg$gr13_3_3 == 1 | bverfg$gr13_3_4 == 1 |
                            bverfg$gr13_4 == 1 | bverfg$gr13_4_1 == 1 | bverfg$gr13_4_2 == 1 |
                            bverfg$gr13_5 == 1 | bverfg$gr13_5_1 == 1 | bverfg$gr13_5_2 == 1 |
                            bverfg$gr13_6 == 1 | bverfg$gr13_6_1 == 1 | bverfg$gr13_6_2 == 1 |
                            bverfg$gr13_6_3 == 1 | bverfg$gr13_7 == 1, 1, 0)
bverfg$gr14_1 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*14\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr14_1_1 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*14\\s*Abs\\.\\s*1\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr14_1_2 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*14\\s*Abs\\.\\s*1\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr14_2 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*14\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr14_2_1 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*14\\s*Abs\\.\\s*2\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr14_2_2 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*14\\s*Abs\\.\\s*2\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr14_guarantee <- ifelse(bverfg$gr14_1 == 1 | bverfg$gr14_1_1 == 1 | bverfg$gr14_1_2 == 1 |
                                  bverfg$gr14_2 == 1 | bverfg$gr14_2_1 == 1 |
                                  bverfg$gr14_2_2 == 1, 1, 0)
bverfg$gr14_3 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*14\\s*Abs\\.\\s*3\\s*GG")), 1, 0)
bverfg$gr14_3_1 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*14\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr14_3_2 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*14\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr14_3_3 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*14\\s*Abs\\.\\s*3\\s*Satz\\s*3\\s*GG")), 1, 0)
bverfg$gr14_3_4 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*14\\s*Abs\\.\\s*3\\s*Satz\\s*4\\s*GG")), 1, 0)
bverfg$gr14_3_all <- ifelse(bverfg$gr14_3 == 1 | bverfg$gr14_3_1 == 1 | bverfg$gr14_3_2 == 1 |
                              bverfg$gr14_3_3 == 1 | bverfg$gr14_3_4 == 1, 1, 0)
bverfg$gr15 <- ifelse(str_detect(bverfg$full_text,
                                 regex("Art\\.\\s*15\\s*GG")), 1, 0)
bverfg$gr16_1 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*16\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr16_1_1 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*16\\s*Abs\\.\\s*1\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr16_1_2 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*16\\s*Abs\\.\\s*1\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr16_1_all <- ifelse(bverfg$gr16_1 == 1 | bverfg$gr16_1_1 == 1 | bverfg$gr16_1_2 == 1,
                            1, 0)
bverfg$gr16_2 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*16\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr16_2_1 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*16\\s*Abs\\.\\s*2\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr16_2_2 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*16\\s*Abs\\.\\s*2\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr16_2_all <- ifelse(bverfg$gr16_2 == 1 | bverfg$gr16_2_1 == 1 | bverfg$gr16_2_2 == 1,
                            1, 0)
bverfg$gr16a_1 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr16a_2 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr16a_2_1 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*2\\s*Satz\\s*1\\s*GG")),
                           1, 0)
bverfg$gr16a_2_2 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*2\\s*Satz\\s*2\\s*GG")),
                           1, 0)
bverfg$gr16a_3 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*3\\s*GG")), 1, 0)
bverfg$gr16a_3_1 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG")),
                           1, 0)
bverfg$gr16a_3_2 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG")),
                           1, 0)
bverfg$gr16a_4 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*4\\s*GG")), 1, 0)
bverfg$gr16a_4_1 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*4\\s*Satz\\s*1\\s*GG")),
                           1, 0)
bverfg$gr16a_4_2 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*4\\s*Satz\\s*2\\s*GG")),
                           1, 0)
bverfg$gr16a_5 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*5\\s*GG")), 1, 0)
bverfg$gr16a_all <- ifelse(bverfg$gr16a_1 == 1 | bverfg$gr16a_2 == 1 |
                             bverfg$gr16a_2_1 == 1 | bverfg$gr16a_2_2 == 1 |
                             bverfg$gr16a_3 == 1 | bverfg$gr16a_3_1 == 1 |
                             bverfg$gr16a_3_2 == 1 | bverfg$gr16a_4 == 1 |
                             bverfg$gr16a_4_1 == 1 | bverfg$gr16a_4_2 == 1 |
                             bverfg$gr16a_5 == 1, 1, 0)
bverfg$gr17 <- ifelse(str_detect(bverfg$full_text,
                                 regex("Art\\.\\s*17\\s*GG")), 1, 0)
bverfg$gr17a_1 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*17\\s*a\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr17a_2 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*17\\s*a\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr18 <- ifelse(str_detect(bverfg$full_text,
                                 regex("Art\\.\\s*18\\s*GG")), 1, 0)
bverfg$gr19_1_1 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*19\\s*Abs\\.\\s*1\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr19_1_2 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*19\\s*Abs\\.\\s*1\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr19_2 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*19\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr19_3 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*19\\s*Abs\\.\\s*3\\s*GG")), 1, 0)
bverfg$gr19_4 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*19\\s*Abs\\.\\s*4\\s*GG")), 1, 0)
bverfg$gr19_4_1 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*19\\s*Abs\\.\\s*4\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr19_4_2 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*19\\s*Abs\\.\\s*4\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr19_4_3 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*19\\s*Abs\\.\\s*4\\s*Satz\\s*3\\s*GG")), 1, 0)
bverfg$gr19_4_all <- ifelse(bverfg$gr19_4 == 1 | bverfg$gr19_4_1 == 1 | bverfg$gr19_4_2 == 1 |
                              bverfg$gr19_4_3 == 1, 1, 0)
bverfg$gr20_4 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*20\\s*Abs\\.\\s*4\\s*GG")), 1, 0)
bverfg$gr28_2 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*28\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr28_2_1 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*28\\s*Abs\\.\\s*2\\s*Satz\\s*1\\s*GG")),
                          1, 0)
bverfg$gr28_2_2 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*28\\s*Abs\\.\\s*2\\s*Satz\\s*2\\s*GG")),
                          1, 0)
bverfg$gr28_2_3 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*28\\s*Abs\\.\\s*2\\s*Satz\\s*3\\s*GG")),
                          1, 0)
bverfg$gr28_2_all <- ifelse(bverfg$gr28_2 == 1 | bverfg$gr28_2_1 == 1 | bverfg$gr28_2_2 == 1 |
                              bverfg$gr28_2_3 == 1, 1, 0)
bverfg$gr33_1 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*33\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr33_2 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*33\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr33_3 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*33\\s*Abs\\.\\s*3\\s*GG")), 1, 0)
bverfg$gr33_3_1 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*33\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr33_3_2 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*33\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr33_4 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*33\\s*Abs\\.\\s*4\\s*GG")), 1, 0)
bverfg$gr33_5 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*33\\s*Abs\\.\\s*5\\s*GG")), 1, 0)
bverfg$gr33_publicofficial <- ifelse(bverfg$gr33_2 == 1 | bverfg$gr33_3_1 == 1 |
                                       bverfg$gr33_4 == 1 | bverfg$gr33_5 == 1, 1, 0)
bverfg$gr38_1 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*38\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr38_1_1 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*38\\s*Abs\\.\\s*1\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr38_1_2 <- ifelse(str_detect(bverfg$full_text,
                                     regex("Art\\.\\s*38\\s*Abs\\.\\s*1\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr38_2 <- ifelse(str_detect(bverfg$full_text,
                                   regex("Art\\.\\s*38\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr38_all <- ifelse(bverfg$gr38_1 == 1 | bverfg$gr38_1_1 == 1 | 
                            bverfg$gr38_1_2 == 1 | bverfg$gr38_2 == 1, 1, 0)
bverfg$gr101_1 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*101\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr101_1_1 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*101\\s*Abs\\.\\s*1\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr101_1_2 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*101\\s*Abs\\.\\s*1\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr101_2 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*101\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr101_all <- ifelse(bverfg$gr101_1 == 1 | bverfg$gr101_1_1 == 1 |
                             bverfg$gr101_1_2 == 1 | bverfg$gr101_2 == 1, 1, 0)
bverfg$gr103_1 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*103\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr103_2 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*103\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr103_3 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*103\\s*Abs\\.\\s*3\\s*GG")), 1, 0)
bverfg$gr103_straf <- ifelse(bverfg$gr103_2 == 1 |
                               bverfg$gr103_3 == 1, 1, 0)
bverfg$gr104_1 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*104\\s*Abs\\.\\s*1\\s*GG")), 1, 0)
bverfg$gr104_1_1 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*104\\s*Abs\\.\\s*1\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr104_1_2 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*104\\s*Abs\\.\\s*1\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr104_2 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*104\\s*Abs\\.\\s*2\\s*GG")), 1, 0)
bverfg$gr104_2_1 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*104\\s*Abs\\.\\s*2\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr104_2_2 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*104\\s*Abs\\.\\s*2\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr104_2_3 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*104\\s*Abs\\.\\s*2\\s*Satz\\s*3\\s*GG")), 1, 0)
bverfg$gr104_2_4 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*104\\s*Abs\\.\\s*2\\s*Satz\\s*4\\s*GG")), 1, 0)
bverfg$gr104_3 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*104\\s*Abs\\.\\s*3\\s*GG")), 1, 0)
bverfg$gr104_3_1 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*104\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG")), 1, 0)
bverfg$gr104_3_2 <- ifelse(str_detect(bverfg$full_text,
                                      regex("Art\\.\\s*104\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG")), 1, 0)
bverfg$gr104_4 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*104\\s*Abs\\.\\s*4\\s*GG")), 1, 0)
bverfg$gr104_all <- ifelse(bverfg$gr104_1 == 1 | bverfg$gr104_1_1 == 1 | bverfg$gr104_1_2 == 1 |
                             bverfg$gr104_2 == 1 | bverfg$gr104_2_1 == 1 | bverfg$gr104_2_2 == 1 |
                             bverfg$gr104_2_3 == 1 | bverfg$gr104_2_4 == 1 | bverfg$gr104_3 == 1 |
                             bverfg$gr104_3_1 == 1 | bverfg$gr104_3_2 == 1 |
                             bverfg$gr104_4 == 1, 1, 0)
bverfg$grwr136 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*136\\s*WRV")), 1, 0)
bverfg$grwr137 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*137\\s*WRV")), 1, 0)
bverfg$grwr138 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*138\\s*WRV")), 1, 0)
bverfg$grwr139 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*139\\s*WRV")), 1, 0)
bverfg$grwr141 <- ifelse(str_detect(bverfg$full_text,
                                    regex("Art\\.\\s*141\\s*WRV")), 1, 0)
bverfg$grwr_all <- ifelse(bverfg$grwr136 == 1 | bverfg$grwr137 == 1 | bverfg$grwr138 == 1 |
                            bverfg$grwr139 == 1 | bverfg$grwr141 == 1, 1, 0)

  ##### frequency count ----

bverfg$fgr1_1 <- str_count(bverfg$full_text, 
                           regex("Art\\.\\s*1\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr1_2 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*1\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr1_3 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*1\\s*Abs\\.\\s*3\\s*GG"))
bverfg$fgr2_1 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*2\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr2_2 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*2\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr2_2_1 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*2\\s*Abs\\.\\s*2\\s*Satz\\s*1\\s*GG"))
bverfg$fgr2_2_2 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*2\\s*Abs\\.\\s*2\\s*Satz\\s*2\\s*GG"))
bverfg$fgr2_2_3 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*2\\s*Abs\\.\\s*2\\s*Satz\\s*3\\s*GG"))
bverfg$fgr2_2_all <- bverfg$fgr2_2 + bverfg$fgr2_2_1 + bverfg$fgr2_2_2 + bverfg$fgr2_2_2
bverfg$fgr3_1 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*3\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr3_2 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*3\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr3_2_1 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*3\\s*Abs\\.\\s*2\\s*Satz\\s*1\\s*GG"))
bverfg$fgr3_2_2 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*3\\s*Abs\\.\\s*2\\s*Satz\\s*2\\s*GG"))
bverfg$fgr3_2_all <- bverfg$fgr3_2 + bverfg$fgr3_2_1 + bverfg$fgr3_2_2
bverfg$fgr3_3 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*3\\s*Abs\\.\\s*3\\s*GG"))
bverfg$fgr3_3_1 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*3\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG"))
bverfg$fgr3_3_2 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*3\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG"))
bverfg$fgr3_3_all <- bverfg$fgr3_3 + bverfg$fgr3_3_1 + bverfg$fgr3_3_2
bverfg$fgr4_1 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*4\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr4_1und <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*4\\s*Abs\\.\\s*1\\s*und.*GG"))
bverfg$fgr4_2 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*4\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr4_religion <- bverfg$fgr4_1 + bverfg$fgr4_1und + bverfg$fgr4_2
bverfg$fgr4_3 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*4\\s*Abs\\.\\s*3\\s*GG"))
bverfg$fgr4_3_1 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*4\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG"))
bverfg$fgr4_3_2 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*4\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG"))
bverfg$fgr4_3_all <- bverfg$fgr4_3 + bverfg$fgr4_3_1 + bverfg$fgr4_3_2
bverfg$fgr5_1 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*5\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr5_1_1 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*5\\s*Abs\\.\\s*1\\s*Satz\\s*1\\s*GG"))
bverfg$fgr5_1_2 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*5\\s*Abs\\.\\s*1\\s*Satz\\s*2\\s*GG"))
bverfg$fgr5_1_3 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*5\\s*Abs\\.\\s*1\\s*Satz\\s*3\\s*GG"))
bverfg$fgr5_2 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*5\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr5_speech <- bverfg$fgr5_1 + bverfg$fgr5_1_1 + bverfg$fgr5_1_2 + bverfg$fgr5_1_3 + 
  bverfg$fgr5_2
bverfg$fgr5_3 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*5\\s*Abs\\.\\s*3\\s*GG"))
bverfg$fgr5_3_1 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*5\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG"))
bverfg$fgr5_3_2 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*5\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG"))
bverfg$fgr5_3_all <- bverfg$fgr5_3 + bverfg$fgr5_3_1 + bverfg$fgr5_3_2
bverfg$fgr6_1 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*6\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr6_2 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*6\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr6_2_1 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*6\\s*Abs\\.\\s*2\\s*Satz\\s*1\\s*GG"))
bverfg$fgr6_2_2 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*6\\s*Abs\\.\\s*2\\s*Satz\\s*2\\s*GG"))
bverfg$fgr6_3 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*6\\s*Abs\\.\\s*3\\s*GG"))
bverfg$fgr6_4 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*6\\s*Abs\\.\\s*4\\s*GG"))
bverfg$fgr6_5 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*6\\s*Abs\\.\\s*5\\s*GG"))
bverfg$fgr6_all <- bverfg$fgr6_1 + bverfg$fgr6_2 + bverfg$fgr6_2_1 + bverfg$fgr6_2_2 + 
  bverfg$fgr6_3 + bverfg$fgr6_4 + bverfg$fgr6_5
bverfg$fgr7_1 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*7\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr7_2 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*7\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr7_3 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*7\\s*Abs\\.\\s*3\\s*GG"))
bverfg$fgr7_3_1 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*7\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG"))
bverfg$fgr7_3_2 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*7\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG"))
bverfg$fgr7_3_3 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*7\\s*Abs\\.\\s*3\\s*Satz\\s*3\\s*GG"))
bverfg$fgr7_4 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*7\\s*Abs\\.\\s*4\\s*GG"))
bverfg$fgr7_4_1 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*7\\s*Abs\\.\\s*4\\s*Satz\\s*1\\s*GG"))
bverfg$fgr7_4_2 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*7\\s*Abs\\.\\s*4\\s*Satz\\s*2\\s*GG"))
bverfg$fgr7_4_3 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*7\\s*Abs\\.\\s*4\\s*Satz\\s*3\\s*GG"))
bverfg$fgr7_5 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*7\\s*Abs\\.\\s*5\\s*GG"))
bverfg$fgr7_6 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*7\\s*Abs\\.\\s*6\\s*GG"))
bverfg$fgr7_all <- bverfg$fgr7_1 + bverfg$fgr7_2 + bverfg$fgr7_3 + bverfg$fgr7_3_1 +
  bverfg$fgr7_3_2 + bverfg$fgr7_3_3 + bverfg$fgr7_4 + bverfg$fgr7_4_1 + bverfg$fgr7_4_2 +
  bverfg$fgr7_4_3 + bverfg$fgr7_5 + bverfg$fgr7_6
bverfg$fgr8_1 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*8\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr8_2 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*8\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr8_all <- bverfg$fgr8_1 + bverfg$fgr8_2
bverfg$fgr9_1 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*9\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr9_2 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*9\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr9_association <- bverfg$fgr9_1 + bverfg$fgr9_2
bverfg$fgr9_3 <- str_count(bverfg$full_text,
                           regex("Art\\.\\s*9\\s*Abs\\.\\s*3\\s*GG"))
bverfg$fgr9_3_1 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*9\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG"))
bverfg$fgr9_3_2 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*9\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG"))
bverfg$fgr9_3_3 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*9\\s*Abs\\.\\s*3\\s*Satz\\s*3\\s*GG"))
bverfg$fgr9_3_all <- bverfg$fgr9_3 + bverfg$fgr9_3_1 + bverfg$fgr9_3_2 + bverfg$fgr9_3_3
bverfg$fgr10_1 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*10\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr10_2 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*10\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr10_2_1 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*10\\s*Abs\\.\\s*2\\s*Satz\\s*1\\s*GG"))
bverfg$fgr10_2_2 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*10\\s*Abs\\.\\s*2\\s*Satz\\s*2\\s*GG"))
bverfg$fgr10_all <- bverfg$fgr10_1 + bverfg$fgr10_2 + bverfg$fgr10_2_1 + bverfg$fgr10_2_2
bverfg$fgr11_1 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*11\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr11_2 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*11\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr11_all <- bverfg$fgr11_1 + bverfg$fgr11_2
bverfg$fgr12_1 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*12\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr12_1_1 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*12\\s*Abs\\.\\s*1\\s*Satz\\s*1\\s*GG"))
bverfg$fgr12_1_2 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*12\\s*Abs\\.\\s*1\\s*Satz\\s*2\\s*GG"))
bverfg$fgr12_1_all <- bverfg$fgr12_1 + bverfg$fgr12_1_1 + bverfg$fgr12_1_2
bverfg$fgr12_2 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*12\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr12_3 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*12\\s*Abs\\.\\s*3\\s*GG"))
bverfg$fgr12a_1 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr12a_2 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr12a_3 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*3\\s*GG"))
bverfg$fgr12a_3_1 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG"))
bverfg$fgr12a_3_2 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG"))
bverfg$fgr12a_4 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*4\\s*GG"))
bverfg$fgr12a_4_1 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*4\\s*Satz\\s*1\\s*GG"))
bverfg$fgr12a_4_2 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*4\\s*Satz\\s*2\\s*GG"))
bverfg$fgr12a_5 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*5\\s*GG"))
bverfg$fgr12a_5_1 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*5\\s*Satz\\s*1\\s*GG"))
bverfg$fgr12a_5_2 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*5\\s*Satz\\s*2\\s*GG"))
bverfg$fgr12a_6 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*6\\s*GG"))
bverfg$fgr12a_6_1 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*6\\s*Satz\\s*1\\s*GG"))
bverfg$fgr12a_6_2 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*12\\s*a\\s*Abs\\.\\s*6\\s*Satz\\s*2\\s*GG"))
bverfg$fgr13_1 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*13\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr13_2 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*13\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr13_3 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*13\\s*Abs\\.\\s*3\\s*GG"))
bverfg$fgr13_3_1 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*13\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG"))
bverfg$fgr13_3_2 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*13\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG"))
bverfg$fgr13_3_3 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*13\\s*Abs\\.\\s*3\\s*Satz\\s*3\\s*GG"))
bverfg$fgr13_3_4 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*13\\s*Abs\\.\\s*3\\s*Satz\\s*4\\s*GG"))
bverfg$fgr13_4 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*13\\s*Abs\\.\\s*4\\s*GG"))
bverfg$fgr13_4_1 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*13\\s*Abs\\.\\s*4\\s*Satz\\s*1\\s*GG"))
bverfg$fgr13_4_2 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*13\\s*Abs\\.\\s*4\\s*Satz\\s*2\\s*GG"))
bverfg$fgr13_5 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*13\\s*Abs\\.\\s*5\\s*GG"))
bverfg$fgr13_5_1 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*13\\s*Abs\\.\\s*5\\s*Satz\\s*1\\s*GG"))
bverfg$fgr13_5_2 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*13\\s*Abs\\.\\s*5\\s*Satz\\s*2\\s*GG"))
bverfg$fgr13_6 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*13\\s*Abs\\.\\s*6\\s*GG"))
bverfg$fgr13_6_1 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*13\\s*Abs\\.\\s*6\\s*Satz\\s*1\\s*GG"))
bverfg$fgr13_6_2 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*13\\s*Abs\\.\\s*6\\s*Satz\\s*2\\s*GG"))
bverfg$fgr13_6_3 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*13\\s*Abs\\.\\s*6\\s*Satz\\s*3\\s*GG"))
bverfg$fgr13_7 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*13\\s*Abs\\.\\s*7\\s*GG"))
bverfg$fgr13_all <- bverfg$fgr13_1 + bverfg$fgr13_2 + bverfg$fgr13_3 + bverfg$fgr13_3_1 +
  bverfg$fgr13_3_2 + bverfg$fgr13_3_3 + bverfg$fgr13_3_4 + bverfg$fgr13_4 + bverfg$fgr13_4_1 +
  bverfg$fgr13_4_2 + bverfg$fgr13_5 + bverfg$fgr13_5_1 + bverfg$fgr13_5_2 + bverfg$fgr13_6 +
  bverfg$fgr13_6_1 + bverfg$fgr13_6_2 + bverfg$fgr13_6_3 + bverfg$fgr13_7
bverfg$fgr14_1 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*14\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr14_1_1 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*14\\s*Abs\\.\\s*1\\s*Satz\\s*1\\s*GG"))
bverfg$fgr14_1_2 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*14\\s*Abs\\.\\s*1\\s*Satz\\s*2\\s*GG"))
bverfg$fgr14_2 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*14\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr14_2_1 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*14\\s*Abs\\.\\s*2\\s*Satz\\s*1\\s*GG"))
bverfg$fgr14_2_2 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*14\\s*Abs\\.\\s*2\\s*Satz\\s*2\\s*GG"))
bverfg$fgr14_guarantee <- bverfg$fgr14_1 + bverfg$fgr14_1_1 + bverfg$fgr14_1_2 + bverfg$fgr14_2 +
  bverfg$fgr14_2_1 + bverfg$fgr14_2_2
bverfg$fgr14_3 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*14\\s*Abs\\.\\s*3\\s*GG"))
bverfg$fgr14_3_1 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*14\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG"))
bverfg$fgr14_3_2 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*14\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG"))
bverfg$fgr14_3_3 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*14\\s*Abs\\.\\s*3\\s*Satz\\s*3\\s*GG"))
bverfg$fgr14_3_4 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*14\\s*Abs\\.\\s*3\\s*Satz\\s*4\\s*GG"))
bverfg$fgr14_3_all <- bverfg$fgr14_3 + bverfg$fgr14_3_1 + bverfg$fgr14_3_2 + bverfg$fgr14_3_3 +
  bverfg$fgr14_3_4
bverfg$fgr15 <- str_count(bverfg$full_text,
                          regex("Art\\.\\s*15\\s*GG"))
bverfg$fgr16_1 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*16\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr16_1_1 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*16\\s*Abs\\.\\s*1\\s*Satz\\s*1\\s*GG"))
bverfg$fgr16_1_2 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*16\\s*Abs\\.\\s*1\\s*Satz\\s*2\\s*GG"))
bverfg$fgr16_1_all <- bverfg$fgr16_1 + bverfg$fgr16_1_1 + bverfg$fgr16_1_2
bverfg$fgr16_2 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*16\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr16_2_1 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*16\\s*Abs\\.\\s*2\\s*Satz\\s*1\\s*GG"))
bverfg$fgr16_2_2 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*16\\s*Abs\\.\\s*2\\s*Satz\\s*2\\s*GG"))
bverfg$fgr16_2_all <- bverfg$fgr16_2 + bverfg$fgr16_2_1 + bverfg$fgr16_2_2
bverfg$fgr16a_1 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr16a_2 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr16a_2_1 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*2\\s*Satz\\s*1\\s*GG"))
bverfg$fgr16a_2_2 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*2\\s*Satz\\s*2\\s*GG"))
bverfg$fgr16a_3 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*3\\s*GG"))
bverfg$fgr16a_3_1 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG"))
bverfg$fgr16a_3_2 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG"))
bverfg$fgr16a_4 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*4\\s*GG"))
bverfg$fgr16a_4_1 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*4\\s*Satz\\s*1\\s*GG"))
bverfg$fgr16a_4_2 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*4\\s*Satz\\s*2\\s*GG"))
bverfg$fgr16a_5 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*16\\s*a\\s*Abs\\.\\s*5\\s*GG"))
bverfg$fgr16a_all <- bverfg$fgr16a_1 + bverfg$fgr16a_2 + bverfg$fgr16a_2_1 + bverfg$fgr16a_2_2 +
  bverfg$fgr16a_3 + bverfg$fgr16a_3_1 + bverfg$fgr16a_3_2 + bverfg$fgr16a_4 + bverfg$fgr16a_4_1 +
  bverfg$fgr16a_4_2 + bverfg$fgr16a_5
bverfg$fgr17 <- str_count(bverfg$full_text,
                          regex("Art\\.\\s*17\\s*GG"))
bverfg$fgr17a_1 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*17\\s*a\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr17a_2 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*17\\s*a\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr18 <- str_count(bverfg$full_text,
                          regex("Art\\.\\s*18\\s*GG"))
bverfg$fgr19_1_1 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*19\\s*Abs\\.\\s*1\\s*Satz\\s*1\\s*GG"))
bverfg$fgr19_1_2 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*19\\s*Abs\\.\\s*1\\s*Satz\\s*2\\s*GG"))
bverfg$fgr19_2 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*19\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr19_3 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*19\\s*Abs\\.\\s*3\\s*GG"))
bverfg$fgr19_4 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*19\\s*Abs\\.\\s*4\\s*GG"))
bverfg$fgr19_4_1 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*19\\s*Abs\\.\\s*4\\s*Satz\\s*1\\s*GG"))
bverfg$fgr19_4_2 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*19\\s*Abs\\.\\s*4\\s*Satz\\s*2\\s*GG"))
bverfg$fgr19_4_3 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*19\\s*Abs\\.\\s*4\\s*Satz\\s*3\\s*GG"))
bverfg$fgr19_4_all <- bverfg$fgr19_4 + bverfg$fgr19_4_1 + bverfg$fgr19_4_2 + bverfg$fgr19_4_3
bverfg$fgr20_4 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*20\\s*Abs\\.\\s*4\\s*GG"))
bverfg$fgr28_2 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*28\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr28_2_1 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*28\\s*Abs\\.\\s*2\\s*Satz\\s*1\\s*GG"))
bverfg$fgr28_2_2 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*28\\s*Abs\\.\\s*2\\s*Satz\\s*2\\s*GG"))
bverfg$fgr28_2_3 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*28\\s*Abs\\.\\s*2\\s*Satz\\s*3\\s*GG"))
bverfg$fgr28_2_all <- bverfg$gr28_2 + bverfg$gr28_2_1 + bverfg$gr28_2_2 + bverfg$gr28_2_3
bverfg$fgr33_1 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*33\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr33_2 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*33\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr33_3 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*33\\s*Abs\\.\\s*3\\s*GG"))
bverfg$fgr33_3_1 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*33\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG"))
bverfg$fgr33_3_2 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*33\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG"))
bverfg$fgr33_4 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*33\\s*Abs\\.\\s*4\\s*GG"))
bverfg$fgr33_5 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*33\\s*Abs\\.\\s*5\\s*GG"))
bverfg$fgr33_publicofficial <- bverfg$fgr33_2 + bverfg$fgr33_3_1 + bverfg$fgr33_4 + bverfg$fgr33_5
bverfg$fgr38_1 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*38\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr38_1_1 <- str_count(bverfg$full_text,
                              regex("Art\\.\\s*38\\s*Abs\\.\\s*1\\s*Satz\\s*1\\s*GG"))
bverfg$fgr38_2 <- str_count(bverfg$full_text,
                            regex("Art\\.\\s*38\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr38_all <- bverfg$fgr38_1 + bverfg$fgr38_1_1 + bverfg$fgr38_2
bverfg$fgr101_1 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*101\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr101_1_1 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*101\\s*Abs\\.\\s*1\\s*Satz\\s*1\\s*GG"))
bverfg$fgr101_1_2 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*101\\s*Abs\\.\\s*1\\s*Satz\\s*2\\s*GG"))
bverfg$fgr101_2 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*101\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr101_all <- bverfg$fgr101_1 + bverfg$fgr101_1_1 + bverfg$fgr101_1_2 +
  bverfg$fgr101_2
bverfg$fgr103_1 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*103\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr103_2 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*103\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr103_3 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*103\\s*Abs\\.\\s*3\\s*GG"))
bverfg$fgr103_straf <- bverfg$fgr103_2 + bverfg$fgr103_3
bverfg$fgr104_1 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*104\\s*Abs\\.\\s*1\\s*GG"))
bverfg$fgr104_1_1 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*104\\s*Abs\\.\\s*1\\s*Satz\\s*1\\s*GG"))
bverfg$fgr104_1_2 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*104\\s*Abs\\.\\s*1\\s*Satz\\s*2\\s*GG"))
bverfg$fgr104_2 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*104\\s*Abs\\.\\s*2\\s*GG"))
bverfg$fgr104_2_1 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*104\\s*Abs\\.\\s*2\\s*Satz\\s*1\\s*GG"))
bverfg$fgr104_2_2 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*104\\s*Abs\\.\\s*2\\s*Satz\\s*2\\s*GG"))
bverfg$fgr104_2_3 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*104\\s*Abs\\.\\s*2\\s*Satz\\s*3\\s*GG"))
bverfg$fgr104_2_4 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*104\\s*Abs\\.\\s*2\\s*Satz\\s*4\\s*GG"))
bverfg$fgr104_3 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*104\\s*Abs\\.\\s*3\\s*GG"))
bverfg$fgr104_3_1 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*104\\s*Abs\\.\\s*3\\s*Satz\\s*1\\s*GG"))
bverfg$fgr104_3_2 <- str_count(bverfg$full_text,
                               regex("Art\\.\\s*104\\s*Abs\\.\\s*3\\s*Satz\\s*2\\s*GG"))
bverfg$fgr104_4 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*104\\s*Abs\\.\\s*4\\s*GG"))
bverfg$fgr104_all <- bverfg$fgr104_1 + bverfg$fgr104_1_1 + bverfg$fgr104_1_2 + bverfg$fgr104_2 +
  bverfg$fgr104_2_1 + bverfg$fgr104_2_2 + bverfg$fgr104_2_3 + bverfg$fgr104_2_4 + bverfg$fgr104_3 +
  bverfg$fgr104_3_1 + bverfg$fgr104_3_2 + bverfg$fgr104_4
bverfg$fgrwr136 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*136\\s*WRV"))
bverfg$fgrwr137 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*137\\s*WRV"))
bverfg$fgrwr138 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*138\\s*WRV"))
bverfg$fgrwr139 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*139\\s*WRV"))
bverfg$fgrwr141 <- str_count(bverfg$full_text,
                             regex("Art\\.\\s*141\\s*WRV"))
bverfg$fgrwr_all <- bverfg$fgrwr136 + bverfg$fgrwr137 + bverfg$fgrwr138 + bverfg$fgrwr139 +
  bverfg$fgrwr141

##### DOMAIN ----
  ##### domain defined by mention of pertinent GR ----
bverfg$ncrim <- bverfg$gr2_2_all + bverfg$gr10_all + bverfg$gr11_all + bverfg$gr13_all +
  bverfg$gr16_2_all + bverfg$gr19_4_all + bverfg$gr101_all + bverfg$gr103_1 + bverfg$gr103_straf + bverfg$gr104_all  
bverfg$nperson <- bverfg$gr4_religion + bverfg$gr6_all + bverfg$gr7_all + bverfg$gr16a_all + bverfg$grwr_all
bverfg$npolit <- bverfg$gr5_speech + bverfg$gr5_3_all + bverfg$gr8_all + bverfg$gr9_association +
  bverfg$gr28_2_all + bverfg$gr33_publicofficial + bverfg$gr38_all
bverfg$necon <- bverfg$gr2_1 + bverfg$gr3_1 + bverfg$gr9_3_all + bverfg$gr12_1_all + bverfg$gr14_guarantee +
  bverfg$gr19_3

bverfg$crim <- ifelse(bverfg$ncrim > 0, 1, 0)
bverfg$person <- ifelse(bverfg$nperson > 0, 1, 0)
bverfg$polit <- ifelse(bverfg$npolit > 0, 1, 0)
bverfg$econ <- ifelse(bverfg$necon > 0, 1, 0)

bverfg$cldomain <- ifelse(bverfg$crim > 0, 1,
                          ifelse(bverfg$person > 0, 2,
                                 ifelse(bverfg$polit > 0, 3,
                                        ifelse(bverfg$econ > 0, 4, 0))))
bverfg$cldomain <- factor(bverfg$cldomain,
                          levels = c(0:4),
                          labels = c("no", "crim", "person",
                                     "polit", "econ"))

bverfg$crimonly <- ifelse(bverfg$crim == 1 
                          & bverfg$econ == 0 
                          & bverfg$person == 0, 1, 0)
  # no need to exclude bverfg$polit, as majority is the same
bverfg$econonly <- ifelse(bverfg$econ == 1
                          & bverfg$crim == 0
                          & bverfg$polit == 0
                          & bverfg$person == 0, 1, 0)
  # must exclude all other domains, as policy preferences 
  # are opposite to each other
bverfg$persononly <- ifelse(bverfg$person == 1
                            & bverfg$econ == 0
                            & bverfg$crim == 0
                            & bverfg$polit == 0, 1, 0)
  # must exclude all other domains as, here, only FDP and Green favour
bverfg$politonly <- ifelse(bverfg$polit == 1
                           & bverfg$econ == 0
                           & bverfg$person == 0, 1, 0)
  # no need to exclude crim, as preferences in both domains are the same

  ##### ideological majority by domain ----
bverfg %>% 
  mutate(ideology =
           case_when(
             cldomain == "econ" & totright > (numjudges/2) ~ 1,
             cldomain == "person" & 
               (totgreen + totfdp > numjudges/2) ~ 1,
             cldomain == "polit" & totcdu < (numjudges/2) ~ 1,
             cldomain == "crim" & totcdu < (numjudges/2) ~ 1,
             cldomain == "no" ~ 99,
             TRUE ~ 0
           )) -> bverfg
bverfg$ideology2 <- factor(bverfg$ideology,
                          levels = c(0, 1),
                          labels = c("minority", "majority"))
# bverfg$ideology2 <- ifelse(bverfg$ideology == "majority", 1, 0)

  ##### degree of majority influence ----
bverfg %>% mutate(degmaj =
           case_when(
             cldomain == "econ" ~ totright/numjudges,
             cldomain == "person" ~ 
               (totgreen + totfdp)/numjudges,
             cldomain == "polit" ~ (numjudges - totcdu)/numjudges,
             cldomain == "crim" ~ (numjudges - totcdu)/numjudges,
             TRUE ~ 0
           )) -> bverfg
bverfg$degmaj <- ifelse(bverfg$cldomain == "no", NA,
                        bverfg$degmaj)

##### INTERMEDIATE SAVE -----
save(bverfg, file = "bverfg240129intermediate.RData")

##### WEIGHTED IDEOLOGY ----
     # all data preparation in separate script
       #"BVerfGManifesto240110"
load("party240110.RData")
bverfg <- left_join(bverfg, party)

##### IRREGULAR CHAMBER COMPOSITION ----
# all data preparation in separate script
  # "BVerfGChamber240110.R"
# here only import of variables relevant for estimation of
  # party effects

load("chamber240110.RData")
bverfg <- left_join(bverfg, chamber)
save(bverfg, file = "bverfg240110.RData")

##### INCOMPLETE SENATE ----
  ##### incomplete: irr_se ----
bverfg %>% 
  mutate(irr_se = case_when(body == "senate" & numjudges < 8 ~ 1,
         TRUE ~ 0)) -> bverfg
  ##### in relevant domain: irrdm_se ----
bverfg %>% 
  mutate(irrdm_se = case_when(irr_se == 1 &
                                (econ == 1 |
                                 crim == 1 |
                                 polit == 1 |
                                 person == 1) ~ 1,
                              TRUE ~ 0)) -> bverfg
  ##### majority affected: flipgr_se ----
bverfg %>% 
  mutate(flipgr_se = case_when(irrdm_se == 1 &
                                 ((econ == 1 &
                                    totcdu + totfdp != totspd + totgreen) |
                                 (crim == 1 &
                                    totspd + totfdp + totgreen != totcdu) |
                                 (polit == 1 &
                                    totspd + totfdp + totgreen != totcdu) |
                                 (person == 1 &
                                    totfdp + totgreen != totcdu + totspd)) ~ 1,
                               TRUE ~ 0)) -> bverfg
  ##### direction of majority: flipgrmaj_se ----
bverfg %>% 
  mutate(flipgrmaj_se = case_when(irrdm_se == 1 &
                                 ((econ == 1 &
                                     totcdu + totfdp > totspd + totgreen) |
                                    (crim == 1 &
                                       totspd + totfdp + totgreen > totcdu) |
                                    (polit == 1 &
                                       totspd + totfdp + totgreen > totcdu) |
                                    (person == 1 &
                                       totfdp + totgreen > totcdu + totspd)) ~ 1,
                               TRUE ~ 0)) -> bverfg

  ##### (no) uncertainty about regular composition: flipntmaj_se ----
bverfg$flipntmaj_se <- bverfg$flipgrmaj_se

  ##### no overlap between domains: flipntmajonly_se ----
bverfg %>% 
  mutate(flipntmajonly_se =
           case_when(flipntmaj_se == 1 &
                       ((econ == 1 & crim == 0 &
                          polit == 0 & person == 0) |
                       (crim == 1 & econ == 0 &
                          person == 0) |
                       (person == 1 & econ == 0 &
                          crim == 0 & polit == 0) |
                       (polit == 1 & econ == 0 &
                          person == 0)) ~ 1,
                    TRUE ~ 0)) -> bverfg

##### ALL IRREGULAR COMPOSITION ----
bverfg %>% 
  mutate(irr = case_when((irr_ch == 1 |
                            irr_se == 1) ~ 1,
                         TRUE ~ 0),
          irrdm = case_when((irrdm_ch == 1 |
                               irrdm_se == 1) ~ 1,
                            TRUE ~ 0),
         flipgr = case_when((flipgr_ch == 1 |
                               flipgr_se == 1) ~ 1,
                            TRUE ~ 0),
         flipgrmaj = case_when((flipgrmaj_ch == 1 |
                                  flipgrmaj_se == 1) ~ 1,
                               TRUE ~ 0),
         flipntmaj = case_when((flipntmaj_ch == 1 |
                                  flipntmaj_se == 1) ~ 1,
                               TRUE ~ 0),
         flipntmajonly = case_when((flipntmajonly_ch == 1 |
                                      flipntmajonly_se == 1) ~ 1,
                                   TRUE ~ 0)) -> bverfg

##### REFEREE ----
  # data preparation done in separate scripts, one per senate
  ##### senate 1 ----
load("/Users/engel/Documents/word/Manuskript/Governance/BVerfG/Data/2024 Referee/bverfg2.RData")
  #### select variables for join
bverfg2 %>% 
  select(id,
         starts_with("comp_"),
         starts_with("tx_"),
         starts_with("dm_"),
         starts_with("ref_"),
         starts_with("ex_"),
         sumref, sumdm, sumcomp) -> bverfg2join
bverfg <- left_join(bverfg, bverfg2join)
  
  ##### senate 2 ----
load("/Users/engel/Documents/word/Manuskript/Governance/BVerfG/Data/2024 Referee/bverfg3.RData")
bverfg3 %>% 
  select(id,
         starts_with("comp2_"),
         starts_with("tx2_"),
         starts_with("dm2_"),
         starts_with("ref2_"),
         sumref2, sumdm2, sumcomp2) -> bverfg3join
bverfg <- left_join(bverfg, bverfg3join)

##### SAVE ----
save(bverfg, file = "bverfg240129.RData")

##### WINDOW NEAR BREAKPOINT ----
  # all data preparation in separate data preparation file
  # BVerfGDataPrepWindow240110.R"
  # results in 4 separate datasets
    # window 10
      # all data: "window10.RData"
      # duplicate observations removed: "window10net.RData"
    # window 20
      # all data: "window20.RData"
      # duplicate observations removed: "window20net.RData"