---
title: "Metodologie využití dat"
author: "Petr Bouchal"
date: 2023-04-15
output: html_document
---

## Zdroje a využití dat

### Čeho se potřebujeme dobrat

Cílem je na z dat na úrovni projektů vyvodit podíly celkových vydaných částek ESI fondů v jednotlivých kategoriích tzv. klima tagů, tj. Rio markerů.

Kategorizaci vynaložených financí do jednotlivých klima tagů určuje  prováděcí nařízení 215/2014. Příloha I nařízení se týká ESI fondů mimo zemědělství (EAFRD / EFZRV) a v tabulce 1 určuje klima tag pro každou z 125 oblastí intervence (v evropské legislativě oblast zásahu; angl. categories of intervention). Příloha II pak totéž dělá pro EFZRV, a to navázáním klima tagů na jednotlivé články nařízení 1305/2013 (společné nařízení ESIF), podle kterých se výdaje EFZRV člení.

### Proč to není přímočaré

Veřejná projektová data ESIF a CAP vlastní informaci o alokaci výdajů jednotlivých projektů na klima tagy neobsahují; stejně tak neobsahují přímo informaci o alokaci výdajů projektů do oblastí intervencí nebo relevantních cílů CAP. Navíc jeden projekt ESIF mimo PRV může spadat do více oblastí intervence nebo do více tematických cílů, což oboje ovlivňuje přiřazení klima tagu.

U ESF navíc platí, že ačkoli oblasti intervence, do kterých lze projekty alokovat, mají klima tag 0, může projekt zároveň patřit do specifického vedlejšího tématu "Podpora přechodu na nízkouhlíkové hospodářství, které účinně využívá zdroje" (tabulka 6 v příloze 1 prováděcího nařízení), díky kterému by projektu byl přiřazen klima tag 100 %. Takové přiřazení ale nelze u českých projektů ESF nijak dovodit.

Systém alokace klimatagů navíc zahrnuje další pravidlo (čl. 1, odst. 1 (b) prováděcího nařízení), které vyžaduje další napojení dat. Pro výdaje, které jsou v tematickém cíli 4 nebo 5 (TC je 11, je to hlavní obsahové členění cílů ESIF), lze počítat klima tag 40 %, i pokud spadá do oblasti intervence, pro kterou je stanoven klima tag 40 %. Opět ale z veřejných dat nelze přímo přiřadit projekt k tematickému cíli.

### Jak to děláme

#### Postup u EFRR, FS a ESF

Proto postupujeme u ESIF mimo zemědělství následovně:

