##### BVerfG
##### GPT Preparation
##### help file with list of domains
##### 240129

##### HOUSEKEEPING ----
rm(list = ls())
graphics.off()

library(tidyr)
library(dplyr)
library(stringr)

setwd("/Users/engel/Documents/word/Manuskript/Governance/bverfg/Data/2023 GPT Tests")
load("bverfg240129.RData")

##### EMPTY DATASET ----
bverfg %>% 
  select(starts_with("dm_")) %>% 
  names() -> key

domain <- data.frame(key = key, german = NA)

##### FILL IN GERMAN DEFINITIONS ----
##### senate 1 ----
domain$german[domain$key == "dm_environmental"] <- 
  "Öffentliches Umweltschutzrecht, Öffentliches Umweltrecht"
domain$german[domain$key == "dm_property"] <-
  "Verfahren über Beeinträchtigungen von Grundstückseigentum (mit Ausnahme finanzieller Lasten), die sich auf öffentliches Recht stützen; sonstiges grundstücksbezogenes Eigentumsrecht (außer privatem Grundstücksrecht)"
domain$german[domain$key == "dm_taking"] <-
  "Enteignungsrecht"
domain$german[domain$key == "dm_farming"] <-
  "Höferecht (britische Zone)"
domain$german[domain$key == "dm_restitution"] <-
  "Wiedergutmachungsrecht (Entschädigungs- und Rückerstattungsrecht)"
domain$german[domain$key == "dm_postwar"] <- 
    "Kriegsfolgenliquidation"
domain$german[domain$key == "dm_ip"] <-
    "Recht des geistigen Eigentums"
domain$german[domain$key == "dm_inheritance"] <-
    "Erbrecht"
domain$german[domain$key == "dm_art"] <-
    "Kunstfreiheit"
domain$german[domain$key == "dm_gaming"] <-
  "Glücksspielrecht"
domain$german[domain$key == "dm_family"] <-
    "Familienrecht"
domain$german[domain$key == "dm_names"] <-
    "Namensrecht"
domain$german[domain$key == "dm_civilstatus"] <-
    "Personenstandsrecht"
domain$german[domain$key == "dm_transsexual"] <-
    "Transsexuellenrecht"
domain$german[domain$key == "dm_child"] <-
    "Kinder- und Jugendhilferecht"
domain$german[domain$key == "dm_parentalallowance"] <-
  "Elterngeld, Erziehungsgeld"
domain$german[domain$key == "dm_custody"] <-
  "Betreuungsrecht"
domain$german[domain$key == "dm_supportpayment"] <-
  "Unterhaltsrecht"
domain$german[domain$key == "dm_matriomonial"] <-
  "Güterrecht"
domain$german[domain$key == "dm_pensionright"] <-
  "Versorgungsausgleichsrecht"
domain$german[domain$key == "dm_labour"] <-
  "Arbeitsrecht (einschließlich betrieblicher Altersversorgung)"
domain$german[domain$key == "dm_labourleasing"] <-
  "Recht der Arbeitnehmerüberlassung"
domain$german[domain$key == "dm_maternityleave"] <-
  "Mutterschutzrecht, soweit es nicht zum Sozialrecht gehört"
domain$german[domain$key == "dm_association"] <-
  "Vereinigungsfreiheit - Art. 9 GG -"
domain$german[domain$key == "dm_university"] <-
  "Hochschulrecht (einschließlich Promotionsund Habilitationsrecht, nicht jedoch sonstiges Hochschulausbildungs und Hochschulprüfungsrecht)"
domain$german[domain$key == "dm_science"] <-
  "Freiheit von Wissenschaft, Forschung und Lehre - Art. 5 Abs. 3 GG -"
domain$german[domain$key == "dm_petitions"] <-
  "Petitionsrecht - Art. 17 GG -"
domain$german[domain$key == "dm_childallowance"] <-
  "Bundeskindergeldgesetz"
domain$german[domain$key == "dm_welfarebasic"] <- 
  "Grundsicherung für Arbeitsuchende - SGB II"
domain$german[domain$key == "dm_asylumallowance"] <- 
  "Asylbewerberleistungsrecht"
domain$german[domain$key == "dm_welfare"] <-
  "Sozialhilfe"
domain$german[domain$key == "dm_vocationalallowance"] <-
  "Recht der Ausbildungsförderung"
domain$german[domain$key == "dm_services"] <-
  "Dienst- und Werkvertragsrecht"
domain$german[domain$key == "dm_professions"] <-
  "Recht der selbständig und vorwiegend persönlich ausgeübten Berufe, soweit es in den Verfahren (zumindest auch) um die Auslegung des Art. 12 GG geht. Solche Berufe sind: a) die klassischen freien Berufe (z.B. Rechtsanwälte, Ärzte, Architekten, Notare), b) andere selbständig, vorwiegend persönlich ausgeübte Berufe (z.B. Makler, Hebammen, Landwirte, Handwerker)"
domain$german[domain$key == "dm_pensionfund"] <-
  "Recht der berufsständischen Versorgungseinrichtungen"
domain$german[domain$key == "dm_landlord"] <-  
  "Mietrecht"
