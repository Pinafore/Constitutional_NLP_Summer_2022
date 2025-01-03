from Data_Preprocessing_for_Topic_Models import clean_text, read_cases

import csv

# open the file in the write mode
f = open('toy1.csv', 'w')
# create the csv writer
writer = csv.writer(f)
# write a row to the csv file
writer.writerow(['bverfg_id_forward', 'full_text'])
writer.writerow(['123', 'IM NAMEN DES VOLKES In dem Verfahren über die Verfassungsbeschwerde des Herrn (…), gegen den Beschluss des Landgerichts Regensburg - auswärtige Strafvollstreckungskammer bei dem Amtsgericht Straubing - vom 3. September 2021 - SR StVK 430/21 - hat die 1. Kammer des Zweiten Senats des Bundesverfassungsgerichts durch die Vizepräsidentin König und die Richter Müller, Maidowski am 28. Juli 2022 einstimmig beschlossen: Der Beschluss des Landesgerichts Regensburg - SR StVK 430/21 - verletzt den Beschwerdeführer in seinem Grundrecht aus Artikel 3 Absatz 1 in Verbindung mit Artikel 20 Absatz 3 des Grundgesetzes. Der Beschluss wird aufgehoben. Die Sache wird an das Landgericht Regensburg zurückverwiesen. Der Freistaat Bayern hat dem Beschwerdeführer die notwendigen Auslagen für das Verfassungsbeschwerdeverfahren zu erstatten. G r ü n d e : 1 Der inhaftierte Beschwerdeführer wendet sich gegen die Ablehnung seines Antrags auf Prozesskostenhilfe in einem Strafvollzugsverfahren. I. 2 1. Der Beschwerdeführer verbüßt eine lebenslange Freiheitsstrafe in der Justizvollzugsanstalt Straubing (Bayern). Er bezieht Taschengeld und ernährt sich vegetarisch. In der Vergangenheit erhielt er für einen gewissen Zeitraum ohne Vorankündigung seitens der Justizvollzugsanstalt fleischhaltige Kost. König Müller Maidowski'])
writer.writerow(['124', 'IM NAMEN DES VOLKES In dem Verfahren über die Verfassungsbeschwerde des Herrn (…), - Bevollmächtigte: (…) gegen den Beschluss des Landgerichts Zwickau vom 6. Dezember 2021 - 1 Qs 204/21 - hat die 2. Kammer des Zweiten Senats des Bundesverfassungsgerichts durch den Richter Huber und die Richterinnen Kessal-Wulf, Wallrabenstein am 29. Juli 2022 einstimmig beschlossen: Der Beschluss des Landgerichts Zwickau vom 6. Dezember 2021 - 1 Qs 204/21 - verletzt den Beschwerdeführer in seinem Recht auf informationelle Selbstbestimmung aus Artikel 2 Absatz 1 in Verbindung mit Artikel 1 Absatz 1 des Grundgesetzes, soweit er die Anfertigung eines Zehnfinger- und Handflächenabdrucks und eines Fünfseiten- und Ganzkörperbildes betrifft. Er wird insoweit aufgehoben. Die Sache wird an das Landgericht Zwickau zurückverwiesen. Im Übrigen wird die Verfassungsbeschwerde nicht zur Entscheidung angenommen. Der Freistaat Sachsen hat dem Beschwerdeführer seine notwendigen Auslagen zu erstatten. Der Wert des Gegenstands der anwaltlichen Tätigkeit wird auf 10.000 Euro (in Worten: zehntausend Euro) festgesetzt. G r ü n d e : A. 1 Der Beschwerdeführer wendet sich gegen einen Beschluss des Landgerichts Zwickau, mit welchem dieses seine Beschwerde gegen die gerichtliche Bestätigung einer Anordnung erkennungsdienstlicher Maßnahmen nach § 81b Alt. 1 StPO als unbegründet verwarf. Er rügt die Verletzung seines Rechts auf informationelle Selbstbestimmung aus Art. 2 Abs. 1 in Verbindung mit Art. 1. Abs. 1 GG. Huber Kessal-Wulf Wallrabenstein'])
# close the file
f.close()


text1 = 'IM NAMEN DES VOLKES In dem Verfahren über die Verfassungsbeschwerde des Herrn (…), gegen den Beschluss des Landgerichts Regensburg - auswärtige Strafvollstreckungskammer bei dem Amtsgericht Straubing - vom 3. September 2021 - SR StVK 430/21 - hat die 1. Kammer des Zweiten Senats des Bundesverfassungsgerichts durch die Vizepräsidentin König und die Richter Müller, Maidowski am 28. Juli 2022 einstimmig beschlossen: Der Beschluss des Landesgerichts Regensburg - SR StVK 430/21 - verletzt den Beschwerdeführer in seinem Grundrecht aus Artikel 3 Absatz 1 in Verbindung mit Artikel 20 Absatz 3 des Grundgesetzes. Der Beschluss wird aufgehoben. Die Sache wird an das Landgericht Regensburg zurückverwiesen. Der Freistaat Bayern hat dem Beschwerdeführer die notwendigen Auslagen für das Verfassungsbeschwerdeverfahren zu erstatten. G r ü n d e : 1 Der inhaftierte Beschwerdeführer wendet sich gegen die Ablehnung seines Antrags auf Prozesskostenhilfe in einem Strafvollzugsverfahren. I. 2 1. Der Beschwerdeführer verbüßt eine lebenslange Freiheitsstrafe in der Justizvollzugsanstalt Straubing (Bayern). Er bezieht Taschengeld und ernährt sich vegetarisch. In der Vergangenheit erhielt er für einen gewissen Zeitraum ohne Vorankündigung seitens der Justizvollzugsanstalt fleischhaltige Kost. König Müller Maidowski'

print('text1:', text1)

text2 = clean_text(text1)
print('text2:', text2)

text3 = read_cases('toy1.csv')