1. z [veřejných dat o výdajích ESIF](https://dotaceeu.cz/cs/statistiky-a-analyzy/seznam-operaci-(prijemcu)) (zdroj A1) na dotaceEU.cz zjišťujeme aktuálně vyčerpané prostředky pro jednotlivé fondy
2. z [otevřených dat](https://data.gov.cz/datov%C3%A1-sada?iri=https://data.gov.cz/zdroj/datov%C3%A9-sady/66002222/af32ce8f398945f72b65a7215e2ec78e) (zdroj A2) ke každému projektu přiřazujeme specifické cíle
3. z neveřejné sestavy poskytnuté od MMR (zdroj B1 - sestavy E001 a B2 - sestava E005) dovozujeme (1) podíl výdajů každého projektu alokovaný do jednotlivých oblastí intervence a (2) podíl výdajů každého projektu na jednotlivé specifické cíle, do kterých projekt spadá - každý projekt tedy rozpadneme na části s velikostmi odpovídajími těmto poměrům. (Relativně málo projektů spadá do více oblastí intervence a velmi málo spadá do více specifických cílů).
4. Pomocí matice vazeb cílů poskytnuté MMR (zdroj C) určíme, do jakého tematického cíle projekt patří - zde jde o to ze specifického cíle (jeden z cílů daného OP) dovodit tematický cíl (TC jsou průřezové napříč všemi fondy a operačními programy)
5. Následně pomocí pravidel z prováděcího nařízení a klima tagů uvedených v jeho příloze dovozujeme pro každý balíček peněz jeho klima tag.

Jakmile aktualizujeme zdroj A1 a A2, může se stát, že v aktuálních veřejných datech budou projekty, které nenajdeme ve zdroji B, který je náročnější aktualizovat (musí se o něj žádat). U těchto projektů ale díky veřejné tabulce víme alespoň výčet kategorií intervence, i když vlivem zastarání sestavy MMR nevíme přesné rozdělení výdajů mezi tyto kategorie. V takových případech tedy projekty rozdělíme rovnoměrně mezi uvedené kategorie. To pravděpodobně mírně nadhodnocuje výdaje alokované do minoritních kategorií, ale další zpřesňování (např. extrapolací z dřívějších projektů) by bylo neúměrně náročné a nepřineslo by velkou změnu výsledku.

#### Postup u EFZRV

U EFZRV je postup složitější. Z dostupných otevřených dat totiž není patrné, jak kategorie projektů v datech uvedené navázat na cíle, ke kterým prováděcí nařízení uvádí klima tagy.

U zemědělství postupujeme následovně:

1. Využíváme [otevřená data SZIF](https://www.szif.cz/cs/seznam-prijemcu-dotaci) (zdroj D), pro kategorizaci pak položku opatření
2. S pomocí [schématu podpor SZIF](https://www.szif.cz/cs/CmDocument?rid=%2Fapa_anon%2Fcs%2Fdokumenty_ke_stazeni%2Fprv2014%2Fzakladni_informace%2F1436519577270.pdf) dovozujeme z kódu opatření v datech skutečný obsah opatření podle schématu; následně k jednotlivým opatřením podle jejich povahy přiřazujeme článek nařízení 1305/2013, podle kterého lze s pomocí prováděcího nařízení 215/2014 přiřadit klima tagy.

### Metodologická poznámka ke CAP vs. ESIF

Součástí ESIF jsou pouze tzv. projektová opatření v rámci PRV, tj. peníze, kde někdo dostane peníze na projekt s daným cílem. 

Tzv. plošná opatření, kde farmáři dostávají dotace na plochu, nejsou součástí ESIF, jsou součástí PRV, a mají přiřazený klima tag. Plošná opatření do celkového výpočtu klima přínosu ESIF nepočítáme.

V datech SZIF jsou pak uvedeny i výdaje z EZZF (ty jsou součástí CAP, ale nikoli ESIF ani PRV) a některé národní dotace. Tyto položky do výpočtu klima příspěvku ESIF také nepočítáme, navíc ani nemají přiřazený klima tag.

Vůbec se pak nezabýváme výdaji z EMFF, tj. v ČR programu OP Rybářství.

> V některých reportech EU (viz např. [Budget Working Document 2022 #1, s. 15](https://commission.europa.eu/system/files/2021-07/db2022_wd_1_programme_statements_web_0.pdf#page=15)) se právě vysoký klima tag pro plošná opatření i EZZF používá jako způsob, jak zvýšit vykazovaný klimapříspěvek evropského rozpočtu. EZZF i EZFRV každý vykazují vyšší příspěvek ke klimatické akci než všechny ostatní ESI fondy (CF, ERDF, ESF).

### Glosář: fondy a programy

Fondy

| Zkratka | Název | Název česky | Poznámka
| 
|

### Glosář: informace o projektech

TO DO

#### ERDF, CF, ESF

#### PRV



### Zdroje výdajů

U ESI fondů je vždy třeba rozlišit, o jakou část peněz podle zdroje se jedná. 

Výdaje ESIF se hrubě dělí na národní a evropské, národní pak na soukromé a veřejné. Evropské a národní veřejné zdroje pak dávají dohromady veřejné zdroje. Některé datová zdroje veřejné zdroje dále člení na státní rozpočet a zdroje z rozpočtů samospráv a další veřejné rozpočty.

EU ráda říká evropskému příspěvku EU cofinancing, příjemci a ČR často slovem kofinancování naopak myslí národní veřejné nebo soukromé kofinancování projektů.

V našich výstupech všude pracujeme s takzvanými celkovými způsobilými výdaji, tj. veřejnými i soukromými, evropskými i českými v jednom.

## Vztah k reportingu EK

EK zveřejňuje [datovou sadu](https://cohesiondata.ec.europa.eu/2014-2020-Categorisation/ESIF-2014-2020-categorisation-ERDF-ESF-CF-planned-/3kkx-ekfq) zahrnující výdaje na klima z jednotlivých operačních programů. 

Oproti zde uvedenému:

- jde pouze o evropský podíl výdajů, přitom podíly spolufinancování se liší mezi státy, programy a příjemci, tj. podíly klima tagů v celkových výdajích se mohou lišit
- data EK ignorují pravidlo čl. 1 odst 1. b. o přidělení klima tagu pro projekty v tematickém cíli 4 a 5
- jde pouze o výdaje řízení DG REGIO, tj. nejsou zde výdaje EZFRV tedy PRV
- vlivem předchozích dvou faktorů EK podhodnocuje příspěvek ESIF v ČR cca o 2 p.b. (tj. celkový příspěvek odpovídá 17 % celkových výdajů oproti 19 % v našich výpočtech), resp. 4 p.b. při započtení PRV v našich výpočtech
- jde o data do konce předchozího roku
- v datech EK je odhadovaný cílový příspěvek ke klimatu, dopočtený podle plánovaných alokací na jednotlivé specifické cíle a tedy oblasti intervencí
- v datech EK nejsou rozpady na operační programy ani žádné jemnější

Ve vlastních [výstupech k tématu](https://cohesiondata.ec.europa.eu/stories/s/a8jn-38y8) EK nikde neprezentuje podíl klima příspěvků na celku ani pokrok k odhadovaným cílovým hodnotám klimapříspěvku; toto z jejich dat dopočítáváme.

## Jak tato čísla vznikají u zdroje?

Stále zůstává otázka, jak vlastně vznikají kategorizace projektů, ze kterých složitě dovozujeme klima tagy.

Takto:
- specifický cíl OP je daný pro každou výzvu. Jedna výzva může zasahovat do více SC a tedy i více TC, ale to se děje relativně málo
- tím pádem je daný i tematický cíl
- s oblastmi intervencí je to složitější. 
    - Každý OP indikativně stanovuje podíl výdajů OP na jednotlivé OI
    - Následně pro každou výzvu stanoví, do kterých OI budou její výdaje spadat, a to se buď napevno promítne do projektů, nebo žadatelé sami uvádějí, jaká číst výdajů projektu spadá do jednotlivých oblastí intervence dostupných ve výzvě; k tomu v některých případech dostávali návod