domain$german[domain$key == "dm_condominium"] <-  
  "Wohnungseigentumsrecht"
domain$german[domain$key == "dm_exams"] <-  
  "Ausbildungs- und Prüfungsrecht (auch an Hochschulen, nicht jedoch im Rahmen des allgemeinen Schulrechts)"
domain$german[domain$key == "dm_healthinsurance"] <-  
  "Wirtschaftsrechtliche Fragen im Bereich der gesetzlichen Krankenversicherung"
domain$german[domain$key == "dm_competition"] <-  
  "Wettbewerbsrecht (UWG, GWB)"
domain$german[domain$key == "dm_competitionenergy"] <-  
  "Wettbewerbsrecht (UWG, GWB) und Regulierungsrecht nach EnWG"
domain$german[domain$key == "dm_sales"] <-  
  "Kaufrecht"
domain$german[domain$key == "dm_attorney"] <-  
  "Anwaltsvertragsrecht"
domain$german[domain$key == "dm_tax"] <-
  "Steuerrecht mit Ausnahme der örtlichen Verbrauch- und Aufwandsteuern"
domain$german[domain$key == "dm_levies"] <-
  "Recht der nichtsteuerlichen Abgaben und Recht der örtlichen Verbrauch- und Aufwandsteuern; Kommunalabgabenrecht (einschließlich Abgabenrecht von Verbänden); Abgabenrecht (einschließlich Abgabenrecht von Verbänden)"
domain$german[domain$key == "dm_developmentcharge"] <-
  "Erschließungsrecht"
domain$german[domain$key == "dm_regulation"] <-
  "Regulierungsrecht (Telekommunikation, Post, Eisenbahnen)"
domain$german[domain$key == "dm_construction"] <-
  "Bau- und Bodenrecht"
domain$german[domain$key == "dm_landsale"] <-
  "Grundstücksverkehrsrecht"
domain$german[domain$key == "dm_mining"] <-
  "Bergrecht"
domain$german[domain$key == "dm_planning"] <-
  "Städtebauliches und ländliches Planungsrecht; Städtebauliches und Fachplanungsrecht (soweit nicht öffentliches Umweltschutzrecht); Fachplanungsrecht (außer Luftverkehrs- und Kernenergierecht); Fachplanungsrecht"
domain$german[domain$key == "dm_landuse"] <-
  "Raumplanungsrecht; Raumordnungsrecht"
domain$german[domain$key == "dm_conservation"] <-
  "Natur- und Landschaftsschutzrecht"
domain$german[domain$key == "dm_landconsolidation"] <-
  "Städtisches Umlegungs- und Grenzbereinigungsrecht; Flurbereinigungsrecht"
domain$german[domain$key == "dm_religion"] <-
  "Recht der Glaubens- und Bekenntnisfreiheit - Art. 4 Abs. 1 und 2 GG -"
domain$german[domain$key == "dm_school"] <-
  "Schulrecht (einschließlich des Privatschulrechts - Art. 7 GG - und einschl. des Prüfungs- und Versetzungsrechts im Rahmen des Schulrechts, jedoch nicht Prüfungen für das Lehramt an Schulen) "
domain$german[domain$key == "dm_reunification"] <-
  "Grundstücks- und unternehmensbezogene Vermögensfragen im Zusammenhang mit der Herstellung der Deutschen Einheit (insbesondere Vermögensgesetz, Investitionsvorranggesetz, Entschädigungs- und Ausgleichsleistungsgesetz, Sachenrechtsänderungsgesetz, Schuldrechtsänderungsgesetz, Landwirtschaftsanpassungsgesetz)"
domain$german[domain$key == "dm_corporations"] <-
  "Gesellschaftsrecht, einschließlich Genossenschaftsrecht; Recht des Versicherungswesens; Bank-, Börsen- und Wertpapierrecht; Kreditrecht einschließlich des Rechts der Sicherungen"
domain$german[domain$key == "dm_socialsecurity"] <-
  "Sozialrecht"
domain$german[domain$key == "dm_speech"] <-
  "Recht der freien Meinungsäußerung, Rundfunk- und Pressefreiheit - Art. 5 Abs. 1 GG -"
domain$german[domain$key == "dm_manifestations"] <- 
  "Versammlungsfreiheit / Demonstrationsrecht - Art. 8 GG -"
domain$german[domain$key == "dm_freedomgeneral"] <-
  "Allgemeines Persönlichkeitsrecht - Art. 2 Abs. 1 GG -"
domain$german[domain$key == "dm_dataprotection"] <-
  "Recht des Datenschutzes; Recht des öffentlichrechtlichen Datenschutzes, soweit ausschließlich oder ganz überwiegend landesrechtliche Regelungen im Streit stehen"
domain$german[domain$key == "dm_competitionspeech"] <-
  "Wettbewerbsrecht (UWG; GWB), soweit die Rüge der Verletzung des Art. 5 Abs. 1 GG von erheblicher Bedeutung ist"
domain$german[domain$key == "dm_torts"] <-
  "Sonstiges Deliktsrecht"


##### save ----
save(domain, file = "domain240129.RData")
